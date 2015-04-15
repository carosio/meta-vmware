SYSLINUX_PROMPT ?= "0"
SYSLINUX_TIMEOUT ?= "10"
SYSLINUX_LABELS = "install boot"
LABELS_append = " ${SYSLINUX_LABELS} "

# need to define the dependency and the ROOTFS for directdisk
# do_bootdirectdisk[depends] += "${PN}:do_rootfs"
INSTALL_IMG ?= "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}.iso"

OVA_PRODUCT ??= "${DISTRO_NAME}"
OVA_VENDOR ??= "Tavelping GmbH"
OVA_VENDOR_URL ??= "http://www.travelping.com/"
OVA_VERSION ??= "${DISTRO_VERSION}"

inherit image_types bootimg

IMAGE_TYPEDEP_ova = "live"
IMAGE_TYPES_MASKED += "ova"

IMAGE_DEPENDS_ova = "virtual/kernel"

create_ova () {
        echo "Creating OVF"

        cd ${WORKDIR}

	REAL_INSTALL_IMG=`readlink -f ${INSTALL_IMG}`
	INSTALL_IMG_NAME=`basename ${REAL_INSTALL_IMG}`

        # create new
        rm -rf  ${WORKDIR}/ova-image
        mkdir -p ${WORKDIR}/ova-image

        # Empty disk could be deployed without a vmdk file but virtualbox does not understand that (https://www.virtualbox.org/ticket/13354)
        qemu-img create -f vmdk -o subformat=streamOptimized ${WORKDIR}/ova-image/${IMAGE_NAME}-disk1.vmdk ${DISK_SIZE_BOOT}G
	cp ${REAL_INSTALL_IMG} ${WORKDIR}/ova-image/${INSTALL_IMG_NAME}

        # Actual size of the created VMDK files.
        DISK_BOOT_VMDK_SIZE=`du -b ova-image/${IMAGE_NAME}-disk1.vmdk | awk '{ print $1 }'`
	DISK_INSTALL_SIZE=`du -b ova-image/${INSTALL_IMG_NAME} | awk '{ print $1 }'`

	# create data disk if size > 0
	if [ "${DISK_SIZE_DATA}" != 0 ] ; then
		qemu-img create -f vmdk -o subformat=streamOptimized ${WORKDIR}/ova-image/${IMAGE_NAME}-disk2.vmdk ${DISK_SIZE_DATA}G
		DISK_DATA_VMDK_SIZE=`du -b ova-image/${IMAGE_NAME}-disk2.vmdk | awk '{ print $1 }'`
	fi

        # Output some debug variables to the logfile ${WORKDIR}/temp/log.do_ova
        # disk names
        bbnote "Boot Disk Name:             ${IMAGE_NAME}-disk1.vmdk"
        bbnote "Install Image Name:         ${INSTALL_IMG_NAME}"
        # disk sizes
        bbnote "DISK_SIZE_BOOT:             ${DISK_SIZE_BOOT}"
        bbnote "DISK_SIZE_DATA:             ${DISK_SIZE_DATA}"
        # vmdk sizes
        bbnote "DISK_BOOT_VMDK_SIZE:        ${DISK_BOOT_VMDK_SIZE}"
        bbnote "DISK_DATA_VMDK_SIZE:        ${DISK_DATA_VMDK_SIZE}"
        bbnote "DISK_INSTALL_SIZE:          ${DISK_INSTALL_SIZE}"
        # distro name
        bbnote "Distro Name:                ${DISTRO_NAME}"
        bbnote "Distro Version:             ${DISTRO_VERSION}"
        # hardware specs
        bbnote "CPU Cores:                  ${CORE_NUMBER}"
        bbnote "RAM Size:                   ${RAM_SIZE}"

        #
        # replace parameters in OVF profile
        #
        sed -e "s|@@DISK_BOOT_NAME@@|${IMAGE_NAME}-disk1.vmdk|g" \
            -e "s|@@DISK_DATA_NAME@@|${IMAGE_NAME}-disk2.vmdk|g" \
	    -e "s|@@DISK_INSTALL_NAME@@|${INSTALL_IMG_NAME}|g" \
            -e "s|@@DISK_BOOT_VMDK_SIZE@@|${DISK_BOOT_VMDK_SIZE}|g" \
            -e "s|@@DISK_DATA_VMDK_SIZE@@|${DISK_DATA_VMDK_SIZE}|g" \
            -e "s|@@DISK_INSTALL_SIZE@@|${DISK_INSTALL_SIZE}|g" \
            -e "s|@@DISK_BOOT_CAPACITY@@|${DISK_SIZE_BOOT}|g" \
            -e "s|@@DISK_DATA_CAPACITY@@|${DISK_SIZE_DATA}|g" \
            -e "s|@@DISTRO_NAME@@|${DISTRO_NAME}-${DISTRO_VERSION}_vAPP|g" \
            -e "s|@@CORE_NUMBER@@|${CORE_NUMBER}|g" \
            -e "s|@@RAM_SIZE@@|${RAM_SIZE}|g" \
	    -e "s|@@OVA_PRODUCT@@|${OVA_PRODUCT}|g" \
	    -e "s|@@OVA_VENDOR@@|${OVA_VENDOR}|g" \
	    -e "s|@@OVA_VENDOR_URL@@|${OVA_VENDOR_URL}|g" \
	    -e "s|@@OVA_VERSION@@|${OVA_VERSION}|g" \
            ${OVFFILES}/ovf.in > ova-image/${IMAGE_NAME}.ovf

	if [ "${DISK_SIZE_DATA}" != 0 ] ; then
		sed -i '/__NO_DATA_DISK__/d' ova-image/${IMAGE_NAME}.ovf
	fi

        #
        # replace parameters in mf-file
        #

	OVF_FILE="${IMAGE_NAME}.ovf"
	DEVICE_FILES="${IMAGE_NAME}-disk1.vmdk"
	if [ "${DISK_SIZE_DATA}" != 0 ] ; then
		DEVICE_FILES="${DEVICE_FILES} ${IMAGE_NAME}-disk2.vmdk"
	fi
	DEVICE_FILES="${DEVICE_FILES} ${INSTALL_IMG_NAME}"

        # create sha1Key of vAPP parts and write to mf file
	for F in ${OVF_FILE} ${DEVICE_FILES}; do
		SHA1KEY=`sha1sum ova-image/${F} | awk '{print $1}'`
		echo "SHA1(${F})= ${SHA1KEY}" >> ova-image/${IMAGE_NAME}.mf
	done

        # ova file
        tar --mode=0644 --owner=65534 --group=65534 -cf ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.ova -C ova-image $OVF_FILE ${IMAGE_NAME}.mf $DEVICE_FILES

        # delete folder to free space
        # rm -rf ova-image

        ln -sf ${IMAGE_NAME}.ova ${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.ova
}

python do_ova() {
        bb.build.exec_func('create_ova', d)
}

addtask ova after do_bootimg before do_build

do_ova[depends] += "qemu-native:do_populate_sysroot"
