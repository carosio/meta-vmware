DECRIPTION = "This will setup CarOS so it can be used with vagrant."
SECTION = "vagrant"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

PR = "r5"

PACKAGE_ARCH = "${MACHINE_ARCH}"

SRCREV="09aed15add861b5070d5efc91e0790756e3327eb"

SRC_URI = "file://caros-vagrant.pub \
    file://vagrant-sudoers "

RDEPENDS_${PN} = " vboxguestdrivers sudo bash wget "

FILES_${PN} += " \
    /home \
    /home/vagrant \
    /home/vagrant/.ssh \
    /home/vagrant/.ssh/authorized_keys "

inherit useradd

USERADD_PACKAGES = "${PN}"
USERADD_PARAM_${PN} = "-m -g users -G vagrant -s /bin/sh vagrant"
GROUPADD_PARAM_${PN} = "vagrant"

VAGRANT_PUBLIC_KEY ?= "caros-vagrant.pub"

do_install_append() {
    install -d ${D}${sysconfdir}/sudoers.d
    install -d -o vagrant ${D}/home/vagrant/ 
    install -d 700 -o vagrant ${D}/home/vagrant/.ssh 
    install ${WORKDIR}/vagrant-sudoers ${D}${sysconfdir}/sudoers.d

    install -m 600 ${WORKDIR}/${VAGRANT_PUBLIC_KEY} ${D}/home/vagrant/.ssh/authorized_keys
}
