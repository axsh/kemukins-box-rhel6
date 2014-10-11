#!/bin/bash
#
# requires:
#  bash
#
set -e

declare chroot_dir=$1

function baseurl() {
  local releasever=${1}

  local baseurl=http://vault.centos.org

  case "${releasever}" in
    5.11 | 6.5 | 7.0.1406 )
      baseurl=http://ftp.riken.jp/Linux/centos
      ;;
    6.4 )
      baseurl=http://vault.centos.org.axsh.jp
      ;;
  esac

  echo ${baseurl}
}

if [[ -f ${chroot_dir}/etc/yum/vars/releasever ]]; then
  releasever=$(< ${chroot_dir}/etc/yum/vars/releasever)
  majorver=${releasever%%.*}

  mv ${chroot_dir}/etc/yum.repos.d/CentOS-Base.repo{,.saved}

  baseurl=$(baseurl ${releasever})

  cat <<-REPO > ${chroot_dir}/etc/yum.repos.d/CentOS-Base.repo
	[base]
	name=CentOS-\$releasever - Base
	baseurl=${baseurl}/\$releasever/os/\$basearch/
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${majorver}

	[updates]
	name=CentOS-\$releasever - Updates
	baseurl=${baseurl}/\$releasever/updates/\$basearch/
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${majorver}
	REPO
fi
