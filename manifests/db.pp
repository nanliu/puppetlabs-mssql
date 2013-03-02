# Manages Micrsoft SQL databases
define mssql::db (
  $sqlcmd     = '"C:\Program Files\Microsoft SQL Server\100\Tools\Binn\sqlcmd.exe"',
  $mdf_file   = undef,
  $mdf_size   = '100MB',
  $mdf_growth = '10%',
  $ldf_file   = undef,
  $ldf_size   = '10MB',
  $ldf_growth = '10%',
  $collate    = 'Latin1_General_CS_AS',
  # settings are configure on database creation and not enforced subsequently:
  $settings   = undef,
  $debug      = false,
) {
  require 'mssql'


  $create_sql = inline_template("
USE [master]
CREATE DATABASE [<%= @name %>]
<% if @mdf_file -%>
ON PRIMARY
(NAME = N'<%= @name %>', FILENAME = N'<%= @mdf_file %>', SIZE = <%= @mdf_size %>, FILEGROWTH = <%= @mdf_growth %> )
<% end -%>
<% if @ldf_file -%>
LOG ON
(NAME = N'<%= @name %>_log', FILENAME = N'<%= @ldf_file %>', SIZE = <%= @ldf_size %>, FILEGROWTH = <%= @ldf_growth %> )
<% end -%>
COLLATE <%= @collate %>
GO")

  exec { "create_db_${name}":
    path      => $::path,
    command   => "${sqlcmd} -Q \"${create_sql}\"",
    unless    => "${sqlcmd} -Q \"exit(if exists(select * from master.sys.databases where name='${name}') select 0 else select 1)\"",
    logoutput => true,
  }

  if $settings {
    validate_array($settings)

    $alter_sql = inline_template("
USE [<%= @name %>]
<% @settings.each do |l| -%>
ALTER DATABASE [<%= @name %>] <%= l %>;
<% end -%>
GO")

    exec { "alter_${name}":
      path        => $::path,
      command     => "${sqlcmd} -Q \"${alter_sql}\"",
      logoutput   => true,
      refreshonly => true,
      subscribe   => Exec["create_db_${name}"],
    }
  }

  if $debug {
    notify { "create_db_${name}":
      message => $create_sql,
    }
    notify { "alter_${name}":
      message => $alter_sql,
    }
  }
}
