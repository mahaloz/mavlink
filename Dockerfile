FROM ubuntu:18.04

USER root 
RUN apt-get update && apt-get install -y sudo sshfs bsdutils python-dev python-pip \
    libpq-dev pkg-config zlib1g-dev libtool libtool-bin wget automake autoconf coreutils bison libacl1-dev \
    llvm clang \
    build-essential git \
    libffi-dev cmake libreadline-dev libtool netcat net-tools 
RUN pip install future


# ----- mahaloz stuff ----- #
USER root
RUN apt-get update && apt-get install -y \
    tmux \
    xclip \
    vim

# ----- target ----- #
# get source
RUN git clone https://github.com/mahaloz/mavlink.git && cd mavlink && git submodule update --init --recursive && cd .. \
    && (cd mavlink/pymavlink/ && tools/mavgen.py --lang=C --wire-protocol=2.0 --output=../../generated/include/mavlink/v2.0 ../message_definitions/v1.0/common.xml) 

# reorient source
RUN mkdir fuzzing && mkdir fuzzing/src && mv generated fuzzing/ && cp mavlink/fuzzme.cpp fuzzing/src && cp mavlink/fuzz_CMakeLists.txt fuzzing/src/CMakeLists.txt 

# build the target
RUN cd fuzzing && cmake -Bbuild src && cmake && make && cp fuzzme /
