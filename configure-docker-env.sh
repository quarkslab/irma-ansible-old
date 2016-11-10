#!/bin/bash
# Run this script with argument "probe" or "brain", then run "docker build".


if [ "$1" = "probe" ]; then
    echo "[+] Configuring docker environment for probe"
    cp docker/probe/Dockerfile .
elif [ "$1" = 'brain' ]; then
    echo "[+] Configuring docker environment for brain"
    cp docker/brain/Dockerfile .
else
    echo "Usage:" $0 "[probe|brain]"
    exit 1
fi

if [ $? -ne 0 ]; then
    exit 1
fi

echo "Done. You can now run docker build."

exit 0
