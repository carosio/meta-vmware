FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
PRINC := "${@int(PRINC) + 6}"

SRC_URI += "file://vmware-net.rules"

libexecdir = "${base_libdir}/udev"

do_install_append () {
    install -d ${D}${libexecdir}/rules.d
    install -m 0644 ${WORKDIR}/vmware-net.rules ${D}${libexecdir}/rules.d/79-vmware-net.rules
}

FILES_${PN} += "${libexecdir}/rules.d"
