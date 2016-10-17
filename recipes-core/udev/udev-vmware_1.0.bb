SUMMARY = "Extra VMWare specific configuration files"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

PR = "r0"

SRC_URI = "file://vmware-net.rules"

libexecdir = "${base_libdir}/udev"

do_install () {
    install -d ${D}${libexecdir}/rules.d
    install -m 0644 ${WORKDIR}/virtual-net.rules ${D}${libexecdir}/rules.d/79-virtual-net.rules
}

RDEPENDS_${PN} = "udev"
FILES_${PN} = "${libexecdir}/rules.d"
