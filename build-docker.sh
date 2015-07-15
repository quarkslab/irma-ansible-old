#!/bin/bash


if [ "$1" = "probe" ]
then
    echo "[+] Building probe"
    cp ./docker/probe/Dockerfile .
    cp ./docker/probe/hosts/irma ./hosts/irma
    docker build -t "probe" .
elif [ "$1" = 'brain' ]
then
    echo "[+] Building brain"
    cp ./docker/brain/Dockerfile .
    cp ./docker/brain/hosts/irma ./hosts/irma
    docker build -t "brain" .
else
    echo "Usage:" $0 "[probe|brain]"
fi
