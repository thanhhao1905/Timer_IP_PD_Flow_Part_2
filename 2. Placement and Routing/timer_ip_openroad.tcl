puts "   OpenROAD Manual Flow - TIMER IP LAB"


# --- CIEL PDK ---
set ciel_version "0fe599b2afb6708d281543108caf8310912f54af"
set ::env(PDK_ROOT) "~/openlane/pdks/$ciel_version"
set ::env(PDK) "sky130A"
set pdk_dir "$::env(PDK_ROOT)/$::env(PDK)"
puts "Using PDK: $pdk_dir"


# --- Load tech / libs ---
read_lef     "$pdk_dir/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"
read_lef     "$pdk_dir/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
read_liberty "$pdk_dir/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"


# --- Load design ---
read_verilog timer_top_synth.v
link_design timer_top
report_design_area


# --- Constraints ---
puts "\nReading constraints.sdc..."
read_sdc constraints.sdc
puts "Clocks defined:"
get_clocks *


# --- Floorplan ---
initialize_floorplan \
  -die_area  {0 0 300 300} \
  -core_area {20 20 280 280} \
  -site unithd


# --- Tapcell insertion ---
tapcell \
  -tapcell_master "sky130_fd_sc_hd__tapvpwrvgnd_1" \
  -distance 50 \
  -halo_width_x 10 \
  -halo_width_y 10


# --- Tracks definition for sky130 ---
make_tracks li1  -x_offset 0.17 -x_pitch 0.34 -y_offset 0.17 -y_pitch 0.34
make_tracks met1 -x_offset 0.17 -x_pitch 0.34 -y_offset 0.17 -y_pitch 0.34
make_tracks met2 -x_offset 0.23 -x_pitch 0.46 -y_offset 0.23 -y_pitch 0.46
make_tracks met3 -x_offset 0.34 -x_pitch 0.68 -y_offset 0.34 -y_pitch 0.68
make_tracks met4 -x_offset 0.46 -x_pitch 0.92 -y_offset 0.46 -y_pitch 0.92
make_tracks met5 -x_offset 1.70 -x_pitch 3.40 -y_offset 1.70 -y_pitch 3.40



# --- Pin placement ---
place_pins \
  -hor_layers {met3} \
  -ver_layers {met4} \
  -corner_avoidance 15 \
  -min_distance 3


# --- Set wire RC for placement ---
set_wire_rc -layer met2


# --- Global placement ---
global_placement \
  -density 0.7 \
  -pad_left 2 \
  -pad_right 2


# --- Detailed placement ---
detailed_placement


# --- Clock Tree Synthesis (single clock) ---
puts "\nRunning CTS for sys_clk..."
clock_tree_synthesis \
  -root_buf sky130_fd_sc_hd__clkbuf_1 \
  -buf_list {sky130_fd_sc_hd__clkbuf_1 sky130_fd_sc_hd__clkbuf_2 sky130_fd_sc_hd__clkbuf_4} \
  -clk_nets sys_clk \
  -wire_unit 20


# Run detailed placement after CTS
detailed_placement


# --- Post-CTS optimization ---
puts "\nRunning post-CTS optimization..."
repair_timing \
  -setup \
  -hold


# --- Fill cell insertion ---
puts "\nInserting filler cells..."
filler_placement "sky130_fd_sc_hd__fill_1 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_8"


# --- Global routing ---
puts "\nRunning global routing..."
global_route \
  -congestion_report_iter_step 5 \
  -verbose


# --- Save after CTS and routing ---
write_def timer_top.def
write_db  timer_top.odb
write_verilog timer_top.v
write_sdc  timer_top.sdc


puts "✓ Saved: timer_top.def / timer_top.odb / timer_top.v / timer_top.sdc"


# --- Reports ---
puts "\n=== CTS REPORT ==="
report_cts

puts "\n=== GLOBAL ROUTING DETAILS ==="
puts "Global routing completed. Check congestion report for details."


write_guides timer_top.guide


estimate_parasitics -global_routing

puts "\n=== TIMING CHECK ==="
report_checks -path_delay min_max -group_count 10 -endpoint_count 10


puts "\n=== POWER REPORT ==="
report_power


puts "\nTIMER IP LAB DONE"
puts "Openroad -GUI and view Clock Tree for sys_clk"


