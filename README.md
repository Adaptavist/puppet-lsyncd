# lsyncd Module

## Overview

The **lsyncd** module installs and configures lsyncd, currently only rsync sync definitions are supported

## Main Configuration

###`package_name`

The name of the lsyncd package **Default: lsyncd** 

####`service_name`

The name of the lsyncd service **Default: lsyncd** 

####`config_dir`

The directory where lsyncd configuration files will be stored.  **Default: /etc/lsyncd**

###`config_file`

The main lsyncd configuration file.  **Default: lsyncd.conf.lua**

###`rh_config_file`

The main confiuration file on Red Hat based systems.  **Default: /etc/lsyncd.conf*
####`use_upstart`

Flag to determine if the lsync service should be managed by upstart.  **Default: false**

####`merge_modules`

Flag to determine if global and host level modules and files should be merged together.  If set to false host level values are used and globals ignored, if however there are no hosts level values then the globals are used. **Default: true** (this option can be overwritten by a host level entry)

####`rsync_modules`

A hash of modules that use rsync to do the actual syncing. **Default: empty hash** (this option can be overwritten/added to by a host level entry)

####`flush_config`

Flag to determine if the existing contents of the lsyncd configuration directory should be deleted, this ensures that only the configuration witin the hiera configuration is present on the system.  **Default: true** (this option can be overwritten by a host level entry)

####`status_file`

The location of lsync's status file, a status report is periodically writen to this file **Default: /tmp/lsyncd.status**

####`max_processes`

Maximum number of processes that can be spawned. **Default: 1**

####`log_ident`

The syslog identification tag **Default: lsyncd**

####`log_facility`

The syslog facility **Default: user**

####`use_upstart`

Flag to determine if a upstart job should be created and the existing sysvinit script removed and linked to an upstart job wrapper, then is only supported on Debian based systems, for any other systems it has no affect. **Default: false**

####`create_files`

A hash of file objects to be created, for example ***exclude_from*** files can be created  **Default: empty hash** (this option can be overwritten/added to by a host level entry)

###`inotify_watches`

The number of inotify watches per user that should be set in the kernel.  if set the running kerenl parameter (set in ***sysctl_inotify_key***) will be changed and a entry added to sysctl.conf to ensure the value survives a reboot, if no value is set then notthing is changed,   **Default: no value** (this option can be overwritten by a host level entry)

###`sysctl_config`

The location of the sysctl configuration file, this is only  used if ***inotify_watches*** is set.  **Default: /etc/sysctl.conf**

###`sysctl_inotify_key`

The sysctl key used to control the number of inotify watchers per user.  **Default: fs.inotify.max_user_watches**

###`insist_start`

Flag to determine if lsync should continue if it encounters errors at startup (such as the inability to do a full sync). **Default: true**

###`max_delays`

The amount of files that can exist in the replication queue before a sync is forced, is the value is 1000 a sync will be forced once 1001 items are 
in the queue, this overrides the sync delay option (defaulted to 15 seconds for rsync targets). **Default: 1000**

##Sync Configuration

The following comfiguration parameters are used to configure a lsync sync definition, currently this module only supports rsync based sync definitions! 
###Rsync sync 

###`source` 

The source location for the sync, can either be a local dir/file or a remote rsync location

###`target` 

The target location for the sync can either be a local dir/file or a remote rsync location

###`init_sync`  

Flag to determine if the target and source locations should have an initial sync performed

###`rsync_binary`

The path to the rsync binary

###`rsync_verbose`

Flag to tell rsync to run in verbose mode

###`rsync_compress`

Flag to determine if rsync should use compression

###`rsync_archive`

Flag to determine if rsync should run in archive mode.

###`rsync_hard_links`

Flag to determine if hard links should be maintained on the destination, true means they will and false means they will created as regular files.

###`exclude_from`

The location of a file that contains a list of items that are to be excluded from the sync, these files can be created via the ***create_files*** global hash.

###`delay`

The delay in seconds that lsync will wait until running a sync once items exist in the replication queue, if no value is set lsync defaults to 15 seconds for rsync targets

###`max_delays`

The amount of files that can exist in the replication queue before a sync is forced, is the value is 1000 a sync will be forced once 1001 items are 
in the queue, this overrides the sync delay option (defaulted to 15 seconds for rsync). If set in the `sync` section this value overides the global
maxDelays option for this particular sync

**The "rsync" options avaliable in this module are only a handfull of those supported, for a complete list visit https://github.com/axkibe/lsyncd/wiki/Lsyncd%202.1.x%20%E2%80%96%20Layer%204%20Config%20%E2%80%96%20Default%20Behavior**
  
  
##Hiera Examples:

* Global Settings

        lsyncd::use_upstart: true
        lsyncd::inotify_watches: 40000
        lsyncd::insist_start: true
        lsyncd::max_delays: 1500
        lsyncd::rsync_modules:
            'opt':
                type: 'rsync'
                source: '/opt'
                target: 'localhost::opt/'
                init_sync: false
                rsync_verbose: true
                rsync_archive: true
                rsync_hard_links: true
                exclude_from: '/etc/lsyncd/rsync.exclusions'
                delay: 15
                max_delays: 2000
        lsyncd::create_files:
            '/etc/lsyncd/rsync.exclusions':
                ensure: present
                owner: 'root'
                group: 'root'
                content: "temp/\nwork/\nlog/\nlogs/\nhome/index/\n"

* Global and Host Settings

        lsyncd::use_upstart: true
        lsyncd::inotify_watches: 40000
        lsyncd::insist_start: true
        lsyncd::rsync_modules:
            'opt':
                type: 'rsync'
                source: '/opt'
                target: 'localhost::opt/'
                init_sync: false
                rsync_verbose: true
                rsync_archive: true
                rsync_hard_links: true
                exclude_from: '/etc/lsyncd/rsync.exclusions'
        lsyncd::create_files:
            '/etc/lsyncd/rsync.exclusions':
                ensure: present
                owner: 'root'
                group: 'root'
                content: "temp/\nwork/\nlog/\nlogs/\nhome/index/\n"
        hosts:
            'host1':
                lsyncd::use_upstart: false
                lsyncd::merge_modules: false
                lsyncd::insist_start: false
                lsyncd::inotify_watches: 120000
                lsyncd::rsync_modules:
                    'opt-slow':
                        type: 'rsync'
                        source: '/opt-slow'
                        target: 'localhost::opt-slow/'
                        init_sync: false
                        rsync_verbose: 'true'
                        rsync_archive: 'true'
                        rsync_hard_links: 'true'

## Dependencies

This module depends on the Adaptavist "packages_repos" module **ONLY** if the operating system is **Red Hat** based, otherwise if has no dependencies.
