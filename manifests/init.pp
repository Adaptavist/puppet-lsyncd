#
# Installs and configures lsyncd, currently only rsync sync definitions are supported
#
# Parameters:
# -----------
#
# [*package_name*]
# The name of the lsyncd OS package.
# Default: 'lsyncd'
#
# [*service_name*]
# The name of the lsyncd service.
# Default: 'lsyncd'
#
# [*service_status*]
# The status puppert should leave the service.
# Default: 'running'
#
# [*service_ensure*]
# The enabled/disabled state of the service, true = enabled, false = disabled
# Default: true
#
# [*config_dir*]
# The location of the lsyncd configuration directory.
# Default: '/etc/lsyncd'
#
# [*config_file*]
# The name of the main lsyncd configuration file # (relative to $config_dir).
# Default: 'lsyncd.conf.lua'
#
# [*rh_config_file*]
# Default: '/etc/lsyncd.conf'
#
# [*status_file*]
# The location of lsync's status file, a status report is # periodically writen to this file.
# Default: '/tmp/lsyncd.status'
#
# [*max_processes*]
# The maximum number of processes that can be spawned.
# Default: 1
#
# [*log_ident*]
# The syslog identification tag used
# Default: 'lsyncd'
#
# [*log_facility*]
# The syslog facility used
# Default: 'user'
#
# [*use_upstart*]
# Flag to determine if a upstart job should be created and the existing sysvinit script removed
# and linked to an upstart job wrapper, then is only supported on Debian based systems, for any
# other systems it has no affect.
# Default: false
#
# [*create_files*]
# A hash of file objects to be created, for example sync exclude files can be created via this hash.
# Default: blank hash
#
# [*merge_modules*]
# Flag to determine if global and host level modules should be merged together.  If set to false
# host level modules are used and globals ignored, if however there are no hosts level modules then
# the globals are used.
# Default: true
#
# [*flush_config*]
# Flag to determine if the existing contents of the lsyncd configuration directory should be deleted,
# this ensures that only the configuration witin the hiera configuration is present on the system.
# Default: true
#
# [*rsync_modules*]
# A hash of modules that use rsync to do the actual syncing.
# Default: blank hash
#
# [*inotify_watches*]
# The number of inotify watches per user that should be set in the kernel.
# Default: undefined
#
# [*sysctl_config*]
# Default: '/etc/sysctl.conf'
# The location of the sysctl configuration file.
#
# [*sysctl_inotify_key*]
# The sysctl key used to control the number of inotify watchers per user.
# Default: fs.inotify.max_user_watches',
#
# [*insist_start*]
# Flag to determine if lsync should continue if it encounters errors at startup (such as the inability to do a full sync)
# Default: true
#
# [*max_delays*]
# The amount of files that can exist in the replication queue before a sync is forced, is the value is 1000 a sync will be forced once 
# 1001 items are in the queue, this overrides the sync delay option (defaulted to 15 seconds for rsync targets).
# Default: 1000
#
# [*systemd_template*]
# The location of the custom systemd unit file template to be used if the system is running systemd.  
# Default: 'puppet:///modules/lsyncd/systemd.service',
#
# [*systemd_unit_file*]
# The location on the filesystem of the custom systemd unit file 
# Default: '/etc/systemd/system/lsyncd.service',
#
# Hiera Examples:
# --------------
#
# Global Settings
#
#        lsyncd::use_upstart: true
#        lsyncd::inotify_watches: 40000
#        lsyncd::max_delays: 1500
#        lsyncd::rsync_modules:
#            'opt':
#                type: 'rsync'
#                source: '/opt'
#                target: 'localhost::opt/'
#                init_sync: false
#                rsync_verbose: true
#                rsync_archive: true
#                rsync_hard_links: true
#                exclude_from: '/etc/lsyncd/rsync.exclusions'
#                delay: 15
#                max_delays: 2000
#        lsyncd::create_files:
#            '/etc/lsyncd/rsync.exclusions':
#                ensure: present
#                owner: 'root'
#                group: 'root'
#                content: "temp/\nwork/\nlog/\nlogs/\nhome/index/\n"
#
# Global and Host Settings
#
#        lsyncd::use_upstart: true
#        lsyncd::inotify_watches: 40000
#        lsyncd::rsync_modules:
#            'opt':
#                type: 'rsync'
#                source: '/opt'
#                target: 'localhost::opt/'
#                init_sync: false
#                rsync_verbose: true
#                rsync_archive: true
#                rsync_hard_links: true
#                exclude_from: '/etc/lsyncd/rsync.exclusions'
#        lsyncd::create_files:
#            '/etc/lsyncd/rsync.exclusions':
#                ensure: present
#                owner: 'root'
#                group: 'root'
#                content: "temp/\nwork/\nlog/\nlogs/\nhome/index/\n"
#        hosts:
#            'host1':
#                lsyncd::use_upstart: false
#                lsyncd::merge_modules: false
#                lsyncd::inotify_watches: 120000
#                lsyncd::rsync_modules:
#                    'opt-slow':
#                        type: 'rsync'
#                        source: '/opt-slow'
#                        target: 'localhost::opt-slow/'
#                        init_sync: false
#                        rsync_verbose: 'true'
#                        rsync_archive: 'true'
#                        rsync_hard_links: 'true'
#

