SUMMARY = "open-vmdk"
DESCRIPTION = "Tools for vmware disk images"
HOMEPAGE = "https://github.com/vmware/open-vmdk"
SECTION = "base"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57 \
                    file://vmdk/mkdisk.c;endline=14;md5=443cd7a9387ca4ac2f9d29a03c7b6f1f"

PV = "1.0+git${SRCPV}"
PKGV = "1.0+git${GITPKGV}"
PR = "r3"
SRCREV = "82eb7268e78cc32907573b713569e1331c571ce5"

SRC_URI = "git://github.com/vmware/open-vmdk;protocol=git"

S = "${WORKDIR}/git"

BBCLASSEXTEND = "native nativesdk"

do_install() {
        install -d ${D}${bindir}
        install ${B}/build/vmdk/vmdk-convert ${D}${bindir}/vmdk-convert
        install ${B}/ova/mkova.sh ${D}${bindir}/mkova.sh
}
