PR := "${PR}.1"

do_install_append() {
    # mount second HDD
    install -d ${D}/srv/data
    echo "/dev/sdb1  /srv/data  ext4  defaults  0  2" >> ${D}${sysconfdir}/fstab
}
