#!/bin/bash
set -e

replace_option()
{
	file=$1
	old=$2
	new=$3
	sed -i "s#${old}#${new}#" ${file}
}

./run_check.sh

git clone https://github.com/DataTravelGuide/ubbd-tests

git clone https://github.com/DataTravelGuide/ubbd-kernel

git clone https://github.com/kdave/xfstests


source /etc/os-release
case "$ID" in
debian|ubuntu|devuan|elementary|softiron)
	echo "ubuntu"
	env DEBIAN_FRONTEND=noninteractive apt install -y xfslibs-dev uuid-dev libtool-bin  e2fsprogs automake gcc libuuid1 quota attr make  libacl1-dev libaio-dev xfsprogs libgdbm-dev gawk fio dbench uuid-runtime
        ;;
rocky|centos|fedora|rhel|ol|virtuozzo)
	echo "centos"
	yum install acl attr automake bc dbench dump e2fsprogs fio gawk gcc indent libtool lvm2 make psmisc quota sed xfsdump xfsprogs libacl-devel libaio-devel libuuid-devel xfsprogs-devel btrfs-progs-devel python sqlite liburing-devel libcap-devel -y
        ;;
*)
        echo "$ID is unknown, dependencies will have to be installed manually."
        exit 1
        ;;
esac

UBBD_DIR=`pwd`
UBBD_TESTS_DIR="${UBBD_DIR}/ubbd-tests"
UBBD_KERNEL_DIR="${UBBD_DIR}/ubbd-kernel"
XFSTESTS_DIR="${UBBD_DIR}/xfstests"

cd ${XFSTESTS_DIR}
make

cd ${UBBD_TESTS_DIR}
mkdir test
mkdir scratch

cp local_conf.example local_conf

replace_option local_conf "UBBD_DIR=.*" "UBBD_DIR=\"${UBBD_DIR}\""
replace_option local_conf "UBBD_TESTS_DIR=.*" "UBBD_TESTS_DIR=\"${UBBD_TESTS_DIR}\""
replace_option local_conf "UBBD_KERNEL_DIR=.*" "UBBD_KERNEL_DIR=\"${UBBD_KERNEL_DIR}\""
replace_option local_conf "UBBD_TESTS_XFSTESTS_DIR=.*" "UBBD_TESTS_XFSTESTS_DIR=\"${XFSTESTS_DIR}\""
replace_option local_conf "XFSTESTS_SCRATCH_MNT=.*" "XFSTESTS_SCRATCH_MNT=\"${UBBD_TESTS_DIR}/scratch\""
replace_option local_conf "XFSTESTS_TEST_MNT=.*" "XFSTESTS_TEST_MNT=\"${UBBD_TESTS_DIR}/test\""
replace_option local_conf "FIOTEST_OUTFILE=.*" "FIOTEST_OUTFILE=\"fio_output.cvs\""

cat local_conf

./test_all.sh quick
