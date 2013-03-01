class { 'mssql':
  features => 'SQL,CONN,SSMS,ADV_SSMS',
}

file { "C:\database":
  ensure => 'directory',
}

mssql::db { 'demo':
  mdf_file => 'C:\database\demo.mdf',
  ldf_file => 'C:\database\demo.ldf',
  settings => [
    "SET SINGLE_USER WITH ROLLBACK IMMEDIATE",
    "SET ALLOW_SNAPSHOT_ISOLATION ON",
    "SET READ_COMMITTED_SNAPSHOT ON WITH NO_WAIT",
    "SET MULTI_USER",
  ],
  require  => File['C:\database'],
}
