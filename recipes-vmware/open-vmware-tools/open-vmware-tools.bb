DECRIPTION = "open-vmware-tools"
SECTION = "vmware-tools"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=5804fe91d3294da4ac47c02b454bbc8a"

PR = "r11"

SRC_URI = "http://downloads.sourceforge.net/project/open-vm-tools/open-vm-tools/stable-9.2.x/open-vm-tools-9.2.2-893683.tar.gz \
   file://path_vmtools.patch;apply=yes \
   file://vmtoolsd.service"

SRC_URI[md5sum] = "7af505681d736d4c9ee6493b1166689f"
SRC_URI[sha256sum] = "1ae795e75bf4b38185f39083b8075686d3bab4c1222f4e39c863aeccb2f5f387"

S = "${WORKDIR}/open-vm-tools-9.2.2-893683"

DEPENDS_append = " glib-2.0 util-linux gcc " 
RDEPENDS_${PN}_append = " util-linux gcc " 

inherit autotools systemd

SYSTEMD_SERVICE_${PN} = "vmtoolsd.service"

EXTRA_OECONF = "--without-procps --disable-multimon --disable-docs disable-tests \
		--without-gtk2 --without-gtkmm --without-icu "

EXTRA_OECONF += "${@base_contains('DISTRO_FEATURES', 'pam', '', '--without-pam', d)} \
                 ${@base_contains('DISTRO_FEATURES', 'x11', '', '--without-x', d)} \
                 ${@base_contains('DISTRO_FEATURES', 'dnet', '', '--without-dnet', d)}"

CFLAGS += '-Wno-error=deprecated-declarations'

FILES_${PN} += " /lib/modules/*/kernel/ \
		/usr/share/open-vm-tools/ \
		/usr/lib/open-vm-tools/plugins/vmsvc/lib* \
		/usr/lib/open-vm-tools/plugins/common/lib* "

do_install_append() {
    install -d ${D}${systemd_unitdir}/system

    install -m 644 ${WORKDIR}/*.service ${D}/${systemd_unitdir}/system
}
