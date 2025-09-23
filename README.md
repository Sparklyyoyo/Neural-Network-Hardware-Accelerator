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

Modern DNN inference demands **low-latency, high-throughput hardware acceleration**. FPGAs offer flexibility and parallelism that make them ideal for embedded accelerators. This project focuses on designing a system-on-chip (SoC) that integrates a soft-core processor (Nios II) with a DNN accelerator, leveraging Avalon memory-mapped interfaces to interact with SDRAM and peripherals efficiently.

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

---

## Deliverables

- **RTL designs:** Verilog modules for dot product, memory copy, and VGA interface  
- **Nios II program:** C program to load data and control accelerators  
- **Testbench:** Simulation testbench for verifying functionality  
- **Documentation:** This README and supporting diagrams  

---

This project demonstrates **practical FPGA design skills**, efficient memory management, and hardware acceleration for neural network inference, making it highly relevant for **hardware and embedded system engineering roles**, including positions in companies like AMD.
