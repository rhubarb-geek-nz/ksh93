#!/bin/sh -e
#
#  Copyright 2021, Roger Brown
#
#  This file is part of rhubarb pi.
#
#  This program is free software: you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation, either version 3 of the License, or (at your
#  option) any later version.
# 
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>
#
# $Id: package.sh 57 2021-06-14 19:02:46Z rhubarb-geek-nz $
#

cleanup()
{
	rm -rf ksh93-code data meta
}

trap cleanup 0

GITREF=e939860a86e1c9f1e7eb0a971d4bc2c5336efc9d

if test ! -d ksh93-code
then
	(
		set -e

		git clone https://github.com/ksh93/ksh.git ksh93-code

		cd ksh93-code

		git checkout "$GITREF"

		git apply < "../$GITREF.patch"

		bin/package make	
	)
fi

rm -rf data meta

PKGNAME=ast-ksh
VERSION=20210603
SRCROOT=data

ls -ld ksh93-code/arch/*/src/cmd/ksh93/ksh 

test 1 = $(ls ksh93-code/arch/*/src/cmd/ksh93/ksh | wc -l)

mkdir -p data/usr/pkg/bin data/usr/pkg/man/man1

cp ksh93-code/arch/*/src/cmd/ksh93/ksh data/usr/pkg/bin/ksh93

cp ksh93-code/src/cmd/ksh93/sh.1 data/usr/pkg/man/man1/ksh93.1

mkdir meta

(
	set -e
	echo HOMEPAGE=https://github.com/ksh93/ksh
	echo MACHINE_ARCH=$(uname -p)
	echo OPSYS=$(uname -s)
	echo OS_VERSION=$(uname -r)
	echo PKGTOOLS_VERSION=$(pkg_info -V)
) > "meta/BUILD_INFO"

echo "KornShell 93u+m" > meta/COMMENT

cat > meta/DESC <<EOF
KSH-93 is the most recent version of the KornShell Language described in "The KornShell Command and Programming Language," by Morris Bolsky and David Korn of AT&T Bell Laboratories, ISBN 0-13-182700-6. The KornShell is a shell programming language, which is upward compatible with "sh" (the Bourne Shell), and is intended to conform to the IEEE P1003.2/ISO 9945.2 Shell and Utilities standard. KSH-93 provides an enhanced programming environment in addition to the major command-entry features of the BSD shell "csh". With KSH-93, medium-sized programming tasks can be performed at shell-level without a significant loss in performance. In addition, "sh" scripts can be run on KSH-93 without modification.
EOF

(
    set -e
    echo "@name $PKGNAME-$VERSION"
    cd $SRCROOT
    find usr/pkg -type f
) > "meta/CONTENTS"

rm -rf "$PKGNAME-$VERSION.tgz"

pkg_create -v -B "meta/BUILD_INFO" -c "meta/COMMENT" -g wheel -u root -d "meta/DESC" -I / -f "meta/CONTENTS" -p "$SRCROOT" -F gzip "$PKGNAME-$VERSION.tgz"
