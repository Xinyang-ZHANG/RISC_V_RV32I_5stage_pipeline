@echo off
REM ****************************************************************************
REM Vivado (TM) v2019.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Fri Mar 01 00:15:14 +0800 2024
REM SW Build 2552052 on Fri May 24 14:49:42 MDT 2019
REM
REM Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
echo "xsim CPU_tb_behav -key {Behavioral:sim_1:Functional:CPU_tb} -tclbatch CPU_tb.tcl -view D:/self_learning/RISC-V-RV32I-CPU/risc_v_cpu1/CPU_tb_behav.wcfg -log simulate.log"
call xsim  CPU_tb_behav -key {Behavioral:sim_1:Functional:CPU_tb} -tclbatch CPU_tb.tcl -view D:/self_learning/RISC-V-RV32I-CPU/risc_v_cpu1/CPU_tb_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
