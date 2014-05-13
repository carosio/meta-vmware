#
# Copyright (C) 2012 Travelping GmbH
#
DESCRIPTION = "Image with TPLino components, configured for the use with virtualbox."
LICENSE = "MIT"

include recipes-vmware/ovf/virtualbox-ovf.inc
inherit core-image-tplino core-image

IMAGE_FEATURES += "splash ssh-server-dropbear ${TPLINO_IMAGE_FEATURES}"
IMAGE_INSTALL += "vboxguestdrivers"
