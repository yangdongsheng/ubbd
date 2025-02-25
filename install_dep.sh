#!/bin/bash

source /etc/os-release
case "$ID" in
debian|ubuntu|devuan|elementary|softiron)
	echo "ubuntu"
	env DEBIAN_FRONTEND=noninteractive apt install -y librbd-dev libc-dev libnl-3-dev libnl-genl-3-dev libcmocka-dev valgrind lcov cmake pkg-config libcurl4-openssl-dev libxml2-dev libssl-dev libssh-dev debhelper dpkg-dev
        ;;
rocky|centos|fedora|rhel|ol|virtuozzo)
	echo "centos"
	yum install librbd-devel glibc-devel libnl3-devel libssh-devel libcurl-devel libxml2-devel  make gcc openssl-devel kernel-devel elfutils-libelf-devel rpm-build -y
        ;;
*)
        echo "$ID is unknown, dependencies will have to be installed manually."
        exit 1
        ;;
esac
