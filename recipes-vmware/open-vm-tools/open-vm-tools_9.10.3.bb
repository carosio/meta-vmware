DECRIPTION = "open-vmware-tools"
SECTION = "vmware-tools"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=5804fe91d3294da4ac47c02b454bbc8a"

PR = "r5"

SRC_URI = "http://sourceforge.net/projects/open-vm-tools/files/open-vm-tools/stable-9.4.x/open-vm-tools-9.4.6-1770165.tar.gz \
   file://patches/fix_kernel_include_patch.patch \
   file://patches/fix_distrofile.patch \
   file://patches/default_source.patch \
   file://patches/upstream/3a9f229_Harden-HostinfoOSData-against-PATH-attacks \
   file://patches/upstream/54780b8_Debian-guys-want-to-play-with-FreeBSD-kernels-and-Linux-userland \
   file://patches/from_fedora/sizeof_argument.patch \
   file://patches/from_arch/0001-Remove-unused-DEPRECATED-macro.patch \
   file://patches/from_arch/0002-Conditionally-define-g_info-macro.patch \
   file://patches/from_arch/0003-Add-kuid_t-kgid_t-compatibility-layer.patch \
   file://patches/from_arch/0004-Use-new-link-helpers.patch \
   file://patches/from_arch/0005-Update-hgfs-file-operations-for-newer-kernels.patch \
   file://patches/from_arch/0006-Fix-vmxnet-module-on-kernels-3.16.patch \
   file://patches/from_arch/0007-Fix-vmhgfs-module-on-kernels-3.16.patch \
   file://patches/from_arch/0008-Fix-segfault-in-vmhgfs.patch \
   file://patches/debian/max_nic_count \
   file://tools.conf \
   file://vmtoolsd.service"

SRC_URI[md5sum] = "3969daf1535d34e1c5f0c87a779b7642"
SRC_URI[sha256sum] = "54d7a83d8115124e4b809098b08d7017ba50828801c2f105cdadbc85a064a079"

S = "${WORKDIR}/open-vm-tools-9.4.6-1770165"

DEPENDS = "virtual/kernel glib-2.0 util-linux libdnet procps"
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

EXTRA_OECONF = "--without-icu --disable-multimon --disable-docs --disable-tests \
		--without-gtk2 --without-gtkmm \
		--with-linuxdir=${STAGING_KERNEL_DIR} --without-kernel-modules"

EXTRA_OECONF += "${@base_contains('DISTRO_FEATURES', 'pam', '', '--without-pam', d)} \
                 ${@base_contains('DISTRO_FEATURES', 'x11', '', '--without-x', d)}"

EXTRA_OEMAKE = "MODULES_DIR=/lib/modules/${KERNEL_VERSION}/kernel KERNEL_RELEASE=${KERNEL_VERSION}"

CFLAGS += '-Wno-error=deprecated-declarations'

FILES_${PN} += "/usr/lib/open-vm-tools/plugins/vmsvc/lib*.so \
		/usr/lib/open-vm-tools/plugins/common/lib*.so \
    ${sysconfdir}/vmware-tools/tools.conf"
FILES_${PN}-locale += "/usr/share/open-vm-tools/messages"
FILES_${PN}-dev += "/usr/lib/open-vm-tools/plugins/common/lib*.la"
FILES_${PN}-dbg += "/usr/lib/open-vm-tools/plugins/common/.debug \
		    /usr/lib/open-vm-tools/plugins/vmsvc/.debug"

CONFFILES_${PN} += "${sysconfdir}/vmware-tools/tools.conf"

do_install_append() {
    install -d ${D}${systemd_unitdir}/system ${D}${sysconfdir}/vmware-tools
    install -m 644 ${WORKDIR}/*.service ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/tools.conf ${D}${sysconfdir}/vmware-tools/tools.conf
}

do_configure_prepend() {
    export CUSTOM_PROCPS_NAME=procps
    export CUSTOM_PROCPS_LIBS=-L${STAGING_LIBDIR}/libprocps.so
}
