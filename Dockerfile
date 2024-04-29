FROM debian:9

ARG MAKE_JOBS=1

RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install --no-install-recommends -y  \
    autoconf \
    automake \
    bzip2 \
    g++ \
    gfortran \
    git \
    libatlas3-base \
    libtool-bin \
    make \
    patch \
    python-pip \
    python2.7 \
    python3 \
    sox \
    subversion \
    unzip \
    wget \
    zlib1g-dev && \
    apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove -y

RUN mkdir -p /opt/kaldi && \
    git clone https://github.com/kaldi-asr/kaldi /opt/kaldi && \
    cd /opt/kaldi && \
    git reset --hard e5a5a2869c0f91a5db1a9bb0d8ce06bffe82898d && \
    cd /opt/kaldi/tools && \
    bash extras/install_mkl.sh && \
    make -j${MAKE_JOBS} && \
    ./install_portaudio.sh && \
    cd /opt/kaldi/src && \
    ./configure --shared && \
    sed -i '/-g # -O0 -DKALDI_PARANOID/c\-O3 -DNDEBUG' kaldi.mk && \
    make -j${MAKE_JOBS} depend && \
    make -j${MAKE_JOBS} checkversion && \
    make -j${MAKE_JOBS} kaldi.mk && \
    make -j${MAKE_JOBS} mklibdir && \
    make -j${MAKE_JOBS} \
	base \
	bin \
	decoder \
	fstext \
	fstbin \
	nnet3 \
	online2 \
	util && \
    cd /opt/kaldi && git log -n1 > current-git-commit.txt && \
    rm -rf /opt/kaldi/.git && \
    rm -rf /opt/kaldi/windows/ /opt/kaldi/misc/ && \
    find /opt/kaldi/src/ \
	 -type f \
	 -not -name '*.h' \
	 -not -name '*.so' \
	 -not -executable \
	 -delete && \
    find /opt/kaldi/tools/ \
	 -type f \
	 -not -name '*.h' \
	 -not -name '*.so' \
	 -not -name '*.so*' \
	 -not -executable \
	 -delete
