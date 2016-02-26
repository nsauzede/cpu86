onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -radix hexadecimal /cpu86_top_tb/clock_40mhz
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/abus
add wave -noupdate -format Logic /cpu86_top_tb/u_0/csramn
add wave -noupdate -format Logic /cpu86_top_tb/u_0/csromn
add wave -noupdate -format Logic /cpu86_top_tb/u_12/nce
add wave -noupdate -format Logic /cpu86_top_tb/u_12/noe
add wave -noupdate -format Logic /cpu86_top_tb/u_0/wrn
add wave -noupdate -format Logic /cpu86_top_tb/u_0/iom
add wave -noupdate -format Logic -radix hexadecimal /cpu86_top_tb/csramn
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/dbus
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/dbus_in
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpuproc/instr.ireg
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpubiu/shift/reg72_s
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /cpu86_top_tb/u_0/u_0/u_0/sin
add wave -noupdate -format Literal -radix ascii /cpu86_top_tb/udbus
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpudpath/ccbus
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpudpath/ax_s
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpudpath/bx_s
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpudpath/cx_s
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpudpath/dx_s
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpudpath/si_s
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpudpath/di_s
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpudpath/bp_s
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpudpath/sp_s
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpudpath/ss_s
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpudpath/ds_s
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpudpath/es_s
add wave -noupdate -format Literal -radix hexadecimal /cpu86_top_tb/u_0/u_1/cpudpath/cs_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {67234219 ns} 0}
configure wave -namecolwidth 301
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {67233522 ns} {67235193 ns}
