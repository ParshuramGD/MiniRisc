#!/usr/bin/env bash
# =============================================================
# MiniRISC PDK Fix + RTL→GDS Flow Driver
# =============================================================
# Fixes the broken sky130_fd_sc_hd installation, then runs the
# complete RTL→GDS flow:
#   Yosys → OpenSTA → OpenROAD (floor/place/cts/route) →
#   Magic (GDS) → Magic (DRC) → Netgen (LVS)
#
# Run from the project root:
#   cd ~/path/to/Minirisc
#   bash scripts/fix_pdk_and_flow.sh 2>&1 | tee flow.log
# =============================================================

set -euo pipefail

# ── colour helpers ─────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
step()  { echo -e "\n${BOLD}${BLUE}══════════════════════════════════════${NC}"; \
          echo -e "${BOLD}${BLUE}  $*${NC}"; \
          echo -e "${BOLD}${BLUE}══════════════════════════════════════${NC}"; }
ok()    { echo -e "${GREEN}✔ $*${NC}"; }
warn()  { echo -e "${YELLOW}⚠ $*${NC}"; }
die()   { echo -e "${RED}✘ FATAL: $*${NC}" >&2; exit 1; }

# ── Project paths ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$ROOT/build"
RESULTS_DIR="$ROOT/results"

# ── PDK paths ──────────────────────────────────────────────
OPEN_PDKS="$HOME/open_pdks"
PDK_ROOT="$HOME/pdk/share/pdk/sky130A"
HD_LIBDIR="$PDK_ROOT/libs.ref/sky130_fd_sc_hd/lib"
TT_LIB="$HD_LIBDIR/sky130_fd_sc_hd__tt_025C_1v80.lib"
HD_LEF="$PDK_ROOT/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
HD_TLEF="$PDK_ROOT/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"
HD_SPICE="$PDK_ROOT/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice"

export PDK_ROOT

mkdir -p "$BUILD_DIR" "$RESULTS_DIR"

# =============================================================
# STEP 1 – Check / Upgrade Magic
# =============================================================
step "STEP 1: Verify Magic version (need ≥ 8.3.250)"

MAGIC_VER="$(magic --version 2>/dev/null | tr -d '[:alpha:]' | xargs)"
MAGIC_MINOR="$(echo "$MAGIC_VER" | cut -d. -f2)"
MAGIC_PATCH="$(echo "$MAGIC_VER" | cut -d. -f3)"
echo "Installed Magic: $MAGIC_VER (minor=$MAGIC_MINOR patch=$MAGIC_PATCH)"

needs_upgrade=0
if [ "$MAGIC_MINOR" -lt 3 ]; then
    needs_upgrade=1
elif [ "$MAGIC_MINOR" -eq 3 ] && [ "${MAGIC_PATCH:-0}" -lt 250 ]; then
    needs_upgrade=1
fi

if [ "$needs_upgrade" -eq 1 ]; then
    warn "Magic $MAGIC_VER is too old — upgrading from source"

    # Install build dependencies
    sudo apt-get install -y \
        build-essential tcl-dev tk-dev libcairo2-dev \
        libncurses-dev libglu1-mesa-dev freeglut3-dev \
        mesa-common-dev m4 csh libx11-dev

    MAGIC_SRC="$HOME/magic_src"
    if [ -d "$MAGIC_SRC" ]; then
        echo "Updating existing magic_src clone"
        git -C "$MAGIC_SRC" fetch --prune
        git -C "$MAGIC_SRC" checkout master
        git -C "$MAGIC_SRC" pull
    else
        git clone https://github.com/RTimothyEdwards/magic.git "$MAGIC_SRC"
    fi

    cd "$MAGIC_SRC"
    # Checkout latest stable 8.3 tag
    LATEST_TAG="$(git tag | grep '^8\.3' | sort -V | tail -1)"
    echo "Checking out tag: $LATEST_TAG"
    git checkout "$LATEST_TAG"

    ./configure --prefix=/usr/local
    make -j"$(nproc)"
    sudo make install

    NEW_VER="$(magic --version 2>/dev/null)"
    ok "Magic upgraded to $NEW_VER"
    cd "$ROOT"
else
    ok "Magic $MAGIC_VER — OK"
