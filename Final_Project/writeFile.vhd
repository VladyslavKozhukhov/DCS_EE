library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity writeFile is
PORT(
input_top : in character ;
clk : in std_logic
);
end writeFile;

architecture arc_writeFile of writeFile is
	
begin

WRITE_FILE: process (clk)
  variable VEC_LINE : line;
  CONSTANT file_write_loc :string(1 to 45):="C:\Users\VladKo\Documents\MSc\BGU\Barcode.txt";
	file output_file : text open write_mode is file_write_loc;
begin
  if rising_edge(clk) then
    write (VEC_LINE, input_top);
    writeline (output_file, VEC_LINE);
  end if;
end process WRITE_FILE;


end arc_writeFile;
