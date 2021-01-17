#!/bin/bash
docker build -t debian9-openmpi - < debian9/Dockerfile-debian9.openmpi
docker build -t debian9-mpas - < debian9/Dockerfile-debian9.mpas
docker build -t debian9-ncl - < debian9/Dockerfile-debian9.ncl