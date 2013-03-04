require 'spec_helper'

describe 'mssql::user' do
  let(:title) { 'demo' }

  context 'with no user role' do
    let(:params) { {
      :password => 'just_me',
      :default_database => 'example',
    } }

    it {
      should contain_exec('create_user_demo').with({
        'command' => /CREATE LOGIN \[demo\] WITH PASSWORD = N'just_me'/
      })
      should_not contain_exec('role_demo')
    }
  end

  context 'with user role' do
    let(:params) { {
      :password => 'just_me',
      :default_database => 'example',
      :roles => ['db_owner'],
    } }

    it {
      should contain_exec('role_demo').with({
        'command' => /sp_addrolemember \[db_owner\], \[demo\]\n/
      })
    }

  end

  context 'with invalid user role' do
    let(:params) { {
      :password => 'just_me',
      :default_database => 'example',
      :roles => 'bad_role',
    } }

    it {
      expect{
        should contain_exec('role_demo')
      }.to raise_error(Puppet::Error, /is not an Array/)
    }
  end
end