fi

# =============================================================
# STEP 2 – Re-stage only sky130_fd_sc_hd (digital-hd-A target)
# =============================================================
step "STEP 2: Re-stage sky130_fd_sc_hd"

if [ -f "$TT_LIB" ]; then
    ok "Liberty already installed — skipping re-staging"
else
    echo "Liberty missing — running digital-hd-A staging target"

    # Clean only the hd staging dir so other libs are not re-staged
    STAGING_HD="$OPEN_PDKS/sky130/sky130A/libs.ref/sky130_fd_sc_hd"
    echo "Cleaning incomplete staging dir: $STAGING_HD"
    rm -rf "$STAGING_HD"
    mkdir -p "$STAGING_HD"

    cd "$OPEN_PDKS/sky130"

    # Run single-thread to avoid parallel magic races
    make -j1 digital-hd-A 2>&1 | tee "$OPEN_PDKS/sky130/sky130A_hd_restage.log"
    RC=${PIPESTATUS[0]}
    if [ "$RC" -ne 0 ]; then
        die "digital-hd-A staging failed (exit $RC). Check $OPEN_PDKS/sky130/sky130A_hd_restage.log"
    fi
    ok "sky130_fd_sc_hd staging complete"

    # Re-run install for sky130A
    echo "Re-running make install for sky130A"
    make -j1 install-A 2>&1 | tee "$OPEN_PDKS/sky130/sky130A_hd_reinstall.log"
    RC=${PIPESTATUS[0]}
    if [ "$RC" -ne 0 ]; then
        die "make install-A failed (exit $RC). Check $OPEN_PDKS/sky130/sky130A_hd_reinstall.log"
    fi
    ok "PDK install-A complete"
    cd "$ROOT"
fi

# =============================================================
# STEP 3 – Verify PDK files
# =============================================================
step "STEP 3: Verify PDK installation"

check_file() {
    local f="$1"
    if [ -f "$f" ]; then
        ok "$f"
    else
        die "Required file missing: $f"
    fi
}

check_file "$TT_LIB"
check_file "$HD_LEF"
check_file "$HD_SPICE"

# Techlef (nom)
TLEF_FILE="$(find "$PDK_ROOT/libs.ref/sky130_fd_sc_hd/techlef" -name '*nom*.tlef' 2>/dev/null | head -1)"
if [ -z "$TLEF_FILE" ]; then
    TLEF_FILE="$(find "$PDK_ROOT/libs.ref/sky130_fd_sc_hd/techlef" -name '*.tlef' 2>/dev/null | head -1)"
fi
[ -n "$TLEF_FILE" ] && ok "techlef: $TLEF_FILE" || die "No techlef found for sky130_fd_sc_hd"
HD_TLEF="$TLEF_FILE"

ok "PDK verification passed"
echo "  TT Liberty : $TT_LIB"
echo "  LEF        : $HD_LEF"
echo "  TechLEF    : $HD_TLEF"
echo "  SPICE      : $HD_SPICE"

# =============================================================
# STEP 4 – RTL Synthesis (Yosys + ABC)
# =============================================================
step "STEP 4: RTL Synthesis (Yosys + ABC)"

# Generate Yosys script with actual Liberty path
sed "s|@@LIBPATH@@|$TT_LIB|g" \
    "$ROOT/scripts/synth.ys" \
    > "$BUILD_DIR/synth_run.ys"

yosys -s "$BUILD_DIR/synth_run.ys" 2>&1 | tee "$BUILD_DIR/yosys.log"
RC=${PIPESTATUS[0]}
[ "$RC" -ne 0 ] && die "Yosys failed (exit $RC)"

# Verify mapped netlist was produced
[ -f "$RESULTS_DIR/top_cpu_mapped.v" ] || die "top_cpu_mapped.v not generated"

# Verify SKY130 cells appear in mapped netlist
if grep -q 'sky130_fd_sc_hd__' "$RESULTS_DIR/top_cpu_mapped.v"; then
    ok "Mapped netlist contains SKY130 HD cells"
else
    die "Mapped netlist does NOT contain SKY130 cells — tech mapping failed"
fi

ok "Synthesis complete → $RESULTS_DIR/top_cpu_mapped.v"

