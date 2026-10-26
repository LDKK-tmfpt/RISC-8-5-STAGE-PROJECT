# 8-bit RISC 5-Stage Pipelined Processor

**Student Name:** Hoàng Ngọc Long  
**Student ID:** SE204586  
**Status:** Complete (Design & Simulation)

## Project Overview
This project implements an 8-bit, 5-stage pipelined RISC processor using Verilog HDL. The architecture is designed to optimize execution throughput (CPI ≈ 1) by overlapping instructions across five independent hardware stages: Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write-Back (WB).

Advanced architectural features are implemented to resolve pipeline conflicts:
* **Data Hazards:** Handled via a dynamic **Forwarding Multiplexer** prioritizing EX/MEM and MEM/WB bypassed data.
* **Load-Use Hazards:** Handled via a **1-Cycle Pipeline Stall** and ID/EX bubble injection.
* **Control Hazards:** Handled via a **Branch Flush** mechanism that squashes wrong-path instructions.

## Repository Structure

```text
SE204586_HoangNgocLong_project/
│
├── rtl/                        # Register Transfer Level (Verilog Source Code)
│   ├── 8risc.v                 # Top-level core module (Datapath integration)
│   ├── alu8risc.v              # Arithmetic Logic Unit
│   ├── ctrlu8risc.v            # Control Unit (Opcode decoder)
│   ├── dmem8risc.v             # Data Memory (RAM)
│   ├── hazardu8risc.v          # Hazard Detection & Forwarding Unit
│   ├── imem8risc.v             # Instruction Memory (ROM)
│   ├── regfile8risc.v          # Register File (8-bit, 8 registers)
│   └── New PY File.py          # Auxiliary Python script (e.g., assembler/utils)
│
├── sw/                         # Software & Documentation
│   ├── Presentation 8-bit RISC project... # Project defense slide deck
│   └── schematic.pdf           # Exported RTL block design schematic
│
├── tb/                         # Testbench Environment
│   └── tb_core8risc.v          # Self-checking automated testbench
│
├── file.f                      # Verilog file list for compiler inclusion
├── simulate.bat                # Windows batch script to run the simulation
├── simulation_log.txt          # Exported log of the latest successful simulation
└── README.md                   # This file
```

## How to Run Simulation

This project includes an automated, self-checking testbench (`tb_core8risc.v`) that executes a predefined assembly program, logs the pipeline status cycle-by-cycle, and automatically compares the final hardware state against expected values.

**To run the simulation:**
1. Ensure you have a Verilog simulator installed (e.g., Icarus Verilog, Vivado, ModelSim).
2. Simply double-click the `simulate.bat` file in the root directory, OR run it via command line:
   ```cmd
   ./simulate.bat
   ```
3. The script will compile the sources listed in `file.f`, run the testbench, and output the results.
4. Check the console output or the `simulation_log.txt` file. A successful run will end with the message: `*** ALL TESTS PASSED ***`.
