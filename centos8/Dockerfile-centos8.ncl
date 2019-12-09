#Building NCL off of the MPAS Debian9 Dockerfile
#LA-UR-19-27938
#This will allow visual generation in the form of PDF's from output.nc files.
#Find "script.ncl" and run "ncl script.ncl" to generate an output.pdf


#Loading in the pre-build image mpas-debian9 from Dockerfile-debian9.mpas
FROM centos8-mpas

#Building dir for ncl and wget tarball, unzip, and delete tar
RUN mkdir /usr/local/ncl-6.6.2
WORKDIR /usr/local/ncl-6.6.2
RUN wget https://www.earthsystemgrid.org/dataset/ncl.662.dap/file/ncl_ncarg-6.6.2-Debian9.8_64bit_gnu630.tar.gz
RUN tar -xzf ncl_ncarg-6.6.2-Debian9.8_64bit_gnu630.tar.gz
RUN rm ncl_ncarg-6.6.2-Debian9.8_64bit_gnu630.tar.gz

#Required installs to run ncl installed with apt.
#Some installs are most likely redundent.
#This serves as a catch-all for what ncl needs.
RUN yum -y install csh            \
                   libfontconfig  \
                   gfortran       \
                   libgfortran3   \
                   libxrender-dev \
                   libx11-dev     \
                   libxrender1    \
                   libssh2-1      \
                   libgomp1       \
                   imagemagick

#Export variables for ncl to generate visual data files.
ENV NCARG_ROOT=/usr/local/ncl-6.6.2
ENV PATH=$NCARG_ROOT/bin:$PATH
ENV DISPLAY=:0

#Installation of metis for mesh-divison if not pre-generated.
WORKDIR /usr/local/src/metis-5.1.0
RUN DCMAKE_C_COMPILER=gcc gcc=/usr/local make config shared=1 cc=gcc


