# Manages Microsoft SQL database user
define mssql::user (
  $password,
  $default_database,
  $default_language = 'us_english',
  $check_policy     = 'OFF',
  $roles            = undef,
  $sqlcmd           = '"C:\Program Files\Microsoft SQL Server\100\Tools\Binn\sqlcmd.exe"',
  $debug            = false,
) {
  require 'mssql'

  $create_sql = inline_template("
USE [<%= @default_database %>]
CREATE LOGIN [<%= @name %>] WITH PASSWORD = N'<%= @password %>',
DEFAULT_DATABASE = [<%= @default_database %>],
DEFAULT_LANGUAGE = [<%= @default_language %>],
CHECK_POLICY = <%= @check_policy %>
CREATE USER [<%= @name %>] FOR LOGIN [<%= @name %>]
GO")

  exec { "create_user_${name}":
    path      => $::path,
    command   => "${sqlcmd} -Q \"${create_sql}\"",
    unless    => "${sqlcmd} -Q \"exit(if exists(select * from master.sys.server_principals where name='${name}') select 0 else select 1)\"",
    logoutput => true,
    require   => Mssql::Db[$default_database],
  }

  if $roles {
    validate_array($roles)

    $role_sql = inline_template("
USE [<%= @default_database %>]
GO
<% @roles.each do |r| -%>
sp_addrolemember [<%= r %>], [<%= @name %>]
<% end -%>
GO")

    exec { "role_${name}":
      path        => $::path,
      command     => "${sqlcmd} -Q \"${role_sql}\"",
      logoutput   => true,
      refreshonly => true,
      subscribe   => Exec["create_user_${name}"],
    }
  }

  if $debug {
    notify { "create_user_${name}":
      message => $create_sql,
    }
    notify { "role_${name}":
      message => $role_sql,
    }
  }
}
