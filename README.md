# Deep Neural Network Accelerator on FPGA

This project implements a **deep neural network (DNN) accelerator** for an embedded Nios II system on the DE1-SoC FPGA platform. The accelerator is designed to perform high-performance matrix-vector multiplications for inference on pre-trained networks, interfacing efficiently with off-chip SDRAM and using a custom Avalon memory-mapped architecture.  

---

## Table of Contents

- [Background](#background)  
- [Project Overview](#project-overview)  
- [Neural Network Architecture](#neural-network-architecture)  
- [Fixed-Point Implementation](#fixed-point-implementation)  
- [System Design](#system-design)  
  - [PLL and SDRAM Integration](#pll-and-sdram-integration)  
  - [Memory-Mapped Accelerators](#memory-mapped-accelerators)  
- [Simulation and Testing](#simulation-and-testing)  
- [Usage](#usage)  
- [Deliverables](#deliverables)  

---

## Background

Modern DNN inference demands **low-latency, high-throughput hardware acceleration**. FPGAs offer flexibility and parallelism that make them ideal for embedded accelerators. This project focuses on designing a system-on-chip (SoC) that integrates a soft-core processor (Nios II) with a DNN accelerator, leveraging Avalon memory-mapped interfaces to interact with SDRAM and peripherals efficiently. This was performed using the Intel Platform Designer present on Quartus.

---

## Project Overview

The goal of this project is to implement a **multi-layer perceptron (MLP)** accelerator capable of classifying handwritten digits from the MNIST dataset. The DNN computation is entirely offloaded from the CPU to custom hardware, demonstrating:

- Efficient memory access from off-chip SDRAM  
- Scalable matrix-vector multiplication accelerators  
- Integration with peripheral devices such as VGA output for visualization  

---

## Neural Network Architecture

The MLP consists of:

- **Input layer:** 784 neurons (28×28 grayscale pixels)  
- **Hidden layers:** Two layers with 1000 neurons each  
- **Output layer:** 10 neurons corresponding to digits 0–9  

For the activation function, we use the **rectified linear unit (ReLU)**, which maps all negative values to zero and leaves positive values unchanged.  

> The network is pre-trained. The focus here is on **hardware implementation of inference**, not training.

---

## Fixed-Point Implementation

All computations use **Q16.16 signed fixed-point numbers**, where:

- Upper 16 bits = integer part  
- Lower 16 bits = fractional part  

Multiplications and additions are implemented directly on 32-bit integers, with appropriate scaling to preserve the fixed-point format. **Truncation** is used for simplicity, as full rounding is not critical for inference accuracy.

---

## System Design

The SoC integrates multiple components:

### PLL and SDRAM Integration

- **PLL** generates system and SDRAM clocks with appropriate phase shifts to ensure timing alignment.  
- **SDRAM controller** provides access to off-chip memory for both weights and activations. The system handles wait states and read/write delays to ensure correct memory operations.  

### Memory-Mapped Accelerators

- **Dot product accelerator:** Computes matrix-vector multiplications efficiently in hardware.  
- **Memory copy accelerator:** Optimizes data movement between SDRAM and on-chip buffers.  
- **VGA interface:** Visualizes results as pixel outputs via a memory-mapped Avalon interface.  

The CPU orchestrates operations, loads input images and network weights into SDRAM, and triggers the accelerators to perform inference.

---

## System Architecture

The project builds a complete FPGA-based Nios II system with:

1. **External SDRAM Interface:** Stores neural network weights, biases, and input data.  
2. **Phase-Locked Loop (PLL):** Generates stable 50 MHz clock signals with phase adjustments for SDRAM timing.  
3. **Avalon Memory-Mapped Interfaces:** Facilitates communication between CPU and hardware accelerators.  
4. **Custom Hardware Accelerators:** Implemented as Avalon IP components to accelerate memory copying and dot product calculations.  
5. **VGA Output Module:** Optional grayscale visualization of input data for testing purposes.

---

## Key Components

### 1. SDRAM & PLL Integration

- Configured SDRAM controller for 64 MB external memory.  
- PLL generates two clocks:
  - `outclk0` → Main system modules  
  - `outclk1` → SDRAM interface (phase-shifted to account for signal delay)  
- Nios II system uses on-chip memory for instruction storage and off-chip SDRAM for data.

---

### 2. VGA Core Wrapper

- Created an **Avalon memory-mapped wrapper** for the VGA module.  
- Allows the CPU to plot pixels via a 32-bit word protocol:
  - Bits 30–24: Y-coordinate  
  - Bits 23–16: X-coordinate  
  - Bits 7–0: Brightness (0–255)  
- Supports grayscale visualization with weighted neighborhood averaging.  
- Useful for debugging and displaying input images on hardware.

---

### 3. Memory Copy Accelerator (WordCopy)

- Custom DMA-style accelerator to move blocks of memory without CPU involvement.  
- Avalon interface offsets:
  - `0`: Start copy / poll completion  
  - `1`: Destination address  
  - `2`: Source address  
  - `3`: Number of 32-bit words  
- Handles repeated requests and manages waitrequest/readdatavalid signaling.  
- Optimizes memory transfer performance for subsequent DNN computation.

---

### 4. Dot Product Accelerator

- Hardware module for computing **vector dot products** in Q16.16 fixed-point.  
- Supports bias addition and optional ReLU activation.  
- Avalon interface offsets:
  - `0`: Start / stall for result  
  - `2`: Weight matrix address  
  - `3`: Input vector address  
  - `5`: Vector length  
- Offloads computationally intensive matrix-vector multiplications from the CPU.  
- Used by the `run_nn.c` software to accelerate inference.

---

### 5. Optimized Dot Product (DotOpt)

- High-performance version of the dot product accelerator with **dual Avalon master ports**:  
  - Port 1: SDRAM  
  - Port 2: On-chip SRAM banks (for input activation reuse)  
- Exploits **data locality** to reduce repeated off-chip memory accesses.  
- Designed to perform concurrent reads of weights and activations.  
- Improves inference speed and energy efficiency, illustrating hardware-software co-design principles.

---

## Fixed-Point Computation (Q16.16)

- 32-bit signed representation: upper 16 bits integer, lower 16 bits fraction.  
- Multiplication requires fractional point adjustments (truncation used for simplicity).  
- All weights, biases, and activations stored in Q16.16 format for consistent precision across modules.

---

## Testing & Verification

- RTL unit tests implemented in **SystemVerilog**:
  - `tb_rtl_wordcopy.sv` → validates memory copy functionality  
  - `tb_rtl_dot.sv` → validates dot product computations  
- Functional software tests via `run_nn.c` on the Nios II processor.  
- Optional VGA output used to visualize input patterns and verify memory content.  
- Memory initialization and simulation performed with ModelSim using `$readmemh()` for binary weights and inputs.

---

## Key Skills Demonstrated

- FPGA SoC design using **Intel Platform Designer**  
- Hardware-software co-design for DNN inference  
- Custom Avalon memory-mapped IP development  
- Fixed-point arithmetic and Q-format computation  
- System verification and ModelSim simulation  
- Memory hierarchy optimization for performance and energy efficiency  

---

## Usage

1. Load Nios II system onto DE1-SoC.  
2. Copy neural network weights (`nn.bin`) and input images (`test_00.bin`) into SDRAM.  
3. Run `run_nn.c` to perform inference using the custom accelerators.  
4. (Optional) Display input or output using the VGA module.  

---

This project showcases **practical experience in FPGA-based deep learning acceleration**, combining low-level RTL design, system integration, and software control skills.


---

## Simulation and Testing

The system is verified both in **simulation** (ModelSim) and on a **physical DE1-SoC board**. Simulation involves:

- Generating functional models of SDRAM  
- Observing Avalon interface signals such as `waitrequest` and `readdatavalid`  
- Using test programs to verify memory access and peripheral behavior  

On the board, results are displayed via a 7-segment display or VGA output for visual verification of the recognized digits.

---

## Usage

1. Compile the Nios II program and load it into SDRAM.  
2. Load pre-trained network weights and test images into memory.  
3. Trigger inference via CPU or memory-mapped control registers.  
4. Read output via the hex display or VGA module.  

