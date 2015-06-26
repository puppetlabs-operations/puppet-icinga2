class icinga2::server::repos inherits icinga2::server {

  include icinga2::server

  if $manage_repos == true {
    case $::operatingsystem {
      #CentOS or RedHat systems:
      'CentOS', 'RedHat': {
        #Add the official Icinga Yum repository: http://packages.icinga.org/epel/
        yumrepo { 'icinga2_yum_repo':
          baseurl  => "http://packages.icinga.org/epel/${::operatingsystemmajrelease}/release/",
          descr    => 'Icinga 2 Yum repository',
          enabled  => 1,
          gpgcheck => 1,
          gpgkey   => 'http://packages.icinga.org/icinga.key'
        }
      }

     #Ubuntu systems:
     'Ubuntu': {
        #Include the apt module's base class so we can...
        include apt
        #...use the apt module to add the Icinga 2 PPA from launchpad.net:
        # https://launchpad.net/~formorer/+archive/ubuntu/icinga
        apt::ppa { 'ppa:formorer/icinga': }
      }

      #Debian systems:
      'Debian': {
        include apt

        #On Debian (7) icinga2 packages are on backports
        if $use_debmon_repo == false {
          include apt::backports
        } else {
          apt::source { 'debmon':
            location    => 'http://debmon.org/debmon',
            release     => "debmon-${lsbdistcodename}",
            repos       => 'main',
            key_source  => 'http://debmon.org/debmon/repo.key',
            key         => '29D662D2',
            include_src => false,
            # backports repo use 200
            pin         => '300'
          }
        }
      }

      #Fail if we're on any other OS:
      default: { fail("${::operatingsystem} is not supported!") }
    }
  }

}


