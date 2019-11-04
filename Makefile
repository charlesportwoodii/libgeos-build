SHELL := /bin/bash

VERSION?=3.8.0
RELEASEVER?=1
SCRIPTPATH=$(shell pwd -P)

major=$(shell echo $(VERSION) | cut -d. -f1)
minor=$(shell echo $(VERSION) | cut -d. -f2)

build: clean libgeos pre_package

clean:
	rm -rf /tmp/geos-install
	rm -rf /tmp/geos

libgeos:
	mkdir -p /tmp
	rm -rf /tmp/geos

	# Download and install geos
	cd /tmp && \
	git clone https://github.com/libgeos/geos --recursive -b $(VERSION) && \
	cd /tmp/geos && \
	./autogen.sh && \
	./configure && \
	make check

pre_package:
	cd /tmp/geos && make install DESTDIR=/tmp/geos-install
	mkdir -p /tmp/geos-install/usr/share/docs/libgeos
	cp /tmp/geos/COPYING /tmp/geos-install/usr/share/docs/libgeos/License

	mkdir -p /tmp/geos-install/etc/ld.so.conf.d/
	echo "/usr/local/lib/" > /tmp/geos-install/etc/ld.so.conf.d/geos.conf

fpm_debian:
	fpm -s dir \
		-t deb \
		-n libgeos$(major)$(minor) \
		-v $(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2) \
		-C /tmp/geos-install \
		-p libgeos$(major)$(minor)_$(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2)_$(shell arch).deb \
		-m "charlesportwoodii@erianna.com" \
		--license "GNU Lesser General Public License v2.1; https://github.com/libgeos/geos/blob/$(VERSION)/COPYING" \
		--url https://github.com/charlesportwoodii/libgeos-build \
		--description "Libgeos from https://github.com/libgeos/geos without modifications" \
		--force \
		--deb-systemd-restart-after-upgrade

fpm_rpm:
	fpm -s dir \
		-t rpm \
		-n libgeos$(major)$(minor) \
		-v $(VERSION)_$(RELEASEVER) \
		-C /tmp/geos-install \
		-p libgeos$(major)$(minor)_$(VERSION)-$(RELEASEVER)_$(shell arch).rpm \
		-m "charlesportwoodii@erianna.com" \
		--license "GNU Lesser General Public License v2.1; https://github.com/libgeos/geos/blob/$(VERSION)/COPYING" \
		--url https://github.com/charlesportwoodii/geos-build \
		--description "Libgeos from https://github.com/libgeos/geos without modifications" \
		--vendor "Charles R. Portwood II" \
		--force \
		--rpm-digest sha384 \
		--rpm-compression gzip

fpm_alpine:
	fpm -s dir \
		-t apk \
		-n libgeos$(major)$(minor) \
		-v $(VERSION)-$(RELEASEVER)~$(shell uname -m) \
		-C /tmp/geos-install \
		-p libgeos$(major)$(minor)-$(VERSION)-$(RELEASEVER)~$(shell uname -m).apk \
		-m "charlesportwoodii@erianna.com" \
		--license "GNU Lesser General Public License v2.1; https://github.com/libgeos/geos/blob/$(VERSION)/COPYING" \
		--url https://github.com/charlesportwoodii/libgeos-build \
		--description "Libgeos from https://github.com/libgeos/geos without modifications" \
		-a $(shell uname -m) \
		--force
