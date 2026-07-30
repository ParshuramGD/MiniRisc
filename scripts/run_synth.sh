#!/usr/bin/env bash
#=========================================================
# MiniRISC Yosys Synthesis Runner
#=========================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

#---------------------------------------------------------
# Check PDK_ROOT
#---------------------------------------------------------
if [ -z "$PDK_ROOT" ]; then
    echo "ERROR: PDK_ROOT is not set."
    echo
    echo "Example:"
    echo "export PDK_ROOT=\$HOME/pdk/share/pdk/sky130A"
    exit 1
fi

#---------------------------------------------------------
# SKY130 Liberty
#---------------------------------------------------------
LIBPATH="$PDK_ROOT/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

if [ ! -f "$LIBPATH" ]; then
    echo "ERROR: Liberty file not found:"
    echo "$LIBPATH"
    exit 1
fi

echo "Using Liberty:"
echo "  $LIBPATH"

#---------------------------------------------------------
# Create output directories
#---------------------------------------------------------
mkdir -p "$ROOT_DIR/build"
mkdir -p "$ROOT_DIR/results"

#---------------------------------------------------------
# Generate synthesis script
#---------------------------------------------------------
sed "s|@@LIBPATH@@|$LIBPATH|g" \
    "$ROOT_DIR/scripts/synth.ys" \
    > "$ROOT_DIR/build/synth_run.ys"

#---------------------------------------------------------
# Run Yosys
#---------------------------------------------------------
yosys -s "$ROOT_DIR/build/synth_run.ys" | tee "$ROOT_DIR/build/yosys.log"

echo
echo "======================================"
echo "Synthesis completed successfully."
echo "Results:"
echo "  results/top_cpu.json"
echo "  results/top_cpu_synth.v"
echo "  results/top_cpu_mapped.v"
echo "  build/yosys.log"
echo "======================================"