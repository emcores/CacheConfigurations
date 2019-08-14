FROM ubuntu:xenial
RUN apt-get update \
    &&  apt-get install -y wget git automake build-essential scons python-dev libprotobuf-dev python-protobuf protobuf-compiler libgoogle-perftools-dev

# From https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile (Aug 13, 2019)
# Julia dependencies
# install Julia packages in /opt/julia instead of $HOME
ENV JULIA_DEPOT_PATH=/opt/julia
ENV JULIA_PKGDIR=/opt/julia
ENV JULIA_VERSION=1.1.1

RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    echo "f0a83a139a89a2ccf2316814e5ee1c0c809fca02cbaf4baf3c1fd8eb71594f06 *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia
