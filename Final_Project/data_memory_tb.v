module data_memory_tb #(
//Parameters
parameter DATA_WIDTH = 16,  // 16bit word size
parameter ADDR_WIDTH = 14   // 16KB
);

reg clk;
reg RW;
reg [ADDR_WIDTH - 1 : 0] address;
reg [DATA_WIDTH - 1 : 0] data_in;

wire [DATA_WIDTH - 1 : 0] data_out;

// clock generation - f = 20MHz - T = 50nsec
initial begin
  clk = 0;
  forever clk = #25 ~clk;  // negate clk every 25nsec
end

// DUT instantiation
data_memory DUT
(.clk(clk),
 .RW(RW),
 .address(address),
 .data_in(data_in),
 .data_out(data_out));


initial begin
  RW = 1'b0;
  #7
  // write 1 in address 0x0001
  address = 0;
  data_in = 1;
  #20
  // read value in address 0x0001
  RW = 1'b1;
end


endmodule

