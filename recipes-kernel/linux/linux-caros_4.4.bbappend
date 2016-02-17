FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PR := "${PR}.1"

SRC_URI += "file://vmxnet3.cfg \
	    file://veth.cfg \
	    file://common-drivers.scc"

COMPATIBLE_MACHINE_vmware = "vmware"
COMPATIBLE_MACHINE_virtualbox = "virtualbox"

KMACHINE_vmware = "common-pc-64"
KMACHINE_virtualbox = "common-pc-64"

# KARCH_vmware  = "x86_64"
# KARCH_virtualbox  = "x86_64"

KERNEL_FEATURES_append = " cfg/smp.scc"
KERNEL_FEATURES_append_qemuall=" cfg/virtio.scc"
KERNEL_FEATURES_append_qemux86=" cfg/paravirt_kvm.scc"
KERNEL_FEATURES_append_qemux86-64=" cfg/paravirt_kvm.scc"

# SRCREV_machine_vmware ?= "2dadc3524fcbce0c46f5db65b7c20c673fc60503"
# SRCREV_machine_virtualbox ?= "2dadc3524fcbce0c46f5db65b7c20c673fc60503"
