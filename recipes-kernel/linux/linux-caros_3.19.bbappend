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

SRCREV_machine_vmware ?= "31b35da6a5c8a2b162f6c33202e9b64dd13757d5"
SRCREV_machine_virtualbox ?= "31b35da6a5c8a2b162f6c33202e9b64dd13757d5"

# SRCREV_meta_vmware ?= "${AUTOREV}"
# SRCREV_meta_virtualbox ?= "${AUTOREV}"
