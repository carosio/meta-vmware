inherit image_types
inherit boot-directdisk

IMAGE_FSTYPES_prepend = "ext3 "
IMAGE_DEPENDS_ova-vmware = "virtual/kernel"

CORE_NUMBER ?= "1"
RAM_SIZE ?= "512"

VM_IMAGE_NAME = "${IMAGE_NAME}-${MACHINE}"
VM_IMAGE_NAME_VER = "${IMAGE_NAME}"

SYSLINUX_ROOT = "root=/dev/sda2 "
SYSLINUX_PROMPT = "0"
SYSLINUX_TIMEOUT = "1"
SYSLINUX_LABELS = "boot"

create_ova () {

        echo "Creating OVF"

        cd ${WORKDIR}

        # delete old files
        rm -rf  ${WORKDIR}/ova-image

        # create new
        mkdir -p ${WORKDIR}/ova-image

        # create Root Filesystem and Data Filesystem
	qemu-img convert -O vmdk -o subformat=streamOptimized ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.hdddirect ${WORKDIR}/ova-image/${VM_IMAGE_NAME_VER}-disk1.vmdk
        cd ${WORKDIR}

        # set size parameter of vmdk
        VMDK_USED_ROOT=`du -Lb ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.hdddirect | awk '{ print $1 }'`
        VMDK_SIZE_ROOT=`du -b ova-image/${VM_IMAGE_NAME_VER}-disk1.vmdk | awk '{ print $1 }'`

        # set size parameter of real file space in byte
	# if the size of the root file system is set, use that,
	# else use actual size of file
	if [ -n "${DISK_SIZE_ROOT}" ]; then
            REAL_DISK_SIZE_ROOT=`expr ${IMAGE_ROOTFS_SIZE} \* 1024 \* 105 \/ 100`
	else
            REAL_DISK_SIZE_ROOT=`du -Lb ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.hdddirect | awk '{ print $1 }'`
	fi

        #
        # replace parameters in OVF profile
        #

        # disk names
        # vmdk disk sizes
        # disk sizes
        # distro name
        # hardware specs
        sed -e s/@@DISK_NAME_ROOT@@/${VM_IMAGE_NAME_VER}-disk1.vmdk/g \
            -e s/@@VMDK_SIZE_ROOT@@/${VMDK_SIZE_ROOT}/g \
            -e s/@@VMDK_USED_ROOT@@/${VMDK_USED_ROOT}/g \
            -e s/@@DISK_SIZE_ROOT@@/${REAL_DISK_SIZE_ROOT}/g \
            -e s/@@DISTRO_NAME@@/${DISTRO_NAME}_vAPP/g \
            -e s/@@CORE_NUMBER@@/${CORE_NUMBER}/g \
            -e s/@@RAM_SIZE@@/${RAM_SIZE}/g \
            ${OVFFILES}/ovf.in > ova-image/${VM_IMAGE_NAME_VER}.ovf

        #
        # replace parameters in mf-file
        #

        # create sha1Key of vAPP arts
        SHA1KEY_VMDK_ROOT=`sha1sum ova-image/${VM_IMAGE_NAME_VER}-disk1.vmdk | awk '{print $1}'`
        SHA1KEY_OVF=`sha1sum ova-image/${VM_IMAGE_NAME_VER}.ovf | awk '{print $1}'`

        echo "SHA1(${VM_IMAGE_NAME_VER}-disk1.vmdk)= ${SHA1KEY_VMDK_ROOT}" > ova-image/${VM_IMAGE_NAME_VER}.mf
        echo "SHA1(${VM_IMAGE_NAME_VER}.ovf)= ${SHA1KEY_OVF}" >> ova-image/${VM_IMAGE_NAME_VER}.mf

        # ova file
        tar --mode=0644 --owner=65534 --group=65534 -cf ${DEPLOY_DIR_IMAGE}/${VM_IMAGE_NAME_VER}.ova -C ova-image ${VM_IMAGE_NAME_VER}.ovf ${VM_IMAGE_NAME_VER}.mf ${VM_IMAGE_NAME_VER}-disk1.vmdk

        # delete folder to free space
        rm -rf ova-image
	ln -s ${VM_IMAGE_NAME_VER}.ova ${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.ova
}


python do_ova() {
        bb.build.exec_func('create_ova', d)
}

addtask ova after do_bootdirectdisk before do_build
do_ova[nostamp] = "1"
do_ova[depends] += "qemu-native:do_populate_sysroot"

NOISO = "1"


LABELS_append = " ${SYSLINUX_LABELS} "
ROOTFS ?= "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}.ext3"
do_bootdirectdisk[depends] += "${PN}:do_rootfs"
