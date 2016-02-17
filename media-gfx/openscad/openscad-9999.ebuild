# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit qt4-r2

if [[ ${PV} == "9999" ]] ; then
        inherit git-r3
        EGIT_REPO_URI="https://github.com/openscad/openscad.git"
else
	SRC_URI="http://files.openscad.org/${P}.src.tar.gz"
        KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="The Programmers Solid 3D CAD Modeller"
HOMEPAGE="http://www.openscad.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

CDEPEND="media-gfx/opencsg
	sci-mathematics/cgal
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	dev-qt/qtopengl:4
	dev-cpp/eigen:3
	dev-libs/gmp:0
	dev-libs/mpfr:0
	dev-libs/boost:=
	x11-libs/qscintilla
"
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

src_prepare() {
	#Use our CFLAGS (specifically don't force x86)
	sed -i "s/QMAKE_CXXFLAGS_RELEASE = .*//g" ${PN}.pro  || die

	sed -i "s/\/usr\/local/\/usr/g" ${PN}.pro || die
}
