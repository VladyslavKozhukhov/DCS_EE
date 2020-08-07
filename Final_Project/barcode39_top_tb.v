module barcode39_top_tb();

reg clk;
reg start;
reg barcode_in;

wire barcode_out;

// clock generation
initial begin
  clk = 0;
  forever clk = #20 ~clk;
end

// DUT instantiation
barcode39_top DUT
(.start(start),
 .clk(clk),
 .barcode_in(barcode_in),
 .barcode_out(barcode_out));


initial begin
  start = 1'b0;
  /*
  #7
  start = 1'b0;
  barcode_in = 1'b0;
  
  #7
  start = 1'b1;
  barcode_in = 1'b0;
  
  #7
  start = 1'b0;
  barcode_in = 1'b1;
  
  #7
  start = 1'b1;
  barcode_in = 1'b1;
  
  #7
  start = 1'b0;
  barcode_in = 1'b0;
  
  #7
  start = 1'b1;
  barcode_in = 1'b0;
  
  #7
  start = 1'b0;
  barcode_in = 1'b1;
  
  #7
  start = 1'b1;
  barcode_in = 1'b1;
  */
end


endmodule
