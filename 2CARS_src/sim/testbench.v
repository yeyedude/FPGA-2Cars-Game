`timescale 1ns / 1ps

module testbench;

reg clk = 0;
wire Hsync;
wire Vsync;
wire [3:0] RED;
wire [3:0] GRN;
wire [3:0] BLU;
wire [4:0] data;
parameter delay           = 1;
reg rstn = 0;
top UUT (clk, rstn, Hsync,Vsync,RED,GRN,BLU);
fibonacci fibonacci (clk, rstn, data);


always #5 clk = ~clk;

initial begin
  $display("===================");
  $display("Start Test Scenario");
  $display("===================");
  
  repeat(2)  @(posedge clk); #delay;
  rstn          = 1'b0;
  
  repeat(2) @(posedge clk); #delay;
  rstn          = 1'b1;
  repeat(1)  @(posedge clk); #delay;

  //wait (result_1); i =16; #1; disp_error(result_0, 30); 
  repeat(1) @(posedge clk); #delay;



  repeat(10) @(posedge clk);#delay;

  
  repeat(2) @(posedge clk);#delay;
  
  repeat(10) @(posedge clk);#delay;
  
  
end

endmodule