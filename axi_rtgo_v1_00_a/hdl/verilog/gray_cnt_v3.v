`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2018 15:39:07
// Design Name: 
// Module Name: gray_cnt_v3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gray_cnt_v3(
   input wire clk,
   input wire nreset,
   input wire [SIZE-1:0]init_count_bin,
   output wire [SIZE-1:0]q
   );
parameter SIZE = 128;

integer i;
reg [SIZE-1:0]gray_cnt;
reg [SIZE-1:0]bin;
reg [SIZE-1:0]next_gray_cnt;
reg [SIZE-1:0]init_count_gray;

always @*
begin
  //convert gray-to-bin
  for (i=0; i<SIZE; i=i+1)
    bin[i] = ^(gray_cnt>>i);
  //increment binary
  bin=bin+1;
  //convert bin-to-gray
  next_gray_cnt = (bin>>1)^bin;
  init_count_gray =(init_count_bin>>1)^init_count_bin;
end

always @(posedge clk or negedge nreset)
  if(~nreset)
   gray_cnt <= init_count_gray;
  else
   gray_cnt <= next_gray_cnt;

assign q=gray_cnt;

endmodule