# =============================================================
# STEP 5 – Install OpenROAD (if missing)
# =============================================================
step "STEP 5: Check / Install OpenROAD"

if command -v openroad &>/dev/null; then
    ORVER="$(openroad -version 2>&1 | head -1)"
    ok "OpenROAD already installed: $ORVER"
else
    warn "OpenROAD not found — installing from OpenROAD-flow-scripts binary"

    # Try official binary from GitHub releases (Ubuntu 22.04 / 24.04)
    OS_VER="$(lsb_release -rs 2>/dev/null || echo 22.04)"
    DISTRO="$(lsb_release -cs 2>/dev/null || echo jammy)"

    # Use the official OpenROAD binary package
    ORTOOLS_DEB="$HOME/openroad_install"
    mkdir -p "$ORTOOLS_DEB"

    echo "Fetching latest OpenROAD release info..."
    OR_RELEASE_URL="https://github.com/Precision-Innovations/OpenROAD/releases/latest"
    # Use the official prebuilt from OpenROAD-flow-scripts
    # Fallback: build from source if binary not available

    # First try: apt-based install for Ubuntu 22/24
    sudo apt-get install -y wget curl gnupg2 lsb-release

    # OpenROAD daily build from ORFS
    OR_DEB_URL="https://github.com/The-OpenROAD-Project/OpenROAD/releases/download/v3.0.0/openroad_Ubuntu22.04_amd64.deb"
    OR_DEB_FILE="$ORTOOLS_DEB/openroad.deb"

    echo "Downloading OpenROAD v3.0.0 binary package..."
    if wget -q --show-progress -O "$OR_DEB_FILE" "$OR_DEB_URL" 2>&1; then
        sudo apt-get install -y "$OR_DEB_FILE" || sudo dpkg -i "$OR_DEB_FILE" || true
        sudo apt-get install -f -y
        if command -v openroad &>/dev/null; then
            ok "OpenROAD installed via deb: $(openroad -version 2>&1 | head -1)"
        else
            warn "deb install failed — building OpenROAD from source"
            build_openroad_from_source
        fi
    else
        warn "Binary download failed — building from source (this will take 30–60 min)"
        build_openroad_from_source
    fi
fi

build_openroad_from_source() {
    OR_SRC="$HOME/OpenROAD"
    if [ ! -d "$OR_SRC" ]; then
        git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD.git "$OR_SRC"
    else
        git -C "$OR_SRC" submodule update --init --recursive
    fi
    cd "$OR_SRC"
    bash ./etc/DependencyInstaller.sh -run
    mkdir -p build && cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j"$(nproc)"
    sudo make install
    cd "$ROOT"
    ok "OpenROAD built from source: $(openroad -version 2>&1 | head -1)"
}

command -v openroad &>/dev/null || die "OpenROAD installation failed"

# =============================================================
# STEP 6 – OpenSTA Timing Analysis
# =============================================================
step "STEP 6: OpenSTA Timing Analysis"

STA_SCRIPT="$BUILD_DIR/run_sta.tcl"
STA_LOG="$RESULTS_DIR/sta_timing.rpt"

# Detect Verilog blackbox (for STA)
BLACKBOX_V="$(find "$PDK_ROOT/libs.ref/sky130_fd_sc_hd/verilog" \
    -name 'sky130_fd_sc_hd__blackbox.v' 2>/dev/null | head -1)"
[ -z "$BLACKBOX_V" ] && BLACKBOX_V="$PDK_ROOT/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"

cat > "$STA_SCRIPT" << STA_EOF
# =============================================================
# MiniRISC OpenSTA Timing Script
# =============================================================
read_liberty $TT_LIB
read_verilog $RESULTS_DIR/top_cpu_mapped.v
link_design top_cpu

create_clock -name clk -period 10.0 [get_ports clk]
set_input_delay  2.0 -clock clk [all_inputs]
set_output_delay 2.0 -clock clk [all_outputs]

report_checks -path_delay max -digits 4 -format full_clock_expanded
report_checks -path_delay min -digits 4
report_tns
report_wns
report_check_types -max_slew -max_capacitance -max_fanout
report_power
report_design_area

puts "STA complete."
exit
STA_EOF

