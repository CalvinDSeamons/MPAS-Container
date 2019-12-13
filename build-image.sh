#!/bin/bash

#Builds mpas container image in the the container directory.
#Choose centos8 or debian9

usage() {

echo "MPAS Build Script
      Options:
          * -os | -operatingsystem -- choose what os for your container. 
              Ex: ./build-image -os centos8

          * -tar | -tarball -- select if you just want a tarball.
              Ex: ./build-image -tar debian9

      Filesystem will be built in container/
          * The following command will place a user inside a running container:
              ch-run -w --unset-env=\"*\" --cd=/usr/local/src/ \\
              --set-env=/container/\$OS/ch/environment container/\$OS \\
              -- /bin/bash

      FYI: centos8 is 3x faster to build so i'd recommend that.
      "
}

fatal() {

echo Error: $1
exit 1

}

build-container() {
    #using ch, build-container build a places a debian9 or centos
    #images inside the container/ directory
    if [[ "$1" = "debian9" || "$1" = "centos8" ]]; then
        ch-build -t $1-openmpi -f $1/Dockerfile-$1.openmpi .
        ch-build -t $1-mpas    -f $1/Dockerfile-$1.mpas .

        ch-builder2tar $1-mpas /var/tmp

        ch-tar2dir /var/tmp/$1-mpas.tar.gz container/
    else
        fatal "Invalid Operating System (centos8 or debian9)"
    fi
}

build-only-tar(){
    #build-only-tar will just place a tar image of the container in container/
    if [[ "$1" = "debian9" || "$1" = "centos8" ]]; then
        ch-build -t $1-openmpi -f $1/Dockerfile-$1.openmpi .
        ch-build -t $1-mpas    -f $1/Dockerfile-$1.mpas .

        ch-builder2tar $1-mpas container/

    else
        fatal "Choose centos8 or debian9 for your OS in the tar."
    fi
}

run-container() {
    if [[ -d "container/$1-mpas" ]]; then
        ch-run -w \-\-set-env=container/$1-mpas/ch/environment \
            container/$1-mpas -- /bin/bash

    else
        fatal "Build image first with -os"

    fi

}

which ch-build
#if charliecloud is not installed error out
if [[ $? == 1 ]]; then
    fatal "Charliecloud is not installed, or not in PATH"
fi


#Loop through arguments
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
    -tar|-tarball)
        build-only-tar "$1"
        exit 0
        ;;
    -run)
        run-container "$1"
        exit 0
        ;;
    *)
        fatal "Unknown input $opt"
        ;;
    esac
done



