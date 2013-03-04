require 'spec_helper'

describe 'mssql::db' do
  let(:title) { 'demo' }

  context 'with no db settings' do
    it {
      should contain_exec('create_db_demo').with({
        'command' => /CREATE DATABASE \[demo\]\n/
      })
      should_not contain_exec('alter_demo')
    }
  end

  context 'with mdf/ldf files' do
    let(:params) { {
      :mdf_file => 'C:\database\demo.mdf',
      :ldf_file => 'C:\database\demo.ldf',
    } }

    it {
      should contain_exec('create_db_demo').with({
        'command' => /CREATE DATABASE \[demo\]\nON PRIMARY\n\(NAME = N'demo', FILENAME = N'C\:\\database\\demo.mdf'/
      })
      should_not contain_exec('alter_demo')
    }
  end

  context 'with settings' do
    let(:params) { {
      :settings => ['SET ALLOW_SNAPSHOT_ISOLATION ON'],
    } }

    it {
      should contain_exec('alter_demo').with({
        'command' => /ALTER DATABASE \[demo\] SET ALLOW_SNAPSHOT_ISOLATION ON;\n/,
      })
    }

  end

  context 'with invalid settings' do
    let(:params) { {
      :settings => 'SET ALLOW_SNAPSHOT_ISOLATION ON',
    } }

    it {
      expect{
        should contain_exec('alter_demo')
      }.to raise_error(Puppet::Error, /is not an Array/)
    }
  end
end
