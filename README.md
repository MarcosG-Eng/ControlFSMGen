# Table-Control FSM Generator for Industrial Automation

## Overview

This project provides a modular, parameterizable VHDL framework for generating Finite State Machines (FSMs) from truth tables, specifically tailored for industrial table control applications. The core of the system is the **Table-Control** module, which enables the automatic synthesis of FSMs by specifying state transition and output tables. The design is complemented by a comprehensive top-level module that integrates the FSM generator with real-world industrial hardware, including sensors, actuators, and safety mechanisms.

The project is intended for rapid prototyping and deployment of industrial control logic, offering a reusable and scalable solution for a wide range of automation scenarios.

---

## Key Features

- **FSM Generation from Truth Tables:**  
  The Table-Control module allows users to define FSM behavior using explicit state transition and output tables, enabling fast and error-free FSM implementation.

- **Top-Level Industrial Integration:**  
  A dedicated top module demonstrates the application of the FSM generator in controlling an industrial table, handling sensor inputs, actuator outputs, manual/automatic modes, and emergency stop logic.

- **Highly Parameterizable:**  
  All modules are designed with generics, allowing easy adaptation to different numbers of inputs, outputs, and states.

- **Debouncing and Synchronization:**  
  Input signals are processed through debouncing and synchronization modules to ensure reliable operation in noisy industrial environments.

- **Professional Project Structure:**  
  The project is organized for clarity and maintainability, with separate folders for HDL sources, simulation testbenches, IP cores, and constraints.

- **Automated Vivado Project Creation:**  
  A ready-to-use Tcl script (`generate_project.tcl`) is provided to automate the creation and configuration of the Vivado project, including source import and constraint setup.

---

## Project Structure

```
ControlFSMGen/
├── src/
│   ├── hdl/         # VHDL source files (core modules, Table-Control, top-level, types)
│   ├── sim/         # Testbenches for simulation and verification
│   ├── ip/          # IP cores (if any)
│   ├── repo/        # IP repository (optional)
│   ├── constraints/ # XDC constraint files for FPGA pin mapping
├── generate_project.tcl # Vivado project generation script
├── README.md
├── LICENSE
```

### Main HDL Modules

- **Table-Control (FSM_PLC.vhd):**  
  Core FSM generator. Accepts state transition and output tables as generics or constants, and implements the corresponding FSM logic.

- **PLC.vhd / SentidoPLC.vhd:**  
  Example FSM instances for piece counting and direction control, demonstrating the use of Table-Control with real truth tables.

- **Control_Unit.vhd:**  
  Top-level integration module. Connects FSMs to industrial I/O, manages operation modes, and implements safety logic.

- **Debouncer.vhd, Sincronizador.vhd, CKE_Gen.vhd:**  
  Utility modules for input conditioning and clock enable generation.

- **MUX_PLC.vhd, Reg_PLC.vhd, Reg_Des.vhd:**  
  Supporting modules for state/output selection and register implementation.

- **Mis_Tipos_PLC.vhd:**  
  Global type and constant definitions for parameterization.

---

## Getting Started

### Prerequisites

- **Xilinx Vivado** (recommended for synthesis and implementation)
- **VHDL-93** or higher compatible simulator (ModelSim, GHDL, Vivado Simulator, etc.)

### Project Creation

To set up the project in Vivado:

1. **Clone or Download the Repository**  
   Place the project folder on your local machine.

2. **Open Vivado and Run the Tcl Script**  
   - Launch Vivado.
   - Go to `Tools > Run Tcl Script...`
   - Select `generate_project.tcl` from the project root directory.
   - The script will automatically:
     - Create a new Vivado project.
     - Import all HDL sources, simulation files, and constraints.
     - Set up IP repositories if present.
     - Configure synthesis and implementation strategies.

3. **Set the Top Module (if needed)**  
   The script can be configured to set a specific top module. By default, Vivado will infer the top-level entity.

4. **Simulate or Synthesize**  
   - Use the provided testbenches in `src/sim/` for simulation and verification.
   - Synthesize and implement the design for your target FPGA (ZYBO board supported out-of-the-box).

---

## Usage and Customization

- **FSM Design:**  
  To implement a new FSM, define the state transition and output tables in the appropriate format and instantiate the Table-Control module with the desired parameters.

- **Industrial Integration:**  
  The top-level module (`Control_Unit.vhd`) demonstrates how to connect the FSM to real hardware, including sensors, actuators, and safety controls.

- **Parameter Adjustment:**  
  Modify the generics in the entity declarations to match your application's requirements (number of inputs, outputs, states).

- **Simulation:**  
  Use the testbenches to validate each module individually before hardware deployment.

---

## Professional Notes

- The project is structured for scalability and maintainability, following best practices in industrial VHDL design.
- All modules are documented and parameterized for reuse in other automation projects.
- The use of truth tables for FSM definition minimizes design errors and accelerates development cycles.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Author & Credits

- **Author:** Marcos Guerrero
- **Final Degree Project (TFG)** – [Your University Name]
- **Year:** 2024–2025

For academic, research, and industrial use.