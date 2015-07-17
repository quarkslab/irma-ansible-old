#!/bin/bash


if [ "$1" = "probe" ]
then
    echo "[+] Configuring docker environment for probe"
    cp ./docker/probe/Dockerfile .
    cp ./docker/probe/hosts/irma ./hosts/irma
elif [ "$1" = 'brain' ]
then
    echo "[+] Configuring docker environment for brain"
    cp ./docker/brain/Dockerfile .
    cp ./docker/brain/hosts/irma ./hosts/irma
else
    echo "Usage:" $0 "[probe|brain]"
    exit 1
fi

echo "Done. You can now run docker build ."

exit 0
