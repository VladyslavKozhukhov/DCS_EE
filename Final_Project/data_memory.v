module data_memory #(
//Parameters
parameter DATA_WIDTH = 16,  // 16bit word size
parameter ADDR_WIDTH = 14   // 16KB
) (
//Ports
input clk, 
input RW, 
input [ADDR_WIDTH - 1 : 0] address, 
input [DATA_WIDTH - 1 : 0] data_in, 
output [DATA_WIDTH - 1 : 0] data_out
);
 
//Create memory
reg [DATA_WIDTH - 1 : 0] mem [(2 ** ADDR_WIDTH) - 1 : 0];
reg [DATA_WIDTH - 1 : 0] out;


always @(posedge clk) begin
if (RW) begin
 out <= mem[address];
 end
 else begin
		 mem[address] <= data_in;
		 out <= {DATA_WIDTH{1'bZ}};
 end
end
assign data_out = out;
endmodule