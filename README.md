# Industry-Standard Asynchronous FIFO in Verilog

A robust, parameterizable Asynchronous First-In-First-Out (FIFO) buffer designed in Verilog HDL, implementing rigorous Clock Domain Crossing (CDC) and metastability mitigation techniques tailored for high-reliability digital IC design.

## 🚀 Key Architectural Features
* **Dual-Port RAM Architecture:** Independent write and read clock domains supporting asynchronous data buffering with configurable data and address widths.
* **Gray-Code Pointer Conversion:** Write and read pointers are converted to Gray code before crossing clock domains to ensure that only a single bit transitions at any given time, avoiding multi-bit glitch hazards.
* **Two-Stage Synchronization:** Utilizes multi-flop synchronizer chains (`synchronizer.v`) across asynchronous boundaries to effectively suppress metastability.
* **Safe Status Flag Generation:** Exact full and empty flag computations derived safely via domain-crossing pointer comparisons.

## 📂 Repository Structure
```text
async-fifo/
│
├── rtl/
│   ├── dual_port_ram.v    # Underlying dual-port memory array
│   ├── synchronizer.v     # Multi-stage flip-flop CDC synchronizer
│   └── fifo.v             # Top-level integration and control logic
│
├── testbench/
│   └── fifo_tb.v          # Comprehensive testbench driving independent clocks
│
└── README.md
