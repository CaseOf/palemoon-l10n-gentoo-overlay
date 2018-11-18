# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Translations for the Pale Moon browser"
HOMEPAGE="https://www.palemoon.org/"

LICENSE="MPL-2.0 GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="fetch strip"

#
# when changing the language lists, please be careful to preserve the spaces (bug 491728)
#
# "en:en-US" for mapping from Gentoo "en" to upstream "en-US" etc.
LANGUAGES=" bg cs de el en-GB es-AR es:es-ES es-MX fr hu it ko nl pl pt-BR pt:pt-PT ru sk sv:sv-SE tl tr uk zh-CN "

for lang in ${LANGUAGES}; do
	langpack="${PN/-l10n/}-${PV}-langpack-${lang#*:}.xpi"
	SRC_URI+=$'\n'"l10n_${lang%:*}? ( ${langpack} )"
	IUSE+=" l10n_${lang%:*}"
done
unset lang langpack

RDEPEND="
	|| (
		(
			>=www-client/palemoon-28.0.0
			<www-client/palemoon-28.3.0
		)

		(
			>=www-client/palemoon-bin-28.0.0
			<www-client/palemoon-bin-28.3.0
		)
	)
"
DEPEND=""

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download following language packs:"
	for src_file in ${A}; do
		lang="$(printf ${src_file} | sed "s/${PN/-l10n/}-${PV}-langpack-\(.*\)\.xpi/\1/")"
		einfo "    - https://addons.palemoon.org/?component=download&version=${PV}&id=langpack-${lang}@${PN/-l10n/}.org"
	done
	einfo "and rename them respectively to:"
	for src_file in ${A}; do
		einfo "    - ${src_file}"
	done
	einfo "and place them in your DISTDIR directory."
	einfo "Upstream servers need a User-Agent header in the request."
	einfo "You can use the following one:"
	einfo "    Mozilla/5.0 (X11; Linux x86_64; rv:60.9) Gecko/20100101 Goanna/4.1 Firefox/60.9 PaleMoon/${PV}"
}

src_unpack() {
	# Do not unpack anything.
	return true
}

src_install() {
	for install_dir in /usr/lib/palemoon /opt/palemoon; do
		insinto ${install_dir}/browser/extensions
		for src_file in ${A}; do
			lang="$(printf ${src_file} | sed "s/${PN/-l10n/}-${PV}-langpack-\(.*\)\.xpi/\1/")"
			newins "${DISTDIR}/${src_file}" "langpack-${lang}@${PN/-l10n}.org.xpi"
		done
		insinto ${install_dir}/browser/defaults/preferences
		doins "${FILESDIR}"/disable-addons-installation-warning.js
		doins "${FILESDIR}"/match-system-locale-configuration.js
	done
}
