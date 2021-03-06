# Making Atmospheric Modeling Software (MPAS) Containerized  
LA-UR-19-27938

### Instructions 
***
1) Download charliecloud at <https://github.com/hpc/charliecloud>. This lightweight container builder and runtime is a fantastic choice if you're starting to look into containers. Any runtime that reads Dockerfiles should be fine, but note the rest of these instruction wont relate anymore. 

2) ```cd``` into the `MPAS-Container` directory you cloned (clone this repository). 

3) Build the openmpi image `openmpi-no-ucx` with the following command:  
    ```~/$path_to_charliecloud/charliecloud/bin/ch-build -t openmpi-no-ucx -f Dockerfile.openmpi .```
    
4) Now build the mpas container with the following command:  
    ```~/$path_to_charliecloud/charliecloud/bin/ch-build -t mpas_container -f Dockerfile-debian9.mpas .```
    
5) You can compress the image into a tar with:  
    ```~/path_to_charliecloud/charliecloud/bin/builder2tar mpas_container /tmp```  
    You can now `scp` this tar onto a machine with the same architecture and run the container there,  or where you built it.
    
6) To unpack the tar run the following: ```~/charliecloud/bin/ch-tar2dir /tmp/mpas_container.tar.gz .```  
    This will flatten the tar into a file system image in your current context directory. 
    
7) Look at `Running Simulation Tests with MPAS` below to run actual MPAS simulations. 
    
8) If you dont want to do all this the `build-mpas-container.sh` will do it for you. Run `./build-mpas-container` from within the MPAS-Container directory. 

9) To generate visual data build the `Dockerfile.ncl`.

10) Alternatively just run ```./build-image.sh -os centos8``` or ```./build-image.sh -os debian9```


### Abstract
***
High performance computing (HPC) scientific applications require complex dependencies, many of which are not supplied by the Linux operating system.
Typically, HPC centers offer these dependencies through environment module-files that when loaded, modify 
the user environment to provide access to software installations. If a package doesn’t exist on a system,
customers must request them through system administrators or find alternatives. It is unrealistic for HPC 
centers to provide every unique dependency requested, thus the interest for user defined software stacks 
and containers are increasing. By building Model for Prediction Across Scales (MPAS) and its dependencies 
inside a Debian GNU/Linux 9 container image, we demonstrate that a common atmospheric simulation runs nearly 
identically on a Red Hat Enterprise Linux 7 Commodity Technology System (CTS1) cluster with the Intel® Core 
Broadwell™ architecture and a Cray System with the SuSE Enterprise Linux 12 + Cray Linux Environment (CLEv6.0) 
and an Intel® Core Haswell™ architecture, with minimal modifications to the container. This shows that it is possible 
to build complex software applications inside an unprivileged container and run it successfully across various super computers 
with different hardware components, Linux operating systems, and environments. Furthermore, the application computational
results from their execution are essentially identical with 28 bytes differing between 2.1GB output files. Containers offer 
customers versatility with nominal dependencies on the system they run on. This advancement potentially allows for 
tremendous portability across Linux HPC systems; by encapsulating complex dependencies it gives scientists the ability
to run large scale simulations on HPC resources with their own preferred software. 





### Running Simulation Tests with MPAS
***
1) Download an MPAS test at <https://mpas-dev.github.io/atmosphere/test_cases.html> There should be 3 options `supercell` `mountain_wave` and `baroclinic_wave`

2) Place the following MPAS-test folders in `/usr/local/src` inside the container image

3) In MPAS7.0 top level directory generate the atmospheric cores with:  
    `RUN PIO=/usr/local NETCDF=/usr/local PNETCDF=/usr/local make gfortran CORE=init_atmosphere USE_PIO2=true DEBUG=true PRECISION=single`  
     Save the core `init_atmosphere_model` in another directory then run `make clean CORE=init_atmosphere` and run  
    `RUN PIO=/usr/local NETCDF=/usr/local PNETCDF=/usr/local make gfortran CORE=atmosphere USE_PIO2=true DEBUG=true PRECISION=single`  
    This will generate your ```atmosphere_model``` which you will also want to save

4) Copy both cores into the simulation test you ran or sym link them with example `ln -s /usr/local/src/MPAS-Model-7.0/init_atmosphere_model /usr/local/src/supercell`


5) Run `./init_atmosphere_model` to generate an init.nc and then you can run `./atmosphere_model`



### A Note on Multi Node Runs Using OMPI
***
1) If using charlecloud go into `charliecloud/tests/` and edit the file `Dockerfile.openmpi`  
2) Reflect changes as seen in Dockerfile.openmpi in this repo or copy this one into `charliecloud/tests`
3) Rebuild the openmpi image with `ch-grow -t openmpi-no-ucx -f Dockerfile.openmpi` the openmpi-no-ucx corresponds to the `FROM openmpi-no-ucx` in the MPAS dockerfile.
        Note. Probably a good idea to make a charliecloud branch and add this fix.
4) Add the following line in `streams.$simulation-name` inside the output tags. clobber_mode="apend". This will let multi nodes write to the same output file without issue. 

All MPAS test simulations [Supercell, Mountainwave] are capped at 32 ranks and cannot be exceeded.