class lsyncd (
    $package_name        =    'lsyncd',
    $service_name        =    'lsyncd',
    $service_status      =    'running',
    $service_ensure      =    true,
    $config_dir          =    '/etc/lsyncd',
    $config_file         =    'lsyncd.conf.lua',
    $rh_config_file      =    '/etc/lsyncd.conf',
    $status_file         =    '/tmp/lsyncd.status',
    $max_processes       =     1,
    $log_ident           =     'lsyncd',
    $log_facility        =     'user',
    $use_upstart         =     false,
    $create_files        =     {},
    $merge_modules       =     true,
    $flush_config        =     true,
    $rsync_modules       =     {},
    $inotify_watches     =     undef,
    $sysctl_config       =     '/etc/sysctl.conf',
    $sysctl_inotify_key  =     'fs.inotify.max_user_watches',
    $insist_start        =     true,
    $max_delays          =     1000,
    $systemd_template    =     'puppet:///modules/lsyncd/systemd.service',
    $systemd_unit_file   =     '/etc/systemd/system/lsyncd.service',
    $use_custom_systemd  =     true,
    )  {

    #some config can be set at either global or host level, therefore check to see if the hosts hash exists
    if ($::host != undef) {
        #if so validate the hash
        validate_hash($::host)

        #if a host level "merge_modules" flag has been set use it, otherwise use the global flag
        $real_merge_modules = $host['lsyncd::merge_modules']? {
            default => $host['lsyncd::merge_modules'],
            undef => $merge_modules,
        }

        #if a host level "flush_config" flag has been set use it, otherwise use the global flag
        $real_flush_config = $host['lsyncd::flush_config']? {
            default => $host['lsyncd::flush_config'],
            undef => $flush_config,
        }

        #if a host level "inotify_watches" value has been set use it, otherwise use the global value
        $real_inotify_watches = $host['lsyncd::inotify_watches']? {
            default => $host['lsyncd::inotify_watches'],
            undef => $inotify_watches,
        }

        #if a host level "insist_start" value has been set use it, otherwise use the global value
        $real_insist_start = $host['lsyncd::insist_start']? {
            default => $host['lsyncd::insist_start'],
            undef => $insist_start,
        }

        #if there are host level lsync rsync modules
        if ($host['lsyncd::rsync_modules'] != undef) {
            #and we have merging enabled merge global and host
            if ($real_merge_modules) {
                $real_rsync_modules=merge($rsync_modules,$host['lsyncd::rsync_modules'])
            }
            #if however we have merging disabled, just use host values
            else {
                $real_rsync_modules=$host['lsyncd::rsync_modules']
            }
        }
        #if there are no host level rsync modules just use globals
        else {
            $real_rsync_modules=$rsync_modules
        }

        #if there are host level files to create
        if ($host['lsyncd::create_files'] != undef) {
            #and we have merging enabled merge global and host
            if ($real_merge_modules) {
                $real_create_files=merge($create_files,$host['lsyncd::create_files'])
            }
            #if however we have merging disabled, just use host values
            else {
                $real_create_files=$host['lsyncd::create_files']
            }
        }
        #if there are no host level files just use globals
        else {
            $real_create_files=$create_files
        }
    }
    #if there is no host has then use global values
    else {
        $real_rsync_modules=$rsync_modules
        $real_inotify_watches=$inotify_watches
        $real_flush_config=$flush_config
        $real_create_files=$create_files
        $real_insist_start=$insist_start
    }

    #install the package, if on a Red Hat based system ensure rpmforge repo is added (where lsync lives)
    case $::osfamily {
        'RedHat': {
            include packages_repos
            package { $package_name:
                ensure  => installed,
                require => Class['packages_repos'],
                before  => File[$config_dir],
            }
        }
        default: {
            package { $package_name:
                ensure => installed,
            }
        }
    }

    #if the number of inotify watchers per user is set make sure it
    if ($real_inotify_watches) {
        #set the value in sysctl.conf to ensure it survives a reboot
        augeas { "sysctl_config_${sysctl_inotify_key}":
            context => "/files${sysctl_config}",
            onlyif  => "get ${sysctl_inotify_key} != '${real_inotify_watches}'",
            changes => "set ${sysctl_inotify_key} '${real_inotify_watches}'",
            notify  => Exec['refresh_sysctl'],
        }

        #change the current value using the sysctl command line tool
        exec { 'refresh_sysctl':
            command => "sysctl -w ${sysctl_inotify_key}=${real_inotify_watches}",
            path    => '/usr/bin:/usr/sbin:/bin:/sbin',
        }

    }

    #if we are using upstart instead of sysvinit create upstart config (only supported on Debian systems)
    if ($use_upstart) and ($::osfamily == 'Debian') {
        file { '/etc/init/lsyncd.conf':
            source => 'puppet:///modules/lsyncd/lsyncd.conf',
            owner  => 'root',
            group  => 'root',
            before => Service[$service_name],
        }

        #remove sysvinit scrtipt and replace with a softlink to the upstart job
        file { '/etc/init.d/lsyncd':
            ensure => 'link',
            target => '/lib/init/upstart-job',
            before => Service[$service_name],
        }
    }

    # if this is CentOS/RHEL >= 7 deploy our custom unit file, the one provided does not auto restart!
    if ($::osfamily == 'RedHat') and (versioncmp($::operatingsystemrelease,'7') >= 0 and $::operatingsystem != 'Fedora') and (str2bool($use_custom_systemd)) {
        file { $systemd_unit_file:
            source  => $systemd_template,
            owner   => 'root',
            group   => 'root',
            before  => Service[$service_name],
            require => Package[$package_name],
            notify  => Exec['reload-systemd'],
        }

        exec { 'reload-systemd':
            command     => 'systemctl daemon-reload',
            refreshonly => true,
        }
    }

    #in order to ensure ONLY the elements specified in hiera are present remove existing files from the config directory
    if ($real_flush_config) {
        #then remove the config files
        exec { 'del lsync configs':
            command => "rm -f ${config_dir}/*",
            path    => '/usr/bin:/usr/sbin:/bin',
            onlyif  => "test -d ${config_dir}",
            before  => File[$config_dir],
        }
    }

    #create any required files, such as rsync exclude files..
    if ($real_create_files) {
        #if so validate the hash
        class { 'lsyncd::create_lsyncd_config_files':
            config_files => $real_create_files,
            before       => File["${config_dir}/${config_file}"],
            require      => File[$config_dir]
        }
    }

    #make sure lsync config dir exists
    file {$config_dir:
        ensure => directory,
        before => File["${config_dir}/${config_file}"]
    }

    service {
        $service_name:
            ensure => $service_status,
            enable => str2bool($service_ensure),
    }

    #if on a Red Hat based system create a softlink  for the config file
    if ( $::osfamily == 'RedHat' ) {
        file { "${config_dir}/${config_file}":
            content => template('lsyncd/lsyncd.conf.lua.erb'),
            owner   => 'root',
            group   => 'root',
            before  => Service[$service_name],
        }

        file { $rh_config_file:
            ensure  => 'link',
            target  => "${config_dir}/${config_file}",
            before  => Service[$service_name],
            require => File["${config_dir}/${config_file}"],
            notify  => Service[$service_name],
        }
    } else {
        file { "${config_dir}/${config_file}":
            content => template('lsyncd/lsyncd.conf.lua.erb'),
            owner   => 'root',
            group   => 'root',
            before  => Service[$service_name],
            notify  => Service[$service_name],
        }
    }
    if str2bool($::selinux) {
        selboolean { 'lsync_rsync_client':
            name       => 'rsync_client',
            persistent => true,
            value      => 'on',
        }
        selboolean { 'lsync_rsync_export_all_ro':
            name       => 'rsync_export_all_ro',
            persistent => true,
            value      => 'on',
        }
        selboolean { 'lsync_allow_rsync_anon_write':
            name       => 'allow_rsync_anon_write',
            persistent => true,
            value      => 'on',
        }
    }
}
