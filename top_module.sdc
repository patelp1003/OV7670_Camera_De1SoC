
    create_clock -period 20 [get_ports clk]

    derive_pll_clocks -create_base_clocks
    derive_clock_uncertainty

