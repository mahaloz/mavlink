FROM ubuntu:18.04 as builder

USER root 
RUN apt-get update && apt-get install -y sudo sshfs bsdutils python-dev python-pip \
    libpq-dev pkg-config zlib1g-dev libtool libtool-bin wget automake autoconf coreutils bison libacl1-dev \
    llvm clang \
    build-essential git \
    libffi-dev cmake libreadline-dev libtool netcat net-tools vim
RUN pip install future

# ----- target ----- #
# get source
COPY . /mavlink
RUN cd /mavlink && git submodule update --init --recursive && cd .. \
    && (cd mavlink/pymavlink/ && tools/mavgen.py --lang=C --wire-protocol=2.0 --output=../../generated/include/mavlink/v2.0 ../message_definitions/v1.0/common.xml) 

# build the target
RUN cp /mavlink/tests/fuzz_assembled_message.cpp / && \
    clang++ -I generated/include/mavlink/v2.0 -fsanitize=fuzzer,address,undefined fuzz_assembled_message.cpp -o fuzz_assembled_message
    
FROM ubuntu:18.04

COPY --from=builder /fuzz_assembled_message /
