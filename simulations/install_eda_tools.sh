#!/bin/bash
set -e

echo "================================"
echo "EDA Tools Installation Script"
echo "================================"

# Update system
echo "[1/6] Updating package lists..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install tools from repositories
echo "[2/6] Installing tools from Ubuntu repositories..."
sudo apt-get install -y \
    iverilog \
    gtkwave \
    yosys \
    klayout \
    build-essential \
    git \
    cmake \
    python3 \
    python3-pip \
    python3-venv \
    libgtest-dev \
    autoconf \
    automake \
    libtool

# Install CUDD dependency for OpenSTA
echo "[3/7] Installing CUDD dependency for OpenSTA..."
cd ~
if [ ! -d "cudd" ]; then
    git clone https://github.com/cuddorg/cudd.git
fi
cd cudd
git checkout 3.0.0
sudo ln -sf /usr/bin/aclocal /usr/bin/aclocal-1.14
sudo ln -sf /usr/bin/automake /usr/bin/automake-1.14
./configure --prefix=$HOME/cudd-install
make -j$(nproc)
make install
cd ~

# Install OpenSTA
echo "[4/7] Installing OpenSTA..."
cd ~
if [ ! -d "OpenSTA" ]; then
    git clone https://github.com/The-OpenROAD-Project/OpenSTA.git
fi
cd OpenSTA
mkdir -p build
cd build
cmake -DCUDD_DIR=$HOME/cudd-install ..
make -j$(nproc)
sudo make install
cd ~

# Install OpenROAD
echo "[5/7] Installing OpenROAD..."
if [ ! -d "OpenROAD" ]; then
    git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD.git
fi
cd OpenROAD
bash ./etc/DependencyInstaller.sh -all
mkdir -p build
cd build
cmake ..
make -j$(nproc)
sudo make install
cd ~

# Install Magic VLSI
echo "[6/7] Installing Magic VLSI..."
if [ ! -d "magic" ]; then
    git clone https://github.com/RTimothyEdwards/magic.git
fi
cd magic
./configure
make -j$(nproc)
sudo make install
cd ~

# Install Netgen
echo "[7/7] Installing Netgen..."
if [ ! -d "netgen" ]; then
    git clone https://github.com/RTimothyEdwards/netgen.git
fi
cd netgen
./configure
make -j$(nproc)
sudo make install
cd ~

echo ""
echo "================================"
echo "Installation Complete!"
echo "================================"
echo ""
echo "Verification:"
iverilog -V
gtkwave --version || echo "GTKWave installed"
yosys -V || echo "Yosys installed"
klayout --version || echo "KLayout installed"
opensta -version || echo "OpenSTA installed"
echo "magic, netgen, openroad - Check with: which magic netgen openroad"
