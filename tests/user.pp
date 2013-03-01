# Need mssql::db, this is just an example:
mssql::user { 'demo':
  password         => 'demo2pass!',
  default_database => 'demo',
  roles            => ['db_owner'],
}
