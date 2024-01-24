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
# $Id: package.sh 40 2021-05-03 18:03:59Z rhubarb-geek-nz $
#

cleanup()
{
	rm -rf ksh93-code data meta
}

trap cleanup 0

if test ! -d ksh93-code
then
	(
		set -e

		git clone https://github.com/ksh93/ksh.git ksh93-code

		cd ksh93-code

		bin/package make	
	)
fi

rm -rf data meta

PKGNAME=ksh93
VERSION=93.u_1

ls -ld ksh93-code/arch/*/src/cmd/ksh93/ksh 

test 1 = $(ls ksh93-code/arch/*/src/cmd/ksh93/ksh | wc -l)

mkdir -p data/usr/local/bin data/usr/local/man/man1

cp ksh93-code/arch/*/src/cmd/ksh93/ksh data/usr/local/bin/ksh93

cp ksh93-code/src/cmd/ksh93/sh.1 data/usr/local/man/man1/ksh93.1

gzip data/usr/local/man/man1/ksh93.1

mkdir meta

(
	set -ex
	cd data/usr/local
	find * -type f	
) > meta/PLIST

cat > meta/MANIFEST << EOF
name $PKGNAME
version $VERSION
licenses: [
    "EPL"
]
categories: [
    "shells"
]
desc <<EOD
KSH-93 is the most recent version of the KornShell Language described in "The KornShell Command and Programming Language," by Morris Bolsky and David Korn of AT&T Bell Laboratories, ISBN 0-13-182700-6. The KornShell is a shell programming language, which is upward compatible with "sh" (the Bourne Shell), and is intended to conform to the IEEE P1003.2/ISO 9945.2 Shell and Utilities standard. KSH-93 provides an enhanced programming environment in addition to the major command-entry features of the BSD shell "csh". With KSH-93, medium-sized programming tasks can be performed at shell-level without a significant loss in performance. In addition, "sh" scripts can be run on KSH-93 without modification.
EOD
www https://github.com/ksh93/ksh.git
origin shells/ksh93
comment KornShell 93u+m
maintainer rhubarb-geek-nz@users.sourceforge.net
prefix /usr/local
EOF

pkg create -m meta/MANIFEST -o . -r data -v -p meta/PLIST
