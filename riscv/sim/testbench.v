// testbench top module file
// for simulation only

`timescale 1ns/1ps
module testbench;

reg clk;
reg rst;

riscv_top #(.SIM(1)) top(
    .EXCLK(clk),
    .btnC(rst),
    .Tx(),
    .Rx(),
    .led()
);

initial begin
  $dumpfile("/mnt/c/Users/18303/Desktop/cpu/CPU_ACM_2021/riscv/test/out.vcd");
  $dumpvars;

  clk=0;
  rst=1;
  repeat(50) #1 clk=!clk;
  rst=0; 
  repeat(3000)  #1 clk=!clk;

  $finish;
end

endmodule