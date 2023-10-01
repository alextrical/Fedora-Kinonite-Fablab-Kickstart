#!/usr/bin/env bash

set -o errexit

if [ "${#}" -lt 4 ]
then
    echo 'Usage: ./build_ks_iso.sh ${VOLUME_LABEL} ${KS_PATH} ${ISO_INPUT_PATH} ${ISO_OUTPUT_PATH}'
    exit 1
fi

VOLUME_LABEL=${1}
KS_PATH=${2}
ISO_INPUT_PATH=${3}
ISO_OUTPUT_PATH=${4}

trap "cleanup" ERR

cleanup () {
    [ -e ${ISO_OUTPUT_PATH} ] && rm -- ${ISO_OUTPUT_PATH}
}

./mkksiso -V ${VOLUME_LABEL} --ks ${KS_PATH} ${ISO_INPUT_PATH} ${ISO_OUTPUT_PATH} --no-md5sum
implantisomd5 ${ISO_OUTPUT_PATH}
