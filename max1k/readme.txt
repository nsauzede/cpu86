CPU86 - Free VHDL CPU8088 IP core                                             
Copyright (C) 2005-2010 HT-LAB 

Quick run: 

1) Open a DOSBox/Cygwin shell 
2) Navigate to the web_cpu88/Modelsim directory. 
3) Execute run.bat 

See website for more details. 

The CPU86 core is released under the GNU GPL license. For more information read the copying.txt 
file located in this directory.
                                                                                                                                                                                                         
Bugs/Feedback: http://www.ht-lab.com/misc/feedback.html
  
Version 0.83  Added ghdl script created by Lubomir Rintel <lkundrak@v3.sk> 
Version 0.82  RCR REG,CL with CF set not always produced the right result.
Version 0.81, Fixed CALL [REG] instruction, under certain circumstances the segment register was not set to use CS.
Version 0.80, Full design release under GNU GPL. Fixed "LES SI,[xx]" instruction.
Version 0.75, Ported some HTL8086 fixes back to the CPU86.
Version 0.70, Fixed trace interrupt, split design into smaller files, added opencores UART.
Version 0.69, Fixed INTR logic and SHL instruction as reported by Rick Kilgore
Version 0.69, Added INTA/RDN fix from Rick Kilgore
Version 0.68, Fixed INTA vector. The vector is read during the second interrupt acknowledge cycle, in version 0.67
the vector was always 0. 

Good Luck,
Hans.
www.ht-lab.com


