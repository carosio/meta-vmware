FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PR := "${PR}.1"

SRC_URI += "file://vmxnet3.cfg \
	    file://veth.cfg \
	    file://ide-off.cfg \
	    file://pvscsi.cfg"

COMPATIBLE_MACHINE_vmware = "vmware"
COMPATIBLE_MACHINE_virtualbox = "virtualbox"

KBRANCH_vmware = "standard/common-pc-64/base"
KBRANCH_virtualbox = "standard/common-pc-64/base"

KMACHINE_vmware = "common-pc-64"
KMACHINE_virtualbox = "common-pc-64"

# KARCH_vmware  = "x86_64"
# KARCH_virtualbox  = "x86_64"

KERNEL_FEATURES_append = " cfg/smp.scc"
KERNEL_FEATURES_append_qemuall=" cfg/virtio.scc"
KERNEL_FEATURES_append_qemux86=" cfg/paravirt_kvm.scc"
KERNEL_FEATURES_append_qemux86-64=" cfg/paravirt_kvm.scc"

KERNEL_FEATURES_append = " ./features/scsi/cdrom.scc"
KERNEL_FEATURES_append = " ./features/scsi/disk.scc"

SRCREV_machine_vmware ?= "e152349de59b43b2a75f2c332b44171df461d5a0"
SRCREV_machine_virtualbox ?= "e152349de59b43b2a75f2c332b44171df461d5a0"
