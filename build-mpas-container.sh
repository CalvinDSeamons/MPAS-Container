#!/bin/bash

#This calls ch-build and or grow.
~/charliecloud/bin/ch-build -t mpas-debian9 -f Dockerfile-debian9.mpas .
#This creates a tarball and places it in the tmp directory.
~/charliecloud/bin/ch-builder2tar mpas-debian9 /tmp
#Flattens the tar into a file image.
~/charliecloud/bin/ch-tar2dir /tmp/mpas-debian9.tar.gz .
