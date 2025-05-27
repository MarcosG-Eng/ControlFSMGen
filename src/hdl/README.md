# PLC FSM System for Industrial Table Control

## General Description

This project implements a control system based on finite state machines (FSM) for an industrial table, using VHDL. The design is modular and parameterizable, allowing reuse and adaptation to different configurations of inputs, outputs, and states. It includes synchronization logic, debouncing, emergency control, and manual/automatic operation modes.

## Project Structure

- **PLC.vhd**: Main instance of the programmable finite state machine (FSM) for piece counting.
- **SentidoPLC.vhd**: FSM for controlling the direction of the table.
- **FSM_PLC.vhd**: Generic FSM core, parameterizable via transition and output tables.
- **MUX_PLC.vhd**: Generic multiplexer for selecting states/outputs from ROM tables.
- **Reg_PLC.vhd**: State register for the FSM.
- **Reg_Des.vhd**: Shift register used in debouncing.
- **Debouncer.vhd**: Debounce module for mechanical inputs.
- **Sincronizador.vhd**: Synchronizer and debouncer for trigger signals.
- **CKE_Gen.vhd**: Single-cycle enable pulse generator.
- **Mis_Tipos_PLC.vhd**: Definition of types and global parameters.
- **Control_Unit.vhd**: Top-level control unit integrating FSMs, emergency logic, and operation modes.
- **tests/**: Testbenches for each module.

## Main Features

- **Modularity**: Each main function is encapsulated in a separate VHDL module.
- **Parameterization**: The number of inputs, outputs, and states is configurable via generics.
- **Debouncing and Synchronization**: Critical inputs are processed through debouncing and synchronization modules.
- **Manual/Automatic Mode**: Operation mode selection via switch.
- **Emergency Stop**: Dedicated logic for E-Stop management.
- **Testbenches**: Test files to validate each module's functionality.

## Requirements

- **Tools**: Compatible with any standard VHDL simulator (ModelSim, Vivado, GHDL, etc.).
- **Language**: VHDL-93 or higher.

## Usage

1. **Simulation**: Use the testbench files in the `tests/` folder to simulate and validate each module.
2. **Synthesis**: Import the VHDL files into your preferred FPGA synthesis environment.
3. **Configuration**: Adjust the parameters (K, P, M) in the entity files according to your application requirements.
4. **Integration**: Use `Control_Unit.vhd` as the entry point for integration into larger systems.


## Credits

- Author: Marcos [Your Last Name]
- Final Degree Project (TFG) - [University Name]
- Year: 2024

---
