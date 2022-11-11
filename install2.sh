#!/bin/bash

# Installation paths
MAIN_DIR="$HOME/scl"
ZEN_MAIN_DIR="$MAIN_DIR/SKT/zen"
SCL_MAIN_DIR="$MAIN_DIR/scl"


echo -e "\n=== Updating system packages ===\n"


# Update system package repositories and packages
apt update


echo -e "\n=== Installing prerequisites ===\n"


# Install prerequisite system packages
apt install -y \
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
xsltproc

# Install prerequisite python packages
pip3 install anytree


echo -e "\n=== Downloading SCL & Dependencies ===\n"


# Creating main installation dir
mkdir $MAIN_DIR

# Download Zen
git clone --depth 1 https://gitlab.inria.fr/huet/Zen.git "$ZEN_MAIN_DIR"

echo -e "\n"

# # Download SCL
# git clone --depth 1 https://github.com/samsaadhanii/scl.git "$SCL_MAIN_DIR"


# echo -e "\n=== Installing SCL ===\n"


# if [ ! -d "$ZEN_MAIN_DIR/ML" ] || [ ! -d "$SCL_MAIN_DIR" ]; then 
#     echo "Missing dependencies. Installation failed."
#     exit 1
# fi

# # Setup Zen
# cd "$ZEN_MAIN_DIR/ML"

# make

# a2enmod cgid
# systemctl restart apache2

# # Install SCL
# cd "$SCL_MAIN_DIR"

# cat "$SCL_MAIN_DIR/SPEC/spec_users.txt" \
# | sed -E \
#     -e "s|^(ZENDIR=).*$|\1$ZEN_MAIN_DIR/ML|" \
#     -e "s|^(SCLINSTALLDIR=).*$|\1$SCL_MAIN_DIR|" \
# > "$SCL_MAIN_DIR/spec.txt"

# ./configure

# make

# make install

echo -e "\nInstalled SCL Successfully."
echo -e "\nOpen http://localhost/scl/ in your browser.\n"