sta -no_init -exit "$STA_SCRIPT" 2>&1 | tee "$STA_LOG"
RC=${PIPESTATUS[0]}
[ "$RC" -ne 0 ] && warn "STA returned non-zero ($RC) — check $STA_LOG but continuing"

if grep -q "slack" "$STA_LOG" 2>/dev/null; then
    ok "STA timing report generated: $STA_LOG"
    # Print WNS/TNS
    grep -E "^(wns|tns|worst slack)" "$STA_LOG" 2>/dev/null | head -5 || true
else
    warn "STA report may be incomplete — continuing"
fi

# =============================================================
# STEP 7 – OpenROAD: Floorplan → Place → CTS → Route → GDS
# =============================================================
step "STEP 7: OpenROAD P&R Flow"

OR_DIR="$BUILD_DIR/openroad"
mkdir -p "$OR_DIR"

# Detect design parameters from synthesis output
NETLIST="$RESULTS_DIR/top_cpu_mapped.v"

# ── 7a: Floorplan ──────────────────────────────────────────
step "STEP 7a: Floorplan"

FP_SCRIPT="$OR_DIR/floorplan.tcl"
FP_DEF="$OR_DIR/floorplan.def"

cat > "$FP_SCRIPT" << FP_EOF
# =========================================================
# MiniRISC OpenROAD Floorplan
# =========================================================
read_lef $HD_TLEF
read_lef $HD_LEF

read_liberty $TT_LIB

read_verilog $NETLIST
link_design top_cpu

# Initialize floorplan: utilization 50%, aspect ratio 1.0
initialize_floorplan \\
    -die_area  {0 0 500 500} \\
    -core_area {10 10 490 490} \\
    -site       unithd

# Place IO pins
place_pins -hor_layers met3 -ver_layers met2

# Insert tap cells
tapcell \\
    -tapcell_master sky130_fd_sc_hd__tapvpwrvgnd_1 \\
    -endcap_master  sky130_fd_sc_hd__decap_3 \\
    -distance 14

write_def $FP_DEF
puts "Floorplan complete: $FP_DEF"
exit
FP_EOF

openroad -exit "$FP_SCRIPT" 2>&1 | tee "$OR_DIR/floorplan.log"
RC=${PIPESTATUS[0]}
[ "$RC" -ne 0 ] && die "Floorplan failed (exit $RC) — see $OR_DIR/floorplan.log"
[ -f "$FP_DEF" ] || die "Floorplan DEF not generated"
ok "Floorplan → $FP_DEF"

# ── 7b: Placement ──────────────────────────────────────────
step "STEP 7b: Global + Detailed Placement"

PL_SCRIPT="$OR_DIR/place.tcl"
PL_DEF="$OR_DIR/place.def"

cat > "$PL_SCRIPT" << PL_EOF
read_lef $HD_TLEF
read_lef $HD_LEF
read_liberty $TT_LIB
read_def $FP_DEF

set_wire_rc -layer met2

# Global placement
global_placement -density 0.6

# Legalization
legalize_placement

# Detailed placement
detailed_placement

check_placement -verbose

write_def $PL_DEF
puts "Placement complete: $PL_DEF"
exit
PL_EOF

openroad -exit "$PL_SCRIPT" 2>&1 | tee "$OR_DIR/place.log"
RC=${PIPESTATUS[0]}
[ "$RC" -ne 0 ] && die "Placement failed (exit $RC) — see $OR_DIR/place.log"
[ -f "$PL_DEF" ] || die "Placement DEF not generated"
ok "Placement → $PL_DEF"

# ── 7c: Clock Tree Synthesis ───────────────────────────────
step "STEP 7c: Clock Tree Synthesis"

CTS_SCRIPT="$OR_DIR/cts.tcl"
CTS_DEF="$OR_DIR/cts.def"

cat > "$CTS_SCRIPT" << CTS_EOF
read_lef $HD_TLEF
read_lef $HD_LEF
read_liberty $TT_LIB
read_def $PL_DEF

