#!/usr/bin/env bash
wget https://download.fedoraproject.org/pub/fedora/linux/releases/38/Kinoite/x86_64/iso/Fedora-Kinoite-ostree-x86_64-38-1.6.iso -nc -P ../iso/
rm ../iso/Fedora-Kinoite-ostree-x86_64-38-1.6-custom.iso
./build_ks_iso.sh Fedora-Kinonite-ostree-x86_64 ../fedora-kinonite/ks.cfg ../iso/Fedora-Kinoite-ostree-x86_64-38-1.6.iso ../iso/Fedora-Kinoite-ostree-x86_64-38-1.6-custom.iso
