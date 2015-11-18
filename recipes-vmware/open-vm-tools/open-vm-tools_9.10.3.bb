DECRIPTION = "open-vmware-tools"
SECTION = "vmware-tools"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=5804fe91d3294da4ac47c02b454bbc8a"

PR = "r1"

SRC_URI = "https://github.com/vmware/open-vm-tools/archive/stable-${PV}.tar.gz"

# SRC_URI += "file://patches/fix_kernel_include_patch.patch"
# SRC_URI += "file://patches/fix_distrofile.patch"
# SRC_URI += "file://patches/default_source.patch"
# SRC_URI += "file://patches/upstream/3a9f229_Harden-HostinfoOSData-against-PATH-attacks"
# SRC_URI += "file://patches/upstream/54780b8_Debian-guys-want-to-play-with-FreeBSD-kernels-and-Linux-userland"
# SRC_URI += "file://patches/from_fedora/sizeof_argument.patch"
# SRC_URI += "file://patches/from_arch/0001-Remove-unused-DEPRECATED-macro.patch"
# SRC_URI += "file://patches/from_arch/0002-Conditionally-define-g_info-macro.patch"
# SRC_URI += "file://patches/from_arch/0003-Add-kuid_t-kgid_t-compatibility-layer.patch"
# SRC_URI += "file://patches/from_arch/0004-Use-new-link-helpers.patch"
# SRC_URI += "file://patches/from_arch/0005-Update-hgfs-file-operations-for-newer-kernels.patch"
# SRC_URI += "file://patches/from_arch/0006-Fix-vmxnet-module-on-kernels-3.16.patch"
# SRC_URI += "file://patches/from_arch/0007-Fix-vmhgfs-module-on-kernels-3.16.patch"
# SRC_URI += "file://patches/from_arch/0008-Fix-segfault-in-vmhgfs.patch"
# SRC_URI += "file://patches/debian/max_nic_count"
# SRC_URI += "file://tools.conf"
SRC_URI += "file://vmtoolsd.service"

SRC_URI[md5sum] = "3777e30d72ed4098ecff16e6480cf1cc"
SRC_URI[sha256sum] = "380c0e83c61f3c8e1f101392f6b872c69e52f584dfe0bd15ba9984c1044497ae"

S = "${WORKDIR}/open-vm-tools-stable-${PV}/open-vm-tools"

DEPENDS = "virtual/kernel glib-2.0 util-linux libdnet procps openssl"
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

EXTRA_OECONF += "--enable-deploypkg=no"
EXTRA_OECONF += "--without-xerces"

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
# install -m 0644 ${WORKDIR}/tools.conf ${D}${sysconfdir}/vmware-tools/tools.conf
}

do_configure_prepend() {
    export CUSTOM_PROCPS_NAME=procps
    export CUSTOM_PROCPS_LIBS=-L${STAGING_LIBDIR}/libprocps.so
    export CUSTOM_SSL_CPPFLAGS=-I${STAGING_INCDIR}
}
