KERNEL_SOURCE_VERSION ?= $(shell uname -r)
KERNEL_TREE ?= /lib/modules/$(KERNEL_SOURCE_VERSION)/build
EXTRA_CFLAGS += $(call cc-option,-Wno-tautological-compare) -Wall -Wmaybe-uninitialized -Werror
LDLIBS_CMOCKA = -lcmocka -lcurl -lcrypto -lxml2 -lnl-3 -lnl-genl-3 -lrbd -lrados -lpthread -lm -lz -lssh -ls3-ubbd
CMOCKA_CFLAGS := --coverage
CMOCKA_CALLOC_CFLAGS := -Wl,--wrap=calloc -Wl,--wrap=free
CMOCKA_OPEN_CFLAGS := -Wl,--wrap,open -Wl,--wrap,close -Wl,--wrap,mmap -Wl,--wrap,munmap -Wl,--wrap,read -Wl,--wrap,write -Wl,--wrap,asprintf
SOURCES := $(shell find ../lib/ -name '*.c')
SOURCES += $(shell find ../src/ -name '*.c')

all:
	$(CC) $(EXTRA_CFLAGS) $(CMOCKA_CFLAGS) $(CMOCKA_CALLOC_CFLAGS) -g  utils_test.c $(UBBD_FLAGS) $(LDLIBS_CMOCKA) -o utils_test
	$(CC) $(EXTRA_CFLAGS) $(CMOCKA_CFLAGS) $(CMOCKA_OPEN_CFLAGS) -g ubbd_uio_test.c $(SOURCES) $(UBBD_FLAGS) $(LDLIBS_CMOCKA) -o ubbd_uio_test

clean:
	rm -rf utils_test
	rm -rf ubbd_uio_test
	rm -rf *.gcno *.gcda
