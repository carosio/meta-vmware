#
# Copyright (C) 2013 Travelping GmbH
#
python __anonymous() {
    # Set OVF variables only if target is "vmware"
    if base_contains("MACHINE", "vmware", "1", "", d) == "1":
        d.appendVar("DEPENDS",  " zip-native vmware-disklib vmware-ovftool ")
        if not d.getVar("CORE_NUMBER"):
            d.setVar("CORE_NUMBER", "1")
        if not d.getVar("RAM_SIZE"):
            d.setVar("RAM_SIZE", "512")
        if not d.getVar("DISK_SIZE_DATA"):
            d.setVar("DISK_SIZE_DATA", "6144")
        d.setVar("VM_IMAGE_NAME", "${IMAGE_BASENAME}-${MACHINE}")
        d.setVar("VM_IMAGE_NAME_VER", "${IMAGE_BASENAME}-${DISTRO_VERSION}-${MACHINE}")
	root_size = d.getVar("DISK_SIZE_ROOT")
	if root_size:
	    root_size = int(root_size) * 1024
	    d.setVar("IMAGE_ROOTFS_SIZE", str(root_size))
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
        echo Target Image: ${WORKDIR}/vmware-image/${VM_IMAGE_NAME_VER}.vmdk
        echo "************"
        vmware-vdiskmanager -r ${VM_IMAGE_NAME}.vmdk -t 5 ${WORKDIR}/vmware-image/${VM_IMAGE_NAME_VER}.vmdk

        cd ${WORKDIR}

        # set size parameter of vmdk
        VMDK_SIZE_ROOT=`du -b vmware-image/${VM_IMAGE_NAME_VER}.vmdk | awk '{ print $1 }'`

        # set size parameter of real file space in byte
      	# if the size of the root file system is set, use that,
	      # else use actual size of file
      	if [ -n "${DISK_SIZE_ROOT}" ]
	       then
            REAL_DISK_SIZE_ROOT=`expr ${IMAGE_ROOTFS_SIZE} \* 1024 \* 105 \/ 100`
	       else
            REAL_DISK_SIZE_ROOT=`du -Lb ${DEPLOY_DIR_IMAGE}/${VM_IMAGE_NAME}.hdddirect | awk '{ print $1 }'`
	      fi

        REAL_DISK_SIZE_DATA=`expr ${DISK_SIZE_DATA} \* 1024 \* 1024`

        #
        # replace parameters in OVF profile
        #

        # disk names
        # vmdk disk sizes 
        # disk sizes
        # distro name
        # hardware specs
        sed -e s/@@DISK_NAME_ROOT@@/${VM_IMAGE_NAME_VER}/g \
            -e s/@@VMDK_SIZE_ROOT@@/${VMDK_SIZE_ROOT}/g \
            -e s/@@DISK_SIZE_ROOT@@/${REAL_DISK_SIZE_ROOT}/g \
            -e s/@@DISK_SIZE_DATA@@/${REAL_DISK_SIZE_DATA}/g \
            -e s/@@DISTRO_NAME@@/${DISTRO_NAME}_vAPP/g \
            -e s/@@CORE_NUMBER@@/${CORE_NUMBER}/g \
            -e s/@@RAM_SIZE@@/${RAM_SIZE}/g \
            ${OVFFILES}/vmware.ovf.in > vmware-image/${VM_IMAGE_NAME_VER}.ovf

        #
        # replace parameters in mf-file
        #

        # create sha1Key of vAPP arts
        SHA1KEY_VMDK_ROOT=`sha1sum vmware-image/${VM_IMAGE_NAME_VER}.vmdk | awk '{print $1}'`
        SHA1KEY_OVF=`sha1sum vmware-image/${VM_IMAGE_NAME_VER}.ovf | awk '{print $1}'`

        # set filenames
        sed -e s/@@IMAGE_NAME_ROOT@@/${VM_IMAGE_NAME_VER}/g \
            -e s/@@IMAGE_NAME@@/${VM_IMAGE_NAME_VER}/g \
            ${OVFFILES}/vmware.mf.in > vmware-image/${VM_IMAGE_NAME_VER}.mf

        # set keys
        sed s/@@SHA1KEY_VMDK_ROOT@@/${SHA1KEY_VMDK_ROOT}/g -i vmware-image/${VM_IMAGE_NAME_VER}.mf
        sed s/@@SHA1KEY_OVF@@/${SHA1KEY_OVF}/g -i vmware-image/${VM_IMAGE_NAME_VER}.mf

        # zip files
        zip -r ${DEPLOY_DIR_IMAGE}/${VM_IMAGE_NAME_VER}-OVF-DEPLOY vmware-image
        
        # ova file 
        ovftool -o vmware-image/${VM_IMAGE_NAME_VER}.ovf ${DEPLOY_DIR_IMAGE}/${VM_IMAGE_NAME_VER}.ova

        # delete folder to free space
        rm -rf vmware-image
    fi
}

python do_bundle_files() {
    bb.build.exec_func('create_bundle_files', d)
}

addtask bundle_files after do_vmdkimg before do_build
do_bundle_files[nostamp] = "1"
