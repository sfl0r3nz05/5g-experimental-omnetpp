from ubuntu:latest as env-build                                                                                                                                               

run apt-get update && \                                                                                                                                                       
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install --no-install-recommends --yes \                                                                                 
    gcc g++ gdb bison flex make \                                                                                                                                          
    git python3 python3-pip python3-dev openscenegraph libopenscenegraph-dev curl \                                                                                        
    openmpi-bin libopenmpi-dev \                                                                                                                                          
    gdal-bin libgdal-dev minizip rocksdb-tools duktape cmake \                                                                                                            
    default-jre default-jdk openjfx \                                                                                                                                     
    swig doxygen graphviz libpcap-dev tcl qt5-default libqt5svg5 libqt5opengl5-dev \                                                                                       
    ffmpeg && \
    python3 -m pip install --upgrade pip && \
    pip install posix-ipc numpy scipy pandas matplotlib  && \
    rm -rf /var/lib/apt/lists/*

from env-build as omnetpp-build
shell ["/bin/bash", "-c"]
run curl -L https://github.com/omnetpp/omnetpp/releases/download/omnetpp-6.0pre11/omnetpp-6.0pre11-src-linux.tgz|tar -zxv &&\
    cd /omnetpp-6.0pre11 && \
    source ./setenv -f && ./configure WITH_OSGEARTH=no PREFER_CLANG=no && make

from env-build as inet-build
copy --from=omnetpp-build /omnetpp-6.0pre11 /omnetpp-6.0pre11
shell ["/bin/bash", "-c"]
run cd /omnetpp-6.0pre11 && source ./setenv -f && \
    curl -L https://github.com/inet-framework/inet/releases/download/v4.3.2/inet-4.3.2-src.tgz | tar -zxv -C /omnetpp-6.0pre11/samples && \
    cd /omnetpp-6.0pre11/samples/inet4.3 && \
    source ./setenv -f && make makefiles && make

from env-build as simu5g-build
copy --from=inet-build /omnetpp-6.0pre11 /omnetpp-6.0pre11
shell ["/bin/bash", "-c"]
run cd /omnetpp-6.0pre11 && source ./setenv -f && cd /omnetpp-6.0pre11/samples/inet4.3 && source ./setenv -f && \
    curl -L https://github.com/Unipisa/Simu5G/archive/refs/tags/v1.2.0.tar.gz | tar -zxv -C /omnetpp-6.0pre11/samples && \
    cd /omnetpp-6.0pre11/samples/Simu5G-1.2.0 && \
    source ./setenv -f && make makefiles && make

from env-build
label maintainer.name="Santiago"
label maintainer.email="sfigueroa@ceit.es"

copy --from=simu5g-build /omnetpp-6.0pre11 /omnetpp-6.0pre11
run chown -hR 1000 /omnetpp-6.0pre11

cmd ["/bin/bash"]