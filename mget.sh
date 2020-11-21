#!/bin/bash

#######################################################################
#
# mget v.1.0 (Multi-stream Get)
# Copyright 2020 Konstantin S. Vishnivetsky
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# For contacts:
# WEB: http://www.vishnivetsky.ru
# E-mail: net-projects@vishnivetsky.ru
# SkyPE: kvishnivetsky
# Phone: +7 913 774-7588
# Telegram: @kvishnivetsky
# SkyPE: @kvishnivetsky
#
#######################################################################

echo '== Start'

let PART_LENGTH=1024*1024*100 # 100Mb

URL="$1"
OUTPUT="$2"
if [ -z "${OUTPUT}" ]; then OUTPUT="file.out"; fi;

echo "== Let's try to download parts of [${PART_LENGTH}]"

curl -vLI "${URL}" | grep -P 'HTTP/1\.[10] 200' && (
    CONTENT_LENGTH_HEADER=`curl -vLI "${URL}" | grep 'Content-Length' | tr -d '\r\n'`
    CONTENT_LENGTH=`echo "${CONTENT_LENGTH_HEADER}" | awk -F' ' '{printf $2}'`
    echo "== File size is [${CONTENT_LENGTH}]"
    PART=0
    OFFSET=0
    while [ "${CONTENT_LENGTH}" -gt "${PART_LENGTH}" ]; do
	RANGE_START=${OFFSET}
	let RANGE_END=RANGE_START+PART_LENGTH-1
	echo "== Range: bytes=${RANGE_START}-${RANGE_END}"
	curl -sL "${URL}" -H"Range: bytes=${RANGE_START}-${RANGE_END}" -o "part.${PART}" &

	let PART=PART+1
	let OFFSET=OFFSET+PART_LENGTH
	let CONTENT_LENGTH=CONTENT_LENGTH-PART_LENGTH;
    done;
    if [ "${CONTENT_LENGTH}" -gt "0" ]; then
	echo "== Range: bytes=-${CONTENT_LENGTH}"
	curl -sL "${URL}" -H"Range: bytes=-${CONTENT_LENGTH}" -o "part.${PART}" &
	let PART=PART+1
    fi;
    echo "== Waiting for ${PART} processes"
    while ps ax | grep -v 'grep' | grep -v 'mget' | grep "${URL}" > /dev/null ; do sleep 1; done;
    echo '== Concatinating file'
    p=0
    while [ "${PART}" -gt "0" ]; do
	echo "== Add part ${p}";
	cat part.${p} >> ${OUTPUT};
	rm -f part.${p};
	let PART=PART-1
	let p=p+1
    done
    md5sum ${OUTPUT}
    echo '== End'
)
