module barcode39_top(
  // inputs
	input 	clk,
	input	start,
	input	barcode_in,
	// outputs
	output	barcode_out
);

reg out;

always@(posedge clk)
	if (!start)
		out <= 1'bZ;
	else
		out <= barcode_in;

assign barcode_out = out;

endmodule