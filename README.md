# I2C Master-Slave Implementation and Verification

This repository contains the second-semester project for the CI-Digital course, focusing on the implementation and verification of I2C master and slave controllers using multiple verification methods.

## Project Structure

<pre>
i2c_implementation_hdl/
├── RTL/ # RTL implementations
│ ├── V1.0/
│ ├── V2.0/
│ └── V3.0/ # Latest version with revision notes
├── Geral Testbenches/ # Basic testbenches
│ ├── V1.0/
│ ├── V2.0/
│ └── V3.0/ # Each contains prompt_icarus.txt with simulation commands
├── Assertions Testbench/ # Assertion-based verification
│ └── V1.0/ # Uses RTL V3.0, includes run_information.txt
├── UVM Environments/ # UVM verification environments
│ ├── master/ # UVM environment for I2C master
│ └── slave/ # UVM environment for I2C slave
├── Synthesis/ # Synthesis files and scripts
└── README.md
</pre>

## Modules

- **I2C Master Controller**: Implements I2C protocol master functionality
- **I2C Slave Controller**: Implements I2C protocol slave functionality

## Verification Approaches

1. **Basic Testbenches**: Simple directed tests for initial validation
2. **Assertion-Based Verification**: Property checking for protocol compliance
3. **UVM Environments**: Scalable verification with sequences, drivers, monitors, and scoreboards

Each verification method includes version tracking and simulation instructions in respective directories.
