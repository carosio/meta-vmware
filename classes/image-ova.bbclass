SYSLINUX_ROOT ?= "root=/dev/sda2 "
SYSLINUX_PROMPT ?= "0"
SYSLINUX_TIMEOUT ?= "10"
SYSLINUX_LABELS = "boot"
LABELS_append = " ${SYSLINUX_LABELS} "

# need to define the dependency and the ROOTFS for directdisk
do_bootdirectdisk[depends] += "${PN}:do_rootfs"
ROOTFS ?= "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}.ext3"

IS_VMDK = '${@bb.utils.contains("IMAGE_FSTYPES", "ova", "true", "false", d)}'

inherit image_types boot-directdisk

IMAGE_TYPEDEP_ova = "ext3"
IMAGE_TYPES_MASKED += "ova"

IMAGE_DEPENDS_ova = "virtual/kernel"

create_ova () {
        echo "Creating OVF"

        cd ${WORKDIR}

        # create new
        rm -rf  ${WORKDIR}/ova-image
        mkdir -p ${WORKDIR}/ova-image

        # create Root Filesystem and Data Filesystem
        qemu-img convert -O vmdk -o subformat=streamOptimized ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.hdddirect ${WORKDIR}/ova-image/${IMAGE_NAME}-disk1.vmdk

        # The second, empty, disk could be deployed without a vmdk file but virtualbox does not understand that (https://www.virtualbox.org/ticket/13354)
        qemu-img create -f vmdk -o subformat=streamOptimized ${WORKDIR}/ova-image/${IMAGE_NAME}-disk2.vmdk ${DISK_SIZE_DATA}G
        cd ${WORKDIR}

        # the "populated_size parameter can be an estimate, this should suffice.
        # FIXME: When the builder has dd in version 8.26 or higher, fix boot-directdisk.bbclass to create a sparse .hdddirect file and use the size of that file.
        DISK_ROOT_VMDK_USED=`du -Lbs ${INSTALL_ROOTFS_IPK} 2>/dev/null | awk '{ print $1 }'`

        # Actual size of the created VMDK files.
        DISK_ROOT_VMDK_SIZE=`du -b ova-image/${IMAGE_NAME}-disk1.vmdk | awk '{ print $1 }'`
        DISK_DATA_VMDK_SIZE=`du -b ova-image/${IMAGE_NAME}-disk2.vmdk | awk '{ print $1 }'`

        # Make Root Disk 100MB bigger than ROOTFS
        DISK_ROOT_CAPACITY=`expr \( ${IMAGE_ROOTFS_SIZE}  + 102400 \) \* 1024`

        # Take Size of data disk as GB from config
        DISK_DATA_CAPACITY=${DISK_SIZE_DATA}

        # Output some debug variables to the logfile ${WORKDIR}/temp/log.do_ova
        # disk names
        bbnote "Root Disk Name:             ${IMAGE_NAME}-disk1.vmdk"
        # vmdk disk sizes
        bbnote "DISK_ROOT_VMDK_USED:        ${DISK_ROOT_VMDK_USED}"
        bbnote "DISK_ROOT_VMDK_SIZE:        ${DISK_ROOT_VMDK_SIZE}"
        # disk sizes
        bbnote "IMAGE_ROOTFS_SIZE:          ${IMAGE_ROOTFS_SIZE}"
        bbnote "IMAGE_ROOTFS_EXTRA_SPACE:   ${IMAGE_ROOTFS_EXTRA_SPACE}"
        bbnote "IMAGE_OVERHEAD_FACTOR:      ${IMAGE_OVERHEAD_FACTOR}"
        bbnote "DISK_ROOT_CAPACITY:         ${DISK_ROOT_CAPACITY}"
        bbnote "DISK_DATA_CAPACITY:         ${DISK_DATA_CAPACITY}"
        bbnote "DISK_DATA_VMDK_SIZE:        ${DISK_DATA_VMDK_SIZE}"
        # distro name
        bbnote "Distro Name:                ${DISTRO_NAME}"
        bbnote "Distro Version:             ${DISTRO_VERSION}"
        # hardware specs
        bbnote "CPU Cores:                  ${CORE_NUMBER}"
        bbnote "RAM Size:                   ${RAM_SIZE}"

        #
        # replace parameters in OVF profile
        #
        sed -e s/@@DISK_ROOT_NAME@@/${IMAGE_NAME}-disk1.vmdk/g \
            -e s/@@DISK_DATA_NAME@@/${IMAGE_NAME}-disk2.vmdk/g \
            -e s/@@DISK_ROOT_VMDK_SIZE@@/${DISK_ROOT_VMDK_SIZE}/g \
            -e s/@@DISK_DATA_VMDK_SIZE@@/${DISK_DATA_VMDK_SIZE}/g \
            -e s/@@DISK_ROOT_VMDK_USED@@/${DISK_ROOT_VMDK_USED}/g \
            -e s/@@DISK_ROOT_CAPACITY@@/${DISK_ROOT_CAPACITY}/g \
            -e s/@@DISK_DATA_CAPACITY@@/${DISK_DATA_CAPACITY}/g \
            -e s/@@DISTRO_NAME@@/${DISTRO_NAME}-${DISTRO_VERSION}_vAPP/g \
            -e s/@@CORE_NUMBER@@/${CORE_NUMBER}/g \
            -e s/@@RAM_SIZE@@/${RAM_SIZE}/g \
            ${OVFFILES}/ovf.in > ova-image/${IMAGE_NAME}.ovf

        #
        # replace parameters in mf-file
        #

        # create sha1Key of vAPP arts
        SHA1KEY_VMDK_ROOT=`sha1sum ova-image/${IMAGE_NAME}-disk1.vmdk | awk '{print $1}'`
        SHA1KEY_VMDK_DATA=`sha1sum ova-image/${IMAGE_NAME}-disk2.vmdk | awk '{print $1}'`
        SHA1KEY_OVF=`sha1sum ova-image/${IMAGE_NAME}.ovf | awk '{print $1}'`

        echo "SHA1(${IMAGE_NAME}-disk1.vmdk)= ${SHA1KEY_VMDK_ROOT}" > ova-image/${IMAGE_NAME}.mf
        echo "SHA1(${IMAGE_NAME}-disk2.vmdk)= ${SHA1KEY_VMDK_DATA}" >> ova-image/${IMAGE_NAME}.mf
        echo "SHA1(${IMAGE_NAME}.ovf)= ${SHA1KEY_OVF}" >> ova-image/${IMAGE_NAME}.mf

        # ova file
        tar --mode=0644 --owner=65534 --group=65534 -cf ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.ova -C ova-image ${IMAGE_NAME}.ovf ${IMAGE_NAME}.mf ${IMAGE_NAME}-disk1.vmdk ${IMAGE_NAME}-disk2.vmdk

        # delete folder to free space
        # rm -rf ova-image

        ln -sf ${IMAGE_NAME}.ova ${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.ova
}

python do_ova() {
        bb.build.exec_func('create_ova', d)
}

addtask ova after do_bootdirectdisk before do_build

do_ova[depends] += "qemu-native:do_populate_sysroot"
