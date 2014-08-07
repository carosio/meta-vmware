FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://vmxnet3.cfg"

PR := "${PR}.7"

COMPATIBLE_MACHINE = "vmware|virtualbox"

KBRANCH_vmware = "standard/common-pc-64/base"
KMACHINE_vmware = "common-pc-64"
KARCH_vmware  = "x86_64"

KERNEL_FEATURES_append += " cfg/smp.scc features/veth/veth.scc"

SRCREV_machine_vmware ?= "${AUTOREV}"
SRCREV_meta_vmware ?= "${AUTOREV}"

KBRANCH_virtualbox = "standard/common-pc-64/base"
KMACHINE_virtualbox = "common-pc-64"
KARCH_virtualbox  = "x86_64"
SRCREV_machine_virtualbox ?= "${AUTOREV}"
SRCREV_meta_virtualbox ?= "${AUTOREV}"
