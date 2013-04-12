DECRIPTION = "open-vmware-tools"
SECTION = "vmware-tools"
LICENSE = "GPLv2"
DEPENDS = "glib-2.0 util-linux gcc"
LIC_FILES_CHKSUM = "file://COPYING;md5=5804fe91d3294da4ac47c02b454bbc8a"

PR = "r0"

SRC_URI = "\
   http://downloads.sourceforge.net/project/open-vm-tools/open-vm-tools/stable-9.2.x/open-vm-tools-9.2.2-893683.tar.gz \
   file://path_vmtools.patch \
   file://02-glib-static.patch \
  "



SRC_URI[sha256sum] = "1ae795e75bf4b38185f39083b8075686d3bab4c1222f4e39c863aeccb2f5f387"

EXTRA_OECONF = "--without-procps --disable-multimon --disable-docs --with-linuxdir=${STAGING_KERNEL_DIR}/${KMETA}" 
                

EXTRA_OECONF += "${@base_contains('DISTRO_FEATURES', 'pam', '', '--without-pam', d)} \
                 ${@base_contains('DISTRO_FEATURES', 'x11', '', '--without-x', d)} \
                 ${@base_contains('DISTRO_FEATURES', 'dnet', '', '--without-dnet', d)} \
                "


CFLAGS += '-Wno-error=deprecated-declarations'

S = "${WORKDIR}/open-vm-tools-9.2.2-893683"

inherit autotools gettext core-image
