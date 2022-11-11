FROM ubuntu:20.04

ENV MAIN_DIR="/usr/src/scl"
ENV ZEN_MAIN_DIR="$MAIN_DIR/SKT/zen"
ENV SCL_MAIN_DIR="$MAIN_DIR/scl"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    # --no-install-recommends
    apache2 \
    bash \
    bison \
    camlp4 \
    default-jdk \
    flex \
    g++ \
    gcc \
    git \
    graphviz \
    lttoolbox \
    make \
    ocaml \
    ocamlbuild \
    perl \
    python3-pip \
    python3-pandas \
    python3-openpyxl \
    xsltproc \
    # && rm -rf /var/lib/apt/lists/*
    && pip3 install anytree

RUN git clone --depth 1 https://gitlab.inria.fr/huet/Zen.git "$ZEN_MAIN_DIR" \
    && git clone --depth 1 https://github.com/samsaadhanii/scl.git "$SCL_MAIN_DIR"

RUN cat "$SCL_MAIN_DIR/SPEC/spec_users.txt" | sed -E \
    -e "s|^(ZENDIR=).*$|\1$ZEN_MAIN_DIR/ML|" \
    -e "s|^(SCLINSTALLDIR=).*$|\1$SCL_MAIN_DIR|" \
    > "$SCL_MAIN_DIR/spec.txt"

WORKDIR "$ZEN_MAIN_DIR/ML"

RUN make && a2enmod cgid

WORKDIR "$SCL_MAIN_DIR"

RUN ./configure && make && make install

WORKDIR $MAIN_DIR

CMD ["apachectl", "-D", "FOREGROUND"]

EXPOSE 80