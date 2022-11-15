# image_version: 0.8.0

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

ENV SPEC_FILE="spec.txt"

COPY "$SPEC_FILE" /

# Setup scl & zen
RUN . "/$SPEC_FILE" \
    && git clone --depth 1 https://gitlab.inria.fr/huet/Zen.git "$ZENINSTALLDIR" \
    && git clone --depth 1 https://github.com/samsaadhanii/scl.git "$SCLINSTALLDIR" \
    && rm -rf "$ZENINSTALLDIR/.git/" "$SCLINSTALLDIR/.git/" \
    && cp "$SPEC_FILE" "$SCLINSTALLDIR/" \
    && cd "$ZENINSTALLDIR/ML" && make \
    && cd "$SCLINSTALLDIR" \
    && ./configure && make && make install \
    && rm -rv "e-readers/" "dhaatupaatha/" "GOLD_DATA/" \
    && tar -cf "/app.tar" "$APP_DIR" "$HTDOCSDIR" "$CGIDIR"



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

WORKDIR /

# Copy app artifacts from build
RUN --mount=from=build,target=/artifacts \
    tar -xf "/artifacts/app.tar"

# Enable cgid module in Apache and prevent apache 'ServerName` warning
RUN a2enmod cgid && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy entrypoint script
COPY --chmod=755 entrypoint.sh /

# Expose Apache server port
EXPOSE 80

# Run Apache server when container starts
CMD ["/entrypoint.sh"]
