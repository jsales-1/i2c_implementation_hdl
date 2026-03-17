# I2C Master-Slave Implementation and Verification

This repository contains the second-semester project for the CI-Digital course, focusing on the implementation and verification of I2C master and slave controllers using multiple verification methods.

## Project Structure

<pre>
i2c_implementation_hdl/
├── RTL/ # RTL implementations
│ ├── V1.0/
│ ├── V2.0/
│ ├── V3.0/
│ ├── V4.0/
│ └── V5.0/ # Latest version with revision notes
├── Geral Testbenches/ # Basic testbenches
│ ├── V1.0/
│ ├── V2.0/
│ ├── V3.0/
│ ├── V4.0/
│ └── V5.0/ # Each contains prompt_icarus.txt with simulation commands
├── Assertions Testbench/ # Assertion-based verification
│ ├── V1.0/ # Uses RTL V3.0
│ ├── V2.0/ # Uses RTL V3.0, includes run_information.txt
│ ├── V3.0/ # Uses RTL V4.0, includes run_information.txt
│ └── V4.0/ # Uses RTL V5.0, includes run_information.txt
├── UVM Environments/ # UVM verification environments
│ ├── master/ # UVM environment for I2C master
│ └── slave/ # UVM environment for I2C slave
├── Synthesis/ # Synthesis files and scripts
└── README.md
</pre>

## Register Transfer Level (RTL) 
The versions can be acessed in the path <code> i2c_implementation_hdl/RTL </code>. The last version developed is V5.0, but all contains the modules:

- **I2C Master Controller**: Implements I2C protocol master functionality
- **I2C Slave Controller**: Implements I2C protocol slave functionality

## Geral Testbenches

The **General Testbenches** directory contains simple directed verification environments used for the initial functional validation of the RTL implementations. These testbenches focus on basic protocol behavior, verifying that the master and slave controllers correctly perform operations such as start condition generation, address transmission, read/write transactions, and data transfer on the I2C bus.

All testbenches in this repository are implemented in **SystemVerilog**. The environments instantiate the I2C master together with one or more slave controllers connected through shared "SDA" and "SCL" signals, modeling the open-drain behavior of the I2C bus.

Each testbench version corresponds to a specific RTL version and evolves together with the design. Earlier versions contain simpler directed tests aimed at validating core communication, while later versions include more complete scenarios, such as interactions with multiple slaves and improved verification of protocol behavior.

The simulations can be executed using **Icarus Verilog**. For convenience, every version directory includes a file named `prompt_icarus.txt`, which contains the commands required to compile and run the simulation. These commands compile the SystemVerilog testbench and RTL files using `iverilog` and execute the simulation with `vvp`, generating waveform files that can be analyzed with tools such as GTKWave.

## Assertion-Based Verification

The assertion-based verification environments were developed according to the verification plan, aiming to formally check compliance with key aspects of the I2C protocol. These assertions monitor relevant bus events and protocol rules during simulation, enabling automatic detection of violations such as incorrect start/stop conditions, invalid address phases, or unexpected signal transitions.

The versions V3.0 and V4.0(Final Version) include dedicated testbenches containing SystemVerilog Assertions (SVA) together with functional coverage definitions. During simulation, the coverage model generates coverage database files that can be analyzed using **Cadence IMC (Integrated Metrics Center)**, allowing inspection of the functional coverage results defined in the verification plan. The tests can be executed either in **EDA Playground** for quick experimentation or locally using **Cadence Xcelium**, which enables assertion checking and coverage database generation for further analysis in **IMC**. 

## UVM Environments


The UVM (Universal Verification Methodology) based verification was implemented for the I2C controllers, resulting in complete and reusable environments following the recommended methodology practices. The UVM environments are organized in the `UVM Environments` folder, which is divided into two main sections: `master` and `slave`, each containing numbered versions from V1.0 to V4.0. Version V2.0 is already complete and was developed to validate RTL version V4.0, while version V3.0 is dedicated to RTL version V5.0 (final version) and version V4.0 is used for the verification of the netlist obtained after synthesis. Each version includes a complete structure with sequences, drivers, monitors, agents, scoreboards and multiple test classes, allowing from basic transactions to stress scenarios and error injection. For easy access and execution, each version contains a `run_information.txt` file with a direct link to EDA Playground, where the UVM environment is already pre-configured and ready for simulation, allowing result analysis and exploration of the different implemented tests.


## Netlists and Gate Level Simulation


## Synthesis and Reports 
