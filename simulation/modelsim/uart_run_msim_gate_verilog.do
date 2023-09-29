transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {uart.vo}

vlog -vlog01compat -work work +incdir+D:/Quartus\ II/Project/Week_end {D:/Quartus II/Project/Week_end/uart_tb.v}

vsim -t 1ps -L altera_ver -L cycloneive_ver -L gate_work -L work -voptargs="+acc"  testbench

source uart_dump_all_vcd_nodes.tcl
add wave *
view structure
view signals
run -all
