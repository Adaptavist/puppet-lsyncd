require 'spec_helper'

describe 'lsyncd', :type => 'class' do

  global_module    = { 'opt' => {
        'type'               => 'rsync',
        'source'             => '/opt',
        'target'             => 'localhost::opt-fast/',
        'init_sync'          => false,
        'rsync_verbose'      => true,
        'rsync_archive'      => true,
        'rsync_hard_links'   => true,
        'exclude_from'       => '/etc/lsyncd/rsync.exclusions' }
  }

  global_file_attributes =  {
        'ensure'      => 'present',
        'owner'       => 'root',
        'group'       => 'root',
        'content'     => 'this is the global level file'
  }

  global_file   = { '/tmp/testfile' => {}.merge(global_file_attributes) }

  host_merge_off      = { 'lsyncd::merge_modules' => false}

  host_merge_on      = { 'lsyncd::merge_modules' => true}

  host_module   = {'lsyncd::rsync_modules'   => { 'opt-slow' => {
        'type'               => 'rsync',
        'source'             => '/opt-slow',
        'target'             => 'localhost::opt-slow/',
        'init_sync'          => false,
        'rsync_verbose'      => true,
        'rsync_archive'      => true,
        'rsync_hard_links'   => true, }
        }
      }


  context "Should create config file soflink on RedHat systems" do

    let(:params) {
      { :rsync_modules    =>  global_module }
    }

    let(:facts) {{
      :osfamily     => 'RedHat',
      :operatingsystemrelease => '7.1'
     }}

    it do
      should contain_file('/etc/lsyncd.conf').with(
            'ensure'         => 'link',
            'target'         => '/etc/lsyncd/lsyncd.conf.lua'
      )
    end
  end


  context "Should not create config file soflink on non RedHat systems" do

    let(:params) {
      { :rsync_modules    =>  global_module }
    }

    let(:facts) {
     { :osfamily     => 'Debian' }
    }

    it do
      should_not contain_file('/etc/lsyncd.conf')
    end
  end

  context "Should create upstart job and softlink sysvinit script on Debian systems" do

    let(:params) {
      { :rsync_modules    =>  global_module,
        :use_upstart      =>  true
      }
    }

    let(:facts) {
     { :osfamily     => 'Debian' }
    }

    it do
      should contain_file('/etc/init/lsyncd.conf')
      should contain_file('/etc/init.d/lsyncd').with(
            'ensure'         => 'link',
            'target'         => '/lib/init/upstart-job'
      )
    end
  end

  context "Should not create upstart job and softlink sysvinit script on non Debian systems" do

    let(:params) {
      { :rsync_modules    =>  global_module,
        :use_upstart      =>  true
      }
    }

    let(:facts) {{ 
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7.1'
    }}

    it do
      should_not contain_file('/etc/init/lsyncd.conf')
      should_not contain_file('/etc/init.d/lsyncd').with(
            'ensure'         => 'link',
            'target'         => '/lib/init/upstart-job'
      )
    end
  end

  context "Should install packages_repos YUM repos on RedHat systems" do

    let(:params) {
      { :rsync_modules    =>  global_module }
    }

    let(:facts) {{ 
      :osfamily     => 'RedHat',
      :operatingsystemrelease => '7.1'
    }}

    it do
      should contain_class('packages_repos')
    end
  end

  context "Should not install packages_repos YUM repo on non RedHat systems" do

    let(:params) {
      { :rsync_modules    =>  global_module }
    }

    let(:facts) {{
      :osfamily     => 'Debian',
      :operatingsystemrelease => '14.0.1'
    }}

    it do
      should_not contain_class('packages_repos')
    end
  end

  context "Should create exclude file" do

    let(:params) {
      { :rsync_modules    =>  global_module,
        :create_files     =>  global_file
      }
    }

    it do
      should contain_file('/tmp/testfile').with(global_file_attributes)
    end
  end

  context "Should install lsyncd and create sync definition from global level config" do

    let(:params) {
      { :rsync_modules    =>  global_module }
    }

    it do
      should contain_package('lsyncd').with(
            'ensure'         => 'installed'
      )
      should contain_service('lsyncd').with(
            'ensure'         => 'running',
            'enable'         => 'true'
      )
      should contain_file('/etc/lsyncd').with(
            'ensure'         => 'directory'
      )
      should contain_file('/etc/lsyncd/lsyncd.conf.lua').with_content(/\s*localhost::opt-fast\s*/)
      should_not contain_file('/etc/lsyncd/lsyncd.conf.lua').with_content(/\s*localhost::opt-slow\s*/)
    end
  end

  context "Should install lsyncd and create sync definition from global and host level config" do

    let(:params) {
      { :rsync_modules    =>  global_module }
    }

    let(:facts) {
     { :host => host_module.merge(host_merge_on) }
    }

    it do
      should contain_package('lsyncd').with(
            'ensure'         => 'installed'
      )
      should contain_service('lsyncd').with(
            'ensure'         => 'running',
            'enable'         => 'true'
      )
      should contain_file('/etc/lsyncd').with(
            'ensure'         => 'directory'
      )
      should contain_file('/etc/lsyncd/lsyncd.conf.lua').with_content(/\s*localhost::opt-fast\s*/)
      should contain_file('/etc/lsyncd/lsyncd.conf.lua').with_content(/\s*localhost::opt-slow\s*/)
    end
  end

  context "Should install lsyncd and create sync definition from host level config as merging is disabled" do

    let(:params) {
      { :rsync_modules    =>  global_module }
    }

    let(:facts) {
     { :host => host_module.merge(host_merge_off) }
    }

    it do
      should contain_package('lsyncd').with(
            'ensure'         => 'installed'
      )
      should contain_service('lsyncd').with(
            'ensure'         => 'running',
            'enable'         => 'true'
      )
      should contain_file('/etc/lsyncd').with(
            'ensure'         => 'directory'
      )
      should contain_file('/etc/lsyncd/lsyncd.conf.lua').with_content(/\s*localhost::opt-slow\s*/)
    end
  end


  context "Should selinux booleans" do

    let(:params) {
      { :rsync_modules    =>  global_module }
    }

    let(:facts) {
      { :host => host_module.merge(host_merge_on),
        :selinux => 'true'}
    }

    it do
      should contain_selboolean('lsync_rsync_client').with(
                 'value'      => 'on',
                 'persistent' => true
             )
      should contain_selboolean('lsync_rsync_export_all_ro').with(
                 'value'      => 'on',
                 'persistent' => true
             )
      should contain_selboolean('lsync_allow_rsync_anon_write').with(
                 'value'      => 'on',
                 'persistent' => true
             )
    end
  end

 end
