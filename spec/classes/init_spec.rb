require 'spec_helper'

describe 'mssql' do
  context 'when installing from E: drive' do
    let(:params) {
      { :media => 'E:' }
    }
    it {
      should contain_user('SQLAGTSVC')
      should contain_user('SQLASSVC')
      should contain_user('SQLRSSVC')
      should contain_user('SQLSVC')
      should contain_file('C:\sql2008install.ini') \
        .with_content(/FTSVCACCOUNT=\"NT AUTHORITY\\LOCAL SERVICE\"\r\n\r\n\r\n$/)
      should contain_dism('NetFx3')
      should contain_exec('install_mssql2008').with({
        :command => /^E:\\setup.exe/,
      })
      should contain_service('SQLSERVERAGENT')
    }
  end

  context 'when specifying custom passwords' do
    let(:params) { {
      :agtsvcaccount  => 'agt',
      :agtsvcpassword => 'agt_pwd',
      :assvcaccount   => 'as',
      :assvcpassword  => 'as_pwd',
      :rssvcaccount   => 'rs',
      :rssvcpassword  => 'rs_pwd',
      :sqlsvcaccount  => 'sql',
      :sqlsvcpassword => 'sql_pwd',
    } }
    it {
      should contain_user('agt').with( :password => 'agt_pwd')
      should contain_user('as').with( :password => 'as_pwd')
      should contain_user('rs').with( :password => 'rs_pwd')
      should contain_user('sql').with( :password => 'sql_pwd')
      should contain_file('C:\sql2008install.ini') \
        .with_content(/AGTSVCACCOUNT=\"agt\"/)
    }
  end

  context 'when installing with sa password' do
    let(:params) {
      { :sapwd => 'hello_90s!' }
    }
    it {
      should contain_user('SQLAGTSVC')
      should contain_user('SQLASSVC')
      should contain_user('SQLRSSVC')
      should contain_user('SQLSVC')
      should contain_file('C:\sql2008install.ini') \
        .with_content(/SECURITYMODE=SQL\r\nSAPWD=hello_90s!\r\n\r\n$/)
      should contain_dism('NetFx3')
      should contain_exec('install_mssql2008').with({
        :command => /\/SECURITYMODE=SQL \/SAPWD=\"hello_90s!\"$/
      })
      should contain_service('SQLSERVERAGENT')
    }
  end

  context 'when only installing tools' do
    let(:params) {
      { :features => 'Tools' }
    }

    it {
      should_not contain_service('SQLSERVERAGENT')
    }
  end
end
