# SDC File for ULA Circuit

# ---------------------------------------------------------
# Define the primary clock
# ---------------------------------------------------------

# Define clock "clk" with a period of 10 ns (100 MHz)
create_clock -name clock -period 10 [get_ports clk]

