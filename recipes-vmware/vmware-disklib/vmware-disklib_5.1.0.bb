DESCRIPTION = "The Virtual Disk Development Kit (VDDK) is a collection of C/C++ libraries, code samples, utilities, and documentation to help you create and access VMware virtual disk storage. The VDDK is useful in conjunction with the vSphere API for writing backup and recovery software, or similar applications."
HOMEPAGE = "http://www.vmware.com/support/developer/vddk/"
LICENSE = "CLOSED"
SECTION = "net"
DEPENDS = " perl-native "
PR = "r0"

SRC_URI = "file://VMware-vix-disklib-5.1.0-774844.x86_64.tar.gz"

S = "${WORKDIR}/vmware-vix-disklib-distrib"

inherit native

do_install() {
	install -d -m755 ${D}${bindir} \
		   	 ${D}${libdir}/vmware
	cp -a ${S}/bin64/* ${D}${bindir}
	cp -a ${S}/lib64/* ${D}${libdir}/vmware
}
