class mssql (
  # See http://msdn.microsoft.com/en-us/library/ms144259.aspx
  $media          = 'D:\\',
  $instancename   = 'MSSQLSERVER',
  $features       = 'SQL,AS,RS,IS',
  $agtsvcaccount  = 'SQLAGTSVC',
  $agtsvcpassword = 'Sql!agt#2008demo',
  $assvcaccount   = 'SQLASSVC',
  $assvcpassword  = 'Sql!as#2008demo',
  $rssvcaccount   = 'SQLRSSVC',
  $rssvcpassword  = 'Sql!rs#2008demo',
  $sqlsvcaccount  = 'SQLSVC',
  $sqlsvcpassword = 'Sql!#2008demo',
  $instancedir    = "C:\\Program Files\\Microsoft SQL Server",
  $ascollation    = 'Latin1_General_CI_AS',
  $sqlcollation   = 'SQL_Latin1_General_CP1_CI_AS',
  $admin          = 'Administrator',
  $sapwd          = undef
) {

  User {
    ensure   => present,
    before => Exec['install_mssql2008'],
  }

  user { 'SQLAGTSVC':
    comment  => 'SQL 2008 Agent Service.',
    password => $agtsvcpassword,
  }
  user { 'SQLASSVC':
    comment  => 'SQL 2008 Analysis Service.',
    password => $assvcpassword,
  }
  user { 'SQLRSSVC':
    comment  => 'SQL 2008 Report Service.',
    password => $rssvcpassword,
  }
  user { 'SQLSVC':
    comment  => 'SQL 2008 Service.',
    groups   => 'Administrators',
    password => $sqlsvcpassword,
  }

  file { 'C:\sql2008install.ini':
    content => template('mssql/config.ini.erb'),
    backup  => false,
  }

  dism { 'NetFx3':
    ensure => present,
  }

  if $sapwd {
    $install_cmd = "${media}\\setup.exe /Action=Install /IACCEPTSQLSERVERLICENSETERMS /QS /CONFIGURATIONFILE=C:\\sql2008install.ini /SQLSVCPASSWORD=\"${sqlsvcpassword}\" /AGTSVCPASSWORD=\"${agtsvcpassword}\" /ASSVCPASSWORD=\"${assvcpassword}\" /RSSVCPASSWORD=\"${rssvcpassword}\" /SECURITYMODE=SQL /SAPWD=\"$sapwd\""
  } else {
    $install_cmd = "${media}\\setup.exe /Action=Install /IACCEPTSQLSERVERLICENSETERMS /QS /CONFIGURATIONFILE=C:\\sql2008install.ini /SQLSVCPASSWORD=\"${sqlsvcpassword}\" /AGTSVCPASSWORD=\"${agtsvcpassword}\" /ASSVCPASSWORD=\"${assvcpassword}\" /RSSVCPASSWORD=\"${rssvcpassword}\""
  }

  # We should be able to switch to package resource in 3.0.x:
  # http://projects.puppetlabs.com/issues/11870
  exec { 'install_mssql2008':
    command   => $install_cmd,
    cwd       => $media,
    path      => $media,
    logoutput => true,
    creates   => $instancedir,
    timeout   => 1200,
    require   => [ File['C:\sql2008install.ini'],
                   Dism['NetFx3'] ],
  }

  if 'SQL' in $features {
    service { 'SQLSERVERAGENT':
      ensure  => running,
      enable  => true,
      require => Exec['install_mssql2008'],
    }
  }
}
