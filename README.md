# Table-Control FSM Generator for Industrial Automation

## Overview
This project provides a modular, parameterizable VHDL framework for generating Finite State Machines (FSMs) from truth tables, specifically tailored for industrial table control applications. The core of the system is the **FSM Component**, which enables the automatic synthesis of FSMs by specifying state transition and output tables. The design is complemented by a **PLC Top Module**, which serves as a test and validation environment for the FSM generator, integrating it with real-world industrial hardware, including sensors, actuators, and safety mechanisms.

The project is intended for rapid prototyping and deployment of industrial control logic, offering a reusable and scalable solution for a wide range of automation scenarios.

---

## Key Features
- **FSM Generation from Truth Tables:**  
  The FSM Component allows users to define FSM behavior using explicit state transition and output tables, enabling fast and error-free FSM implementation.

- **PLC Top Module for Validation:**  
  A dedicated top module demonstrates the application of the FSM generator in controlling an industrial table, handling sensor inputs, actuator outputs, manual/automatic modes, and emergency stop logic. This module is primarily for testing and validating the FSM Component.

- **Highly Parameterizable:**  
  All modules are designed with generics, allowing easy adaptation to different numbers of inputs, outputs, and states.

- **Comprehensive Test Bench:**  
  Includes a robust test bench to validate FSM behavior under various conditions.

---

## Project Structure
```
├── src/
│   ├── hdl/                # VHDL source files for FSM and supporting modules (board-independent)
│   ├── sim/                # Test bench files
│   ├── constraints/        # Xilinx constraints files (ZYBO 7000 example provided)
│   └── ip/                 # IP cores (if any)
├── proj/                   # Vivado project files
├── README.md               # Project documentation
├── LICENSE                 # License information
└── generate_project.tcl    # TCL script for project generation
```

---

## Getting Started

### Prerequisites
- **Vivado Design Suite**: Ensure you have Xilinx Vivado installed.
- **Hardware**: A compatible FPGA development board (e.g., ZYBO).

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/MarcosG-Eng/ControlFSMGen.git
   cd ControlFSMGen
   ```
2. Open Vivado and source the `generate_project.tcl` script to set up the project:
   ```
   source ./generate_project.tcl
   ```
3. Synthesize and implement the design in Vivado.
4. Program the FPGA with the generated bitstream.

---

## Usage

### Simulation
The project includes a comprehensive test bench located in the `src/sim/` directory to validate the top module. You can use Vivado's built-in simulator or your preferred VHDL simulation tool to run and analyze the test bench.

### Hardware Deployment
1. Connect the FPGA board to your computer.
2. Load the bitstream onto the FPGA using Vivado.
3. Interact with the FSM through the input/output interfaces.

---

## Contributing
Contributions are welcome! Please fork the repository and submit a pull request with your changes.

---

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## Acknowledgments
Special thanks to the contributors and the open-source community for their support.