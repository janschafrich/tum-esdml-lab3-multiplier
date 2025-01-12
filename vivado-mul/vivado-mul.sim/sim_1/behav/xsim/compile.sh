#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2024.1.1 (64-bit)
#
# Filename    : compile.sh
# Simulator   : AMD Vivado Simulator
# Description : Script for compiling the simulation design source files
#
# Generated by Vivado on Sun Jan 12 13:12:03 CET 2025
# SW Build 5094488 on Fri Jun 14 08:57:50 MDT 2024
#
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
#
# usage: compile.sh
#
# ****************************************************************************
set -Eeuo pipefail
# compile VHDL design sources
echo "xvhdl --incr --relax -prj tb_multiplier_vhdl.prj"
xvhdl --incr --relax -prj tb_multiplier_vhdl.prj 2>&1 | tee compile.log

echo "Waiting for jobs to finish..."
echo "No pending jobs, compilation finished."
