FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PR := "${PR}.3"

COMPATIBLE_MACHINE_vmware = "vmware"


KBRANCH_vmware  = "standard/common-pc-64/base"

KMACHINE_vmware  = "vmware"

KARCH_vmware  = "x86_64"

KERNEL_FEATURES_append_vmware += " cfg/smp.scc"


# uncomment and replace these SRCREVs with the real commit ids once you've had
# the appropriate changes committed to the upstream linux-yocto repo
SRCREV_machine_vmware ?= "AUTOINC"
SRCREV_meta_vmware ?= "AUTOINC"

SRC_URI = "git:///usr/src/disk/aschultz/kernel-work/tplino-linux-3.8-bare;bareclone=1;branch=${KBRANCH},meta;name=machine,meta"

