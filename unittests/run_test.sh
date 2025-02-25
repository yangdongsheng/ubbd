#!/bin/bash

unittest_dir=`pwd`

cd ${unittest_dir}/../

make ubbd_ut

cd ${unittest_dir}

valgrind --leak-check=full ./utils_test
if [ $? -ne 0 ]; then
	exit -1
fi

LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:../lib/:../libs3/build/lib/" valgrind --leak-check=full ./ubbd_uio_test
if [ $? -ne 0 ]; then
	exit -1
fi

rm -rf result
mkdir result
mv *gcda result/
mv *gcno result/


cd result
lcov --directory . --capture  --output-file info
genhtml ./info

