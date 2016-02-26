# For Modelsim PE6.5a use
#vsim -novopt work.cpu86_top_tb

#For Modelsim SE6.5a use
vsim -voptargs="+acc+sram" work.cpu86_top_tb


set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run 200 ms
quit -f
