#! /bin/bash

TB=${1:-tb_multiplier}
DESIGN_A=${2:-multiplier}
DESIGN_B=${3:-adder}

ghdl -a $DESIGN_B.vhd
ghdl -e $DESIGN_B

ghdl -a $DESIGN_A.vhd
ghdl -a $DESIGN_A

ghdl -a $TB.vhd
ghdl -e $TB 
ghdl -r $TB
