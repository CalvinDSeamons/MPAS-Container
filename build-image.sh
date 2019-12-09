#!/bin/bash

#Builds mpas container image in the the container directory.
#Choose centos8 or debian9

usage() {

echo "MPAS Build Script
      Specify which os image you want with -os or --operatingsystem
          * Choose from debian9 or centos8

      Filesystem will be built in container/
          * Following command will place user inside running container:
              ch-run -w --unset-env=\"*\" --cd=/usr/local/src/ \\
              --set-env=/container/\$OS/ch/environment container/\$OS \\
              -- /bin/bash
      "
}

fatal() {

echo Error: $1
exit 1

}

build-container() {
    if [[ "$1" = "debian9" || "$1" = "centos8" ]]; then
        ch-build -t $1-openmpi -f $1/Dockerfile-$1.openmpi .
        ch-build -t $1-mpas    -f $1/Dockerfile-$1.mpas .

        ch-builder2tar $1-mpas /var/tmp

        ch-tar2dir /var/tmp/$1-mpas.tar.gz container/
    else
        fatal "Invalid Operating System (centos8 or debian9)"
    fi
}

which ch-build

if [[ $? == 1 ]]; then
    fatal "Charliecloud is not installed, or not in PATH"
fi

while [[ $# > 0 ]]; do
    opt="$1"; shift
    case $opt in
    -h|--help)
        usage
        exit 0
        ;;
    -os|--operatingsystem)
        build-container "$1"
        exit 0
        ;;
    *)
        fatal "Unknown input $opt"
        ;;
    esac
done



