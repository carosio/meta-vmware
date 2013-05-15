DESCRIPTION = "The  is a collection of C/C++ libraries, code samples, utilities, and documentation to help you create and access VMware virtual disk storage. The VDDK is useful in conjunction with the vSphere API for writing backup and recovery software, or similar applications."
HOMEPAGE = "http://www.vmware.com/support/developer/vddk/"
LICENSE = "CLOSED"
SECTION = "net"
DEPENDS = " perl-native "
PR = "r0"

SRC_URI = "file://VMware-Ovftool-3.0.1-x86_64.tar.gz"


S = "${WORKDIR}/vmware-ovftool"

inherit native

do_install() {
	install -d -m755 ${D}${bindir} \ 
                   ${D}${libdir}/vmware-ovftool

  cp -a ${S}/*  ${D}${libdir}/vmware-ovftool
  ln -s ${D}${libdir}/vmware-ovftool/ovftool ${D}${bindir}/ovftool
}
