#! /bin/bash

TB=${1:-tb_multiplier}
DESIGN_BOTTOM=${2:-multiplier}
DESIGN_TOP=${3:-adder}

# ghdl -a $DESIGN_TOP.vhd
# ghdl -e $DESIGN_TOP

ghdl -a $DESIGN_BOTTOM.vhd
ghdl -a $DESIGN_BOTTOM

ghdl -a $TB.vhd
ghdl -e $TB 
ghdl -r $TB
