# ====================================================
# Constraints file for Timer Module
# ====================================================

#-------------------------------------------------------------------------------
# 1. Clock Definition - 50MHz (period 20ns)
#-------------------------------------------------------------------------------
create_clock -name sys_clk -period 20 [get_ports sys_clk]

#-------------------------------------------------------------------------------
# 2. Clock Uncertainty (non-ideal clock)
#-------------------------------------------------------------------------------
set_clock_uncertainty 0.5 [get_clocks sys_clk]

#-------------------------------------------------------------------------------
# 3. Reset Input Delay
#-------------------------------------------------------------------------------
set_input_delay 2.0 -clock sys_clk [get_ports sys_rst_n]

#-------------------------------------------------------------------------------
# 4. APB Interface Input Delays (from APB master)
#-------------------------------------------------------------------------------
set_input_delay 2.0 -clock sys_clk [get_ports {
    tim_psel
    tim_pwrite
    tim_penable
    tim_paddr[*]
    tim_pwdata[*]
    tim_pstrb[*]
}]

#-------------------------------------------------------------------------------
# 5. Debug Mode Input Delay
#-------------------------------------------------------------------------------
set_input_delay 2.0 -clock sys_clk [get_ports dbg_mode]

#-------------------------------------------------------------------------------
# 6. Output Delays (to APB master)
#-------------------------------------------------------------------------------
set_output_delay 4.0 -clock sys_clk [get_ports {
    tim_prdata[*]
    tim_pready
    tim_pslverr
    tim_int
}]

#-------------------------------------------------------------------------------
# 7. False Paths (optional - based on design understanding)
#-------------------------------------------------------------------------------

# Reset is asynchronous - no need to meet timing
set_false_path -setup -hold -from [get_ports sys_rst_n]

# Debug mode signal is asynchronous/control signal
set_false_path -setup -hold -to [get_ports dbg_mode]

# Interrupt output - no timing requirement to external
set_false_path -setup -hold -to [get_ports tim_int]

