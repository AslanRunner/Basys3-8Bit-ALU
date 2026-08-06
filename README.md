# 8-Bit Arithmetic Logic Unit Design on Basys 3 FPGA

## About the Project
This project is an 8-bit Arithmetic Logic Unit, or ALU, designed for the **Basys 3 FPGA** board using the Verilog hardware description language. The system uses a 16-bit input data to perform various mathematical, logical, and memory operations on its internal 256-byte RAM block and 16 registers. The project also implements advanced hardware architectures such as the accurate display of Two's Complement negative numbers and debouncer logic for stable physical button operation.

---

## Hardware Architecture and Modules
The project consists of three main modules connected in a hierarchical structure:

### 1. control_unit.v
* It acts as the brain of the system by parsing the 16-bit raw switch input `inputs`.
* It extracts the most significant 4 bits of the input as the operation code `opcode`.
* Depending on the operation type, it routes the remaining 12 bits to their specific destinations such as the destination register `R_d_addr`, source registers `R_a_addr` and `R_b_addr`, RAM address `ram_addr`, or external data `w`.

### 2. alu.v
* It is the muscle of the system, housing 16 registers and 256 RAM blocks, each holding 8-bit data.
* It can execute 16 different operations including addition, subtraction, shifting, and logical operators.
* It checks whether the operation results are negative and generates a special `sign` bit for the display driver.
* For the CMP command `1110`, it includes a practical hardware workaround that outputs readable results directly to the display-100 for greater, 10 for equal, and 1 for less-instead of using LED flags.

### 3. testbench.v
* It integrates all other modules like CU and ALU and establishes the wire connections between them.
* **Debouncer Algorithm:** It uses a delay counter of approximately 1 million cycles on the 100MHz clock signal to prevent metastability caused by electrical bounces when the user presses the physical button.
* **Binary-to-BCD Converter:** It separates the 8-bit binary data from the ALU into hundreds, tens, and ones digits. If the number is negative, it calculates the absolute value by taking the inverse and adding 1 for correct display on the screen.
* **Display Multiplexer:** It creates an optical illusion by turning the four 7-segment displays on and off sequentially at very high speeds. For negative results, it only lights up the `-` sign `7'b0111111` on the leftmost display.

---

## Basys 3 FPGA Constraints
The system interacts with the hardware on the **Basys 3** board according to the XDC file as follows:

* **System Clock clk:** The native 100 MHz clock signal of Basys 3 on pin `W5` is used for screen scanning and synchronization.
* **Operation Trigger btnC:** The center button connected to pin `U18` is used to manually start the operation.
* **Command Input sw:** 16 physical switches lined up from pin `V17` to `R2` are used.
* **7-Segment Display:** Four anode pins `U2`, `U4`, `V4`, `W4` and seven cathode pins from `W7` to `U7` are used to display data and the minus sign.
* **Decimal Point dp:** Pin `V7` is hardware-configured to remain off `1'b1` at all times to prevent confusion on the screen.

---

## Development Notes
* The project coding was carried out considering Xilinx Vivado and Icarus Verilog compatible standards.
* To prevent unwanted Latch formations during signal routing, initial reset values like `4'b0000` and `8'b00000000` were assigned in the `always @*` block within the `control_unit`.
  
