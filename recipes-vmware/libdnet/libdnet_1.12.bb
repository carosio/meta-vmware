DESCRIPTION = "simplified, portable interface to several low-level networking routines"
SECTION = "libs" 
HOMEPAGE = "http://libdnet.sourceforge.net/"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=0036c1b155f4e999f3e0a373490b5db9"


SRC_URI = "http://libdnet.googlecode.com/files/${P}.tgz"
SRC_URI[sha256sum] = "71302be302e84fc19b559e811951b5d600d976f8" 

S = "${WORKDIR}/${P}"
PR = "r0"

inherit autotools binconfig  

EXTRA_AUTORECONF += " -I ${S}/config"

