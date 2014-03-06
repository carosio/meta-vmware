DECRIPTION = "open-vmware-tools"
SECTION = "vmware-tools"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=5804fe91d3294da4ac47c02b454bbc8a"

<<<<<<< HEAD:recipes-vmware/open-vmware-tools/open-vmware-tools_9.2.3.bb
PR = "r15"
=======
PR = "r14"
>>>>>>> master:recipes-vmware/open-vmware-tools/open-vmware-tools_9.2.3.bb

SRC_URI = "http://downloads.sourceforge.net/project/open-vm-tools/open-vm-tools/stable-9.2.x/open-vm-tools-9.2.3-1031360.tar.gz \
   file://path_vmtools.patch;apply=yes \
   file://fix_kernel_include_patch.patch;apply=yes \
   file://tools.conf \ 
   file://fix_distrofile.patch;apply=yes \
   file://vmtoolsd.service"

SRC_URI[md5sum] = "71a1d8065b632692af2cdcc9d82f305e"
SRC_URI[sha256sum] = "1a004ea1675101fd44cddda299e2e9ac254388769b69f41b7ff5d1797549c8f1"

S = "${WORKDIR}/open-vm-tools-9.2.3-1031360"

<<<<<<< HEAD:recipes-vmware/open-vmware-tools/open-vmware-tools_9.2.3.bb
DEPENDS = "virtual/kernel glib-2.0 util-linux gcc libdnet procps fuse"
=======
DEPENDS = "virtual/kernel glib-2.0 util-linux gcc libdnet rsyslog procps fuse cunit"
>>>>>>> master:recipes-vmware/open-vmware-tools/open-vmware-tools_9.2.3.bb
RDEPENDS_${PN} = "util-linux libdnet"

inherit module-base kernel-module-split autotools systemd

# from module.bbclass...
addtask make_scripts after do_patch before do_compile
do_make_scripts[lockfiles] = "${TMPDIR}/kernel-scripts.lock"
do_make_scripts[deptask] = "do_populate_sysroot"

# add all splitted modules to PN RDEPENDS, PN can be empty now
KERNEL_MODULES_META_PACKAGE = "${PN}"
#

SYSTEMD_SERVICE_${PN} = "vmtoolsd.service"

<<<<<<< HEAD:recipes-vmware/open-vmware-tools/open-vmware-tools_9.2.3.bb
EXTRA_OECONF = "--without-icu --disable-multimon --disable-docs --disable-tests \
=======
EXTRA_OECONF = "--without-icu --disable-multimon --disable-docs disable-tests \
>>>>>>> master:recipes-vmware/open-vmware-tools/open-vmware-tools_9.2.3.bb
		--without-gtk2 --without-gtkmm \
		--with-linuxdir=${STAGING_KERNEL_DIR} "

EXTRA_OECONF += "${@base_contains('DISTRO_FEATURES', 'pam', '', '--without-pam', d)} \
                 ${@base_contains('DISTRO_FEATURES', 'x11', '', '--without-x', d)}"

EXTRA_OEMAKE = "MODULES_DIR=/lib/modules/${KERNEL_VERSION}/kernel"

CFLAGS += '-Wno-error=deprecated-declarations'

FILES_${PN} += "/usr/lib/open-vm-tools/plugins/vmsvc/lib*.so \
		/usr/lib/open-vm-tools/plugins/common/lib*.so \
    ${sysconfdir}/vmware-tools/tools.conf"
FILES_${PN}-locale += "/usr/share/open-vm-tools/messages"
FILES_${PN}-dev += "/usr/lib/open-vm-tools/plugins/common/lib*.la"
FILES_${PN}-dbg += "/usr/lib/open-vm-tools/plugins/common/.debug \
		    /usr/lib/open-vm-tools/plugins/vmsvc/.debug"

do_install_append() {
    install -d ${D}${systemd_unitdir}/system ${D}${sysconfdir}/vmware-tools
    install -m 644 ${WORKDIR}/*.service ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/tools.conf ${D}${sysconfdir}/vmware-tools/tools.conf
}

do_configure_prepend() {
    export CUSTOM_PROCPS_NAME=procps
    export CUSTOM_PROCPS_LIBS=-L${STAGING_LIBDIR}/libprocps.so
}
