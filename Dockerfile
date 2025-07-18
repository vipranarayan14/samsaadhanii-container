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

SHELL ["/bin/bash", "-c"]

WORKDIR /app

# Download ZEN & SCL
RUN git clone https://gitlab.inria.fr/huet/Zen.git tmp_zen; \
    # TEMP FIX: Use a prev version of Zen since the latest changes 
    # causes dependency issues (ocamlfind missing) during build.
    cd tmp_zen && git checkout fba9c4571e2c91513de8d4e63098f5ca14c3cd95; \
    cd .. && git clone --depth 1 https://github.com/samsaadhanii/scl.git tmp_scl;

# Copy SPEC file
COPY spec.txt ./

# Setup SCL & ZEN
RUN set -eux; \
    SPEC_FILE="spec.txt"; \
    source "$SPEC_FILE"; \
    mv tmp_zen "$ZENINSTALLDIR"; \
    mv tmp_scl "$SCLINSTALLDIR"; \
    mv "$SPEC_FILE" "$SCLINSTALLDIR/"; \
    cd "$ZENINSTALLDIR/ML" && make; \
    cd "$SCLINSTALLDIR"; \
    ./configure && make && make install; \
    tar -cf "/app.tar" "$HTDOCSDIR" "$CGIDIR"



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

SHELL ["/bin/bash", "-c"]

WORKDIR /

# Copy app artifacts from build
RUN --mount=from=build,target=/artifacts \
    tar -xf "/artifacts/app.tar"

WORKDIR /app

# Enable cgid module in Apache and prevent apache 'ServerName` warning
RUN a2enmod cgid && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy entrypoint script
COPY --chmod=755 entrypoint.sh ./

# Expose Apache server port
EXPOSE 80

# Run Apache server when container starts
CMD ["./entrypoint.sh"]