# CTS
clock_tree_synthesis \\
    -root_buf  sky130_fd_sc_hd__clkbuf_16 \\
    -clk_buffers sky130_fd_sc_hd__clkbuf_1,sky130_fd_sc_hd__clkbuf_2,sky130_fd_sc_hd__clkbuf_4,sky130_fd_sc_hd__clkbuf_8,sky130_fd_sc_hd__clkbuf_16 \\
    -sink_clustering_enable

set_propagated_clock [all_clocks]
estimate_parasitics -placement

write_def $CTS_DEF
puts "CTS complete: $CTS_DEF"
exit
CTS_EOF

openroad -exit "$CTS_SCRIPT" 2>&1 | tee "$OR_DIR/cts.log"
RC=${PIPESTATUS[0]}
[ "$RC" -ne 0 ] && die "CTS failed (exit $RC) — see $OR_DIR/cts.log"
[ -f "$CTS_DEF" ] || die "CTS DEF not generated"
ok "CTS → $CTS_DEF"

# ── 7d: Routing ────────────────────────────────────────────
step "STEP 7d: Global + Detailed Routing"

RT_SCRIPT="$OR_DIR/route.tcl"
RT_DEF="$OR_DIR/routed.def"

cat > "$RT_SCRIPT" << RT_EOF
read_lef $HD_TLEF
read_lef $HD_LEF
read_liberty $TT_LIB
read_def $CTS_DEF

set_wire_rc -layer met2

# Global routing
global_route -guide_file $OR_DIR/route.guide \\
    -congestion_iterations 30

# Detailed routing
detailed_route -output_drc $OR_DIR/drc_after_route.rpt \\
               -bottom_routing_layer met1 \\
               -top_routing_layer    met4

write_def $RT_DEF
puts "Routing complete: $RT_DEF"
exit
RT_EOF

openroad -exit "$RT_SCRIPT" 2>&1 | tee "$OR_DIR/route.log"
RC=${PIPESTATUS[0]}
[ "$RC" -ne 0 ] && die "Routing failed (exit $RC) — see $OR_DIR/route.log"
[ -f "$RT_DEF" ] || die "Routed DEF not generated"
ok "Routing → $RT_DEF"

# Copy routed DEF to results/
cp "$RT_DEF" "$RESULTS_DIR/top_cpu_routed.def"

# ── 7e: Post-Route STA ────────────────────────────────────
step "STEP 7e: Post-Route Timing Analysis"

PRSTA_SCRIPT="$OR_DIR/post_route_sta.tcl"
cat > "$PRSTA_SCRIPT" << PRSTA_EOF
read_lef $HD_TLEF
read_lef $HD_LEF
read_liberty $TT_LIB
read_def $RT_DEF

set_wire_rc -layer met2
estimate_parasitics -global_routing

create_clock -name clk -period 10.0 [get_ports clk]
set_input_delay  2.0 -clock clk [all_inputs]
set_output_delay 2.0 -clock clk [all_outputs]

report_checks -path_delay max -digits 4
report_tns
report_wns

exit
PRSTA_EOF

openroad -exit "$PRSTA_SCRIPT" 2>&1 | tee "$RESULTS_DIR/post_route_sta.rpt"
ok "Post-route STA → $RESULTS_DIR/post_route_sta.rpt"

# =============================================================
# STEP 8 – Generate GDSII with Magic
# =============================================================
step "STEP 8: GDSII Generation (Magic)"

GDS_SCRIPT="$BUILD_DIR/def2gds.tcl"
GDS_OUT="$RESULTS_DIR/top_cpu.gds"

MAGIC_TECH="$PDK_ROOT/libs.tech/magic/sky130A.magicrc"

cat > "$GDS_SCRIPT" << GDS_EOF
#!/usr/bin/env wish
drc off
locking off

# Load sky130A tech
tech load $PDK_ROOT/libs.tech/magic/sky130A.tech

# Load LEFs for cells
lef read $HD_TLEF
lef read $HD_LEF

# Import the routed DEF
def read $RT_DEF

# Stream out GDSII
gds write $GDS_OUT
puts "GDS written: $GDS_OUT"
quit -noprompt
GDS_EOF

magic -dnull -noconsole -rcfile "$MAGIC_TECH" < "$GDS_SCRIPT" \
    2>&1 | tee "$BUILD_DIR/def2gds.log"
