ARG MAIN_DIR="/usr/src/samsaadhanii"
ARG WEB_DIR="/var/www/html"
ARG CGI_DIR="/usr/lib/cgi-bin"

# STAGE1: Download build deps and make app 

FROM ubuntu:20.04 AS build

# Install build deps
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    bash \
    bison \
    camlp4 \
    default-jdk-headless \
    flex \
    libfl-dev \
    g++ \
    gcc \
    git \
    make \
    ocaml \
    ocamlbuild

ARG MAIN_DIR
ARG WEB_DIR
ARG CGI_DIR
ARG ZEN_MAIN_DIR="$MAIN_DIR/SKT/zen"
ARG SCL_MAIN_DIR="$MAIN_DIR/scl"

# Download scl & zen
RUN git clone --depth 1 https://gitlab.inria.fr/huet/Zen.git "$ZEN_MAIN_DIR" \
    && git clone --depth 1 https://github.com/samsaadhanii/scl.git "$SCL_MAIN_DIR" \
    && rm -rf "$ZEN_MAIN_DIR/.git/" "$SCL_MAIN_DIR/.git/"

# Compose spec.txt
RUN cat "$SCL_MAIN_DIR/SPEC/spec_users.txt" | sed -E \
    -e "s|^(ZENDIR=).*$|\1$ZEN_MAIN_DIR/ML|" \
    -e "s|^(SCLINSTALLDIR=).*$|\1$SCL_MAIN_DIR|" \
    -e "s|^(HTDOCSDIR=).*$|\1$WEB_DIR|" \
    -e "s|^(CGIDIR=).*$|\1$CGI_DIR/|" \
    > "$SCL_MAIN_DIR/spec.txt"

# Make zen
WORKDIR "$ZEN_MAIN_DIR/ML"
RUN make

# Make scl
WORKDIR "$SCL_MAIN_DIR"
RUN ./configure && make && make install



# STAGE2: Copy app artifacts and create final image with runtime deps

FROM ubuntu:20.04

# Install runtime deps
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    apache2 \
    bash \
    default-jre-headless \
    graphviz \
    lttoolbox \
    perl \
    python3 \
    python3-pip \
    python3-pandas \
    python3-openpyxl \
    xsltproc \
    && pip3 install anytree \
    && rm -rf /var/lib/apt/lists/*

ARG MAIN_DIR
ARG WEB_DIR
ARG CGI_DIR

# Copy artifacts from build image
COPY --from=build "$MAIN_DIR" "$MAIN_DIR"
COPY --from=build "$WEB_DIR" "$WEB_DIR"
COPY --from=build "$CGI_DIR" "$CGI_DIR"

WORKDIR /

# Enable cgid module in Apache
RUN a2enmod cgid

# Expose Apache server port
EXPOSE 80

# Run Apache server when container starts
CMD ["apachectl", "-D", "FOREGROUND"]
