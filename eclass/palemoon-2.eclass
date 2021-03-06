# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit check-reqs gnome2-utils fdo-mime

EXPORT_FUNCTIONS pkg_pretend pkg_preinst pkg_postinst pkg_postrm pkg_setup

palemoon-2_pkg_pretend() {
	# Ensure we have enough disk space to compile:
	CHECKREQS_DISK_BUILD=${REQUIRED_BUILDSPACE}
	check-reqs_pkg_setup

	# Ensure we are not on a gcc 5.* profile:
	if [ "$(cc --version | head -c 3)" == "gcc" ]; then
		einfo "Checking gcc version..."
		if [ "$(gcc -dumpversion | head -c 1)" -ge 5 ]; then
			if [ "$(gcc -dumpversion | head -c 1)" -eq 7 ]; then
				gcc-7_error
				die
			fi
			gcc-5_warning
		fi
	fi
}

palemoon-2_pkg_preinst() {
	gnome2_icon_savelist
}

palemoon-2_pkg_postinst() {
	# Update mimedb for the new .desktop file:
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

palemoon-2_pkg_postrm() {
	gnome2_icon_cache_update
}

palemoon-2_pkg_setup() {
	# Nested configure scripts in mozilla products generate unrecognized
	# options false positives when toplevel configure passes downwards:
	export QA_CONFIGURE_OPTIONS=".*"
}

official-branding_warning() {
	elog "You are enabling official branding. You may not redistribute this build"
	elog "to any users on your network or the internet. Doing so puts yourself into"
	elog "a legal problem with Moonchild Productions"
	elog "You can disable it by emerging ${PN} _without_ the official-branding USE-flag"
}

gcc-5_warning() {
	eerror "Building Pale Moon with gcc >=5 may result in an unstable build."
	eerror "You can use gcc-config to change your compiler profile,"
	eerror "just remember to change it back afterwards."
	eerror "You need to have the appropriate versions of gcc installed"
	eerror "for them to be shown in gcc-config."
}

gcc-7_error() {
	eerror "You are currently on a gcc 7.* compiler profile."
	eerror "Building Pale Moon with gcc 7 is risky and rarely possible."
	eerror "You can use gcc-config to change your compiler profile,"
	eerror "just remember to change it back afterwards."
	eerror "You need to have the appropriate versions of gcc installed"
	eerror "for them to be shown in gcc-config."
}
mozconfig_init() {
	cp -L "${S}/browser/config/mozconfig" "${S}/.mozconfig" || die
}

mozconfig_enable() {
	for option in "$@"; do
		echo "ac_add_options --enable-${option}" >> "${S}/.mozconfig"
	done
}

mozconfig_disable() {
	for option in "$@"; do
		echo "ac_add_options --disable-${option}" >> "${S}/.mozconfig"
	done
}

mozconfig_with() {
	for option in "$@"; do
		echo "ac_add_options --with-${option}" >> "${S}/.mozconfig"
	done
}

mozconfig_var() {
	echo "mk_add_options $1=\"$2\"" >> "${S}/.mozconfig"
}

load_default_prefs() {
	PREFS_FILE="${S}/${obj_dir}/dist/bin/browser/defaults/preferences/firefox.js"
	cat "${FILESDIR}"/default-prefs.js-0 >> $PREFS_FILE || die
}

set_pref() {
	echo "pref(\"$1\", \"$2\");" >> $PREFS_FILE
}
