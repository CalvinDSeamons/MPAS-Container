#!/bin/bash
#LA-UR-19-27938
#Download charliecloud
cd ~
git clone git@github.com:hpc/charliecloud.git
#Build the openmpi-no-ucx first
cd - #go back to MPAS_Container directory
~/charliecloud/bin/ch-build -t openmpi-no-ucx -f Dockerfile.openmpi .
#This calls ch-build and or grow.
~/charliecloud/bin/ch-build -t mpas-debian9 -f Dockerfile-debian9.mpas .
#This creates a tarball and places it in the tmp directory.
~/charliecloud/bin/ch-builder2tar mpas-debian9 /tmp
#Flattens the tar into a file image.
~/charliecloud/bin/ch-tar2dir /tmp/mpas-debian9.tar.gz .