RC=${PIPESTATUS[0]}
[ "$RC" -ne 0 ] && die "Magic GDS generation failed (exit $RC)"
[ -f "$GDS_OUT" ] || die "GDS file not generated: $GDS_OUT"
ok "GDSII → $GDS_OUT"

# =============================================================
# STEP 9 – DRC with Magic
# =============================================================
step "STEP 9: Magic DRC"

DRC_SCRIPT="$BUILD_DIR/run_drc.tcl"
DRC_LOG="$RESULTS_DIR/drc_report.txt"

cat > "$DRC_SCRIPT" << DRC_EOF
#!/usr/bin/env wish
drc on
drc euclidean on
lef read $HD_TLEF
lef read $HD_LEF
gds read $GDS_OUT
load top_cpu
drc check
set drc_count [drc list count total]
puts "Total DRC violations: \$drc_count"
if {\$drc_count > 0} {
    drc listall why
}
puts "DRC complete."
quit -noprompt
DRC_EOF

magic -dnull -noconsole -rcfile "$MAGIC_TECH" < "$DRC_SCRIPT" \
    2>&1 | tee "$DRC_LOG"
ok "DRC report → $DRC_LOG"
DRC_COUNT="$(grep -oP 'Total DRC violations: \K[0-9]+' "$DRC_LOG" 2>/dev/null | tail -1 || echo '?')"
echo "DRC violations: $DRC_COUNT"

# =============================================================
# STEP 10 – LVS with Netgen
# =============================================================
step "STEP 10: LVS (Netgen)"

LVS_LOG="$RESULTS_DIR/lvs_report.txt"

# Extract SPICE from GDS via Magic
EXT_SCRIPT="$BUILD_DIR/gds_extract.tcl"
EXT_SPICE="$RESULTS_DIR/top_cpu_layout.spice"

cat > "$EXT_SCRIPT" << EXT_EOF
#!/usr/bin/env wish
lef read $HD_TLEF
lef read $HD_LEF
gds read $GDS_OUT
load top_cpu
extract all
ext2spice lvs
ext2spice -o $EXT_SPICE
puts "Extraction complete: $EXT_SPICE"
quit -noprompt
EXT_EOF

magic -dnull -noconsole -rcfile "$MAGIC_TECH" < "$EXT_SCRIPT" \
    2>&1 | tee "$BUILD_DIR/extract.log"

# Schematic (source netlist) — from mapped Verilog → SPICE via Yosys
SCH_SPICE="$RESULTS_DIR/top_cpu_schematic.spice"

# Use the compiled SPICE from PDK as reference (standard cells are already there)
# Run netgen
netgen -batch lvs \
    "$EXT_SPICE top_cpu" \
    "$HD_SPICE sky130_fd_sc_hd" \
    "$PDK_ROOT/libs.tech/netgen/sky130A_setup.tcl" \
    "$LVS_LOG" \
    2>&1 | tee "$BUILD_DIR/lvs.log"

ok "LVS report → $LVS_LOG"
if grep -q "Circuits match" "$LVS_LOG" 2>/dev/null; then
    ok "LVS PASSED — circuits match"
else
    warn "LVS result: $(tail -5 "$LVS_LOG" 2>/dev/null)"
fi

# =============================================================
# FINAL SUMMARY
# =============================================================
step "FLOW COMPLETE — Summary"

echo ""
echo "Output files:"
for f in \
    "$RESULTS_DIR/top_cpu_mapped.v" \
    "$RESULTS_DIR/top_cpu_routed.def" \
    "$RESULTS_DIR/top_cpu.gds" \
    "$STA_LOG" \
    "$RESULTS_DIR/post_route_sta.rpt" \
    "$DRC_LOG" \
    "$LVS_LOG"; do
    if [ -f "$f" ]; then
        SIZE="$(du -h "$f" | cut -f1)"
        echo -e "  ${GREEN}✔${NC} $f  ($SIZE)"
    else
        echo -e "  ${RED}✘${NC} $f  (MISSING)"
    fi
done

echo ""
ok "MiniRISC RTL→GDS flow complete"
echo ""
echo "To reproduce from scratch:"
echo "  export PDK_ROOT=$PDK_ROOT"
echo "  bash $ROOT/scripts/fix_pdk_and_flow.sh"
