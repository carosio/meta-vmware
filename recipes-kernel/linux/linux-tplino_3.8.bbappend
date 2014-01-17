FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://vmxnet3.cfg"

PR := "${PR}.7"

COMPATIBLE_MACHINE_vmware = "vmware"

KBRANCH_vmware = "standard/common-pc-64/base"
KMACHINE_vmware = "common-pc-64"
KARCH_vmware  = "x86_64"

KERNEL_FEATURES_append_vmware += " cfg/smp.scc features/veth/veth.scc"

SRCREV_machine_vmware ?= "${AUTOREV}"
SRCREV_meta_vmware ?= "${AUTOREV}"
