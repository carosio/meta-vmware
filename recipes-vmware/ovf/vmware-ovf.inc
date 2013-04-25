#
# Copyright (C) 2013 Travelping GmbH
#

python __anonymous() {
    # Set OVF variables only if target is "vmware"
    if base_contains("MACHINE", "vmware", "1", "", d) == "1":
        d.appendVar("DEPENDS",  " zip-native vmware-disklib ")
        if not d.getVar("CORE_NUMBER"):
            d.setVar("CORE_NUMBER", "1")
        if not d.getVar("RAM_SIZE"):
            d.setVar("RAM_SIZE", "512")
        if not d.getVar("DISK_SIZE_DATA"):
            d.setVar("DISK_SIZE_DATA", "6144")
        d.setVar("VM_IMAGE_NAME", "${IMAGE_BASENAME}-${MACHINE}")
}

create_bundle_files () {

    if [ ${MACHINE} = "vmware" ]; then
        echo "Target is VMware. Creating OVF"

        cd ${WORKDIR}

        # delete old files
        rm -rf  ${WORKDIR}/vmware-image

        # create new
        mkdir -p ${WORKDIR}/vmware-image

        # create Root Filesystem and Data Filesystem
        cd ${DEPLOY_DIR_IMAGE}
        echo "************"
        echo Converting ROOT partition
        echo Source Image: ${DEPLOY_DIR_IMAGE}/${VM_IMAGE_NAME}.vmdk
        echo Target Image: ${WORKDIR}/vmware-image/${VM_IMAGE_NAME}.vmdk
        echo "************"
        vmware-vdiskmanager -r ${VM_IMAGE_NAME}.vmdk -t 5 ${WORKDIR}/vmware-image/${VM_IMAGE_NAME}.vmdk

        cd ${WORKDIR}

        # set size parameter of vmdk
        VMDK_SIZE_ROOT=`du -b vmware-image/${VM_IMAGE_NAME}.vmdk | awk '{ print $1 }'`

        # set size parameter of real file space in byte
        DISK_SIZE_ROOT=`du -Lb ${DEPLOY_DIR_IMAGE}/${VM_IMAGE_NAME}.hdddirect | awk '{ print $1 }'`
        REAL_DISK_SIZE_DATA=`expr ${DISK_SIZE_DATA} \* 1024 \* 1024`

        #
        # replace parameters in OVF profile
        #

        # disk names
        sed s/disk_name_root/${VM_IMAGE_NAME}/g  ${OVFFILES}/ovf-dummy > vmware-image/${VM_IMAGE_NAME}.ovf

        # vmdk disk sizes
        sed s/vmdk_size_root/${VMDK_SIZE_ROOT}/g -i vmware-image/${VM_IMAGE_NAME}.ovf

        # disk sizes
        sed s/disk_size_root/${DISK_SIZE_ROOT}/g -i vmware-image/${VM_IMAGE_NAME}.ovf
        sed s/disk_size_data/${REAL_DISK_SIZE_DATA}/g -i vmware-image/${VM_IMAGE_NAME}.ovf

        # distro name
        sed s/distro_name/${DISTRO_NAME}_vAPP/g -i vmware-image/${VM_IMAGE_NAME}.ovf

        # hardware specs
        sed s/core_number/${CORE_NUMBER}/g -i vmware-image/${VM_IMAGE_NAME}.ovf
        sed s/ram_size/${RAM_SIZE}/g -i vmware-image/${VM_IMAGE_NAME}.ovf

        #
        # replace parameters in mf-file
        #

        # create sha1Key of vAPP arts
        SHA1KEY_VMDK_ROOT=`sha1sum vmware-image/${VM_IMAGE_NAME}.vmdk | awk '{print $1}'`
        SHA1KEY_OVF=`sha1sum vmware-image/${VM_IMAGE_NAME}.ovf | awk '{print $1}'`

        # set filenames
        sed s/image_name_root/${VM_IMAGE_NAME}/g  ${OVFFILES}/mf-dummy > vmware-image/${VM_IMAGE_NAME}.mf
        sed s/image_name/${VM_IMAGE_NAME}/g  ${OVFFILES}/mf-dummy > vmware-image/${VM_IMAGE_NAME}.mf

        # set keys
        sed s/sha1Key_VMDK_ROOT/${SHA1KEY_VMDK_ROOT}/g -i vmware-image/${VM_IMAGE_NAME}.mf
        sed s/sha1Key_OVF/${SHA1KEY_OVF}/g -i vmware-image/${VM_IMAGE_NAME}.mf

        # zip files
        zip -r ${DEPLOY_DIR_IMAGE}/${VM_IMAGE_NAME}-OVF-DEPLOY vmware-image

        # delete folder to free space
        rm -rf vmware-image
    fi
}

python do_bundle_files() {
    bb.build.exec_func('create_bundle_files', d)
}

addtask bundle_files after do_vmdkimg before do_build
do_bundle_files[nostamp] = "1"
