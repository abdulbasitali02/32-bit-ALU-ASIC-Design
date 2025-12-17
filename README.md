# 32-Bit ALU ASIC Design (RTL → GDSII) — Cadence Flow

## Overview

This repository contains the complete design and implementation of a **32-bit Arithmetic Logic Unit (ALU)** developed through a **full RTL-to-GDSII ASIC design flow** using **Cadence tools**.

The project was completed as part of a Digital VLSI term project and mirrors an **industry-style ASIC workflow**, including RTL development, functional verification, synthesis, place & route, sign-off checks, and GDSII export.

Two independent ALU implementations are provided:

1. **Structural / Hierarchical (Bit-Slice) Design**  
   A 1-bit ALU slice is designed and instantiated 32 times to form the full 32-bit datapath.

2. **Behavioral 32-bit RTL Design**  
   A single-module 32-bit Verilog implementation used as a performance and verification reference.

Both designs are verified, synthesized, physically implemented, and compared in terms of **area, timing, and performance**.

---

## Key Features

- Complete **RTL → Simulation → Synthesis → PnR → Sign-off → GDSII** flow
- Two ALU implementations: **bit-slice structural** and **behavioral RTL**
- Implemented using **Cadence Xcelium, Genus, and Innovus**
- Targeted **45 nm CMOS GPDK**
- Automated flows using **Tcl scripting**
- Industry-relevant focus on **timing closure, DRC/LVS, and verification**

---

## ALU Specification

### Inputs
- `A[31:0]` – 32-bit operand A  
- `B[31:0]` – 32-bit operand B  
- `Cin` – Carry-in  
- `DinL` – Serial input for shift-left operations  
- `DinR` – Serial input for shift-right operations  
- `S[3:0]` – Operation select signals  

### Outputs
- `F[31:0]` – 32-bit ALU result  
- `Cout` – Carry-out  

### Supported Operations
- Transfer, increment, decrement
- Addition and add-with-carry
- Subtraction variants
- Bitwise AND, OR, XOR, NOT
- Logical shift left and shift right (with serial inputs)

---

## Architecture

### Bit-Slice (Structural) Design

The bit-slice ALU is built from a reusable **1-bit ALU cell**, composed of:

- **Arithmetic unit** (full adder with selectable inputs)
- **Logic unit** (AND / OR / XOR / NOT)
- **Multiplexer layer** selecting arithmetic, logic, or shift outputs

Thirty-two 1-bit slices are chained together to form the full 32-bit datapath.

**Why bit-slice matters:**
- Clean hierarchical design
- Easy scalability
- Strong relevance to datapath design and physical layout regularity
- Enables modular verification and reuse

---

### Behavioral 32-bit Design

The behavioral ALU is implemented as a single Verilog module operating directly on 32-bit vectors.

**Purpose of behavioral design:**
- Faster functional validation
- Reference model for structural verification
- Comparison of area, power, and timing against bit-slice design

---

### Shift Operations

- **Shift Right**: `F = A >> 1` with `DinR` inserted at MSB  
- **Shift Left**: `F = A << 1` with `DinL` inserted at LSB  

In the bit-slice design, shift functionality is achieved through slice-to-slice signal chaining with boundary injection.

---

## Toolchain

- **RTL Simulation**: Cadence Xcelium (`xrun`)
- **Synthesis**: Cadence Genus
- **Place & Route**: Cadence Innovus
- **Layout / Viewing**: Cadence Virtuoso
- **Process**: 45 nm CMOS GPDK

---

## Verification Flow (Design Verification)

### RTL Simulation

- Unit-level testing of:
  - Arithmetic unit
  - Logic unit
  - Multiplexer
  - 1-bit ALU slice
- System-level testing of:
  - 32-bit structural ALU
  - 32-bit behavioral ALU
- Structural vs behavioral output comparison

Waveforms are inspected to validate:
- Correct operation decoding
- Carry propagation
- Shift boundary behavior
- Output correctness across all control combinations

---

## Synthesis Flow (Genus)

- RTL elaboration and technology mapping
- Timing constraint application
- Area, timing, and power report generation
- Netlist export for PnR

Both ALU implementations are synthesized independently to enable architectural comparison.

---

## Physical Design Flow (Innovus)

- Floorplanning and core sizing
- Power planning
- Standard cell placement
- Clock Tree Synthesis (CTS)
- Routing
- Post-route timing analysis

Design closure focuses on:
- Worst Negative Slack (WNS)
- Clock skew
- Congestion
- Utilization

---

## Sign-off & GDS Export

- **DRC checks** to verify foundry rule compliance
- **Connectivity checks** to ensure correct routing
- **LVS checks** to confirm layout-netlist equivalence
- Final **GDSII export** for:
  - Structural core
  - Behavioral core
  - Full-chip layout with pad frame (selected design)

---

## Automation (Tcl)

Key stages of the flow are automated using Tcl scripts for:

- RTL compilation
- Synthesis execution
- PnR stages
- Report generation
- GDS export

Automation enables:
- Faster iteration
- Reproducible results
- Industry-style batch flows

---

## Results Summary

- Achieved **153 MHz timing closure**
- **+1.26 ns worst-case slack** at **125 °C**
- Clean DRC/LVS with no violations
- Successful GDS export for tape-out-ready layouts

(Exact area, power, and timing reports are included in the `results/` directory.)

---
