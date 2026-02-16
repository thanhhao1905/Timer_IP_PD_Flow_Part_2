## Introduction to Timer IP

### **What is Timer IP?**

Timer IP (Timer Intellectual Property) is a functional block designed to count time and generate interrupt events based on pre-configured compare values. It is a common peripheral block in microcontroller systems and SoCs (System-on-Chip), enabling time-related tasks without direct CPU intervention.

<img width="1680" height="767" alt="image" src="https://github.com/user-attachments/assets/79220a71-8daa-4574-9321-e3ba1ad6765f" />


### **Operational Features**

The Timer IP in this design operates based on the following main functional blocks:

1. **Flexible 64-bit Counter with Prescaler Mechanism**:
   - The core of the Timer IP is a 64-bit counter that can increment every clock cycle or according to a clock division ratio configured via the control register.
   - **Flexible Prescaler Mechanism**: The Timer IP supports dividing the input clock frequency (50 MHz) with division factors from 2⁰ to 2⁸ (1 to 256), configured via bits `data0[11:8]` in the TCR control register. This allows the counter to operate at various frequency ranges, suitable for diverse applications:
     - **Division factor = 1**: Counts at 50 MHz (20 ns period) – suitable for high-precision time measurement applications.
     - **Division factor = 256**: Counts at ~195 kHz (~5.12 µs period) – suitable for long-duration timing applications.
   - The counter can be enabled/disabled via bit `data0[0]` (timer enable) and bit `data0[1]` (prescaler enable) in the control register.

<img width="734" height="248" alt="image" src="https://github.com/user-attachments/assets/8ab4ee27-cb36-4003-bc02-8b2479bf4124" />

2. **Halt Mechanism in Debug Mode**:
   - The Timer IP supports a **halt** feature that pauses the counter when the system is in debug mode, controlled via the **THCSR (Timer Halt Control Status Register)**.
   - When the `dbg_mode` signal is activated and the halt bit is set, the counter pauses operation, retaining its current value. This allows engineers to debug the system without losing the current time state of the timer.
   - This feature is particularly useful when debugging real-time systems, enabling timer state inspection at breakpoints without being affected by counter changes.

<img width="871" height="214" alt="image" src="https://github.com/user-attachments/assets/cae1f550-9489-4507-b4ad-488e0ed2ee1a" />


3. **Timer Compare Registers**:
   - **TCMP0 and TCMP1**: Two 32-bit compare registers allowing users to set threshold values. When the counter reaches these values, the Timer IP can generate an interrupt signal.

<img width="951" height="665" alt="image" src="https://github.com/user-attachments/assets/6b1fc77a-0ab2-46b7-82e9-649cac81f4a0" />
<img width="898" height="644" alt="image" src="https://github.com/user-attachments/assets/fcc6ce6a-c152-47c9-94f5-b839cb20650f" />


4. **Timer Capture Registers**:
   - **TDR0 and TDR1**: Two 32-bit registers used to store the current counter value, serving time or frequency measurement purposes. These registers automatically update with the counter value every clock cycle.

<img width="708" height="677" alt="image" src="https://github.com/user-attachments/assets/cd49dd79-3a8e-4f9c-926c-e89de8a416d1" />


5. **Interrupt Mechanism**:
   - The Timer IP generates an interrupt signal (`tim_int`) when the counter reaches the value in the compare registers (both TCMP0 and TCMP1). Interrupts can be enabled/disabled via the TIER register and cleared via the interrupt status register.

<img width="965" height="582" alt="image" src="https://github.com/user-attachments/assets/c174fbc5-7be7-4b6d-b673-761b8589001b" />


6. **APB Interface (Advanced Peripheral Bus)**:
   - The Timer IP communicates with the CPU via the standard APB interface with signals: `tim_psel`, `tim_pwrite`, `tim_penable`, `tim_paddr`, `tim_pwdata`, `tim_prdata`. This allows the CPU to easily configure and read the status of the Timer IP.

  <img width="1685" height="768" alt="image" src="https://github.com/user-attachments/assets/e693501f-f13a-40b8-aeb9-0c4dbcee6819" />

  <img width="1340" height="697" alt="image" src="https://github.com/user-attachments/assets/db55e9a2-8887-411f-ae03-d55515999a22" />   

### **Timer IP Register Structure**


| Address | Register Name | Size | Function Description |
|---------|---------------|------|---------------------|
| **0x000** | **TCR (Timer Control Register)** | 32-bit | Timer control register<br>- Bit [0]: Timer enable (1: on, 0: off)<br>- Bit [1]: Prescaler enable (1: enable prescaler, 0: disable)<br>- Bit [11:8]: Prescaler division factor (0-8, corresponding to 2⁰ to 2⁸) |
| **0x004** | **TDR0 (Timer Data Register 0)** | 32-bit | Lower 32 bits of the 64-bit counter |
| **0x008** | **TDR1 (Timer Data Register 1)** | 32-bit | Upper 32 bits of the 64-bit counter |
| **0x00C** | **TCMP0 (Timer Compare Register 0)** | 32-bit | Compare value for lower 32 bits |
| **0x010** | **TCMP1 (Timer Compare Register 1)** | 32-bit | Compare value for upper 32 bits |
| **0x014** | **TIER (Timer Interrupt Enable Register)** | 32-bit | Interrupt enable register (bit [0]: enable/disable interrupt) |
| **0x018** | **TISR (Timer Interrupt Status Register)** | 32-bit | Interrupt status register (bit [0]: interrupt flag, write 1 to clear) |
| **0x01C** | **THCSR (Timer Halt Control Status Register)** | 32-bit | Halt control register in debug mode<br>- Bit [0]: Halt control (1: enable halt during debug, 0: disable)<br>- Bit [1]: Halt status (read-only, indicates current halt state) |

