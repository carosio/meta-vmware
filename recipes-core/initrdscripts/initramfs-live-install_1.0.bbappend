FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} += "btrfs-tools dosfstools"

TARGET_DEVICE = ""

do_configure_prepend() {
    sed -i "s/__TARGET_DEVICE__/${TARGET_DEVICE}/g" ${WORKDIR}/init-install.sh
}
