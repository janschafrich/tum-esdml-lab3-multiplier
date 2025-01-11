#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2024.1.1 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : AMD Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Sat Jan 11 17:05:14 CET 2025
# SW Build 5094488 on Fri Jun 14 08:57:50 MDT 2024
#
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail
# simulate design
echo "xsim tb_multiplier_behav -key {Behavioral:sim_1:Functional:tb_multiplier} -tclbatch tb_multiplier.tcl -log simulate.log"
xsim tb_multiplier_behav -key {Behavioral:sim_1:Functional:tb_multiplier} -tclbatch tb_multiplier.tcl -log simulate.log