### **Applications of Timer IP**

The Timer IP has many important applications in embedded systems and SoCs:

**Real-Time Operating Systems (RTOS):**
- Generate periodic interrupts for the scheduler to perform task switching.
- Provide time base for delay and timeout functions.

**Time and Frequency Measurement:**
- Measure pulse width, time interval between events.
- Measure frequency of input signals.

**PWM (Pulse Width Modulation) Generation:**
- Control motor speed, LED brightness, or generate audio signals.

**Real-Time Clock (RTC):**
- Maintain time in applications requiring timestamps such as data loggers.

**Watchdog Timer:**
- Monitor system operation, reset the system when software errors are detected.

**Periodic Event Generation:**
- Activate tasks such as keyboard scanning, LED updates, ADC reading periodically.

**System Debug Support:**
- Pause the counter when in debug mode, allowing timer state inspection at breakpoints without losing the current count value.


# Physical Design of Timer IP (RTL-to-GDS Flow)

After completing the functional verification of the Timer IP through simulation, the next step is to take the design through the **synthesis and physical layout generation flow** – a critical phase in preparing for actual integrated circuit fabrication. This flow consists of several key stages: logic synthesis, placement and routing, GDS file export, and layout verification.

<img width="810" height="191" alt="image" src="https://github.com/user-attachments/assets/078a7c97-965b-4f2a-a906-d841de3e07b5" />


### 1. Logic Synthesis with Yosys

The goal of this step is to convert the Verilog code at the Register Transfer Level (RTL) into a **gate-level netlist** based on a specific **standard cell library**.

- **Tool used:** Yosys
- **Implementation process:** Yosys reads all Verilog source files of the Timer IP (including modules such as `apb_slave`, `reg_module`, `timer_top`), performs logic optimization, and maps the behavioral descriptions in the RTL code to basic logic gates available in the cell library (e.g., AND, OR, XOR, DFF).
- **Output:** A netlist file (`.v` format) detailing all instances and their interconnections. This serves as a crucial input for subsequent physical processing steps.

### 2. Placement and Routing with OpenROAD

With the netlist ready, the next step is to determine the physical locations of each cell on the chip surface and create the metal interconnections between them.

- **Tool used:** OpenROAD
- **Implementation process via the `openroad_timer_ip.tcl` script:**
  - **Input data handling:** Accepts the netlist from Yosys, timing constraint file (`.sdc`), and technology library.
  - **Floorplanning:** Determines chip dimensions, I/O pin locations, and allocates areas for major functional blocks.
  - **Placement:** Arranges logic cells into predefined rows and columns, optimizing for area and performance.

 <img width="1853" height="897" alt="image" src="https://github.com/user-attachments/assets/14e38543-7474-483b-83f1-61b98d3cdca9" />
    
  - **Clock Tree Synthesis (CTS):** With support from the `constraints.sdc` file, OpenROAD builds a clock distribution tree, ensuring the `sys_clk` signal reaches all flip-flops with minimal skew and meets timing requirements.
  - **Routing:** Creates metal interconnection paths between cells according to the netlist schematic.

  <img width="1853" height="895" alt="image" src="https://github.com/user-attachments/assets/4b5f157c-ebfd-49c4-8797-b0de24002205" />
    
- **Output:** A **DEF (Design Exchange Format)** file containing geometric information about cell positions and routing paths across various metal layers.
 <img width="1853" height="898" alt="image" src="https://github.com/user-attachments/assets/f82c6aa0-25a6-485c-9c33-54aedaf51586" />

### 3. Complete Layout Generation and GDS Export with Magic

To prepare for manufacturing, the design must be converted from a positional description (DEF) into a detailed geometric representation of actual material layers.

- **Tool used:** Magic VLSI Layout Tool
- **Implementation process:**
  - **Import DEF file:** Using Tcl commands within Magic, the DEF file from OpenROAD is read along with the corresponding technology library.
  - **Layout inspection and editing (if needed):** Magic allows viewing and manual editing of the layout to ensure no geometric violations exist.
  - **Export GDS file:** Using the command `gds write timer_top.gds` to generate a GDSII file – the industry-standard format containing all physical parameters (diffusion layers, polysilicon, metal layers) required by the foundry.

  <img width="1854" height="897" alt="image" src="https://github.com/user-attachments/assets/cceb9215-1a4a-4037-b1e4-a5d51a8221ca" />


### 4. Layout Verification and Visualization with KLayout

Before proceeding to "Tape-out" – sending the design for fabrication – a final verification is necessary to ensure no design rule violations exist.

- **Tool used:** KLayout
- **Role:**
  - **Detailed layout viewing:** KLayout provides the ability to display different color-coded layers, allowing zooming, panning, and precise measurements on the layout.
  - **Visual inspection:** Engineers can easily identify potential issues such as layer overlaps, insufficient spacing between paths, or connectivity problems.
- **Final result:** A complete Timer IP layout, verified and ready for the **Tape-out** stage – the final step before mass production.

<img width="1853" height="893" alt="image" src="https://github.com/user-attachments/assets/79de7bcf-0b28-4481-b695-6932e584298b" />

<img width="1851" height="893" alt="image" src="https://github.com/user-attachments/assets/935dc7d1-43db-42d1-bb00-c63194249ce3" />


## Conclusion

This RTL-to-GDS flow not only closes the integrated circuit design cycle from concept to physical product but also provides valuable hands-on experience for any IC design engineer seeking to deeply understand the synthesis and physical layout creation process. The Timer IP with its flexible features, including diverse frequency division capability (from 1 to 256), halt capability in debug mode, and standard APB interface, allows this peripheral block to adapt to many different applications – from high-precision time measurement, long-duration timing, to system debug support – and can be easily integrated into complex SoC designs.
