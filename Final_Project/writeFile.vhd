library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity writeFile is
	GENERIC(d_width:INTEGER:=16);

PORT(
input_top : in std_logic_vector(15 DOWNTO 0);
clk : in std_logic;
en : in std_logic
);
end writeFile;

architecture arc_writeFile of writeFile is
--	signal out_int : integer;
begin

WRITE_FILE: process (clk,en)
  variable VEC_LINE : line;
  --CONSTANT file_write_loc :string(1 to 57):="C:\Users\BAR\Desktop\DCS\DCS_EE\Final_Project\Barcode.txt";
    CONSTANT file_write_loc :string(1 to 45):="C:\Users\VladKo\Documents\MSc\BGU\Barcode.txt";

	file output_file : text open write_mode is file_write_loc;
begin
  if rising_edge(clk)and en ='1' then
    write (VEC_LINE, to_integer(unsigned(input_top)));
    writeline (output_file, VEC_LINE);
  end if;
end process WRITE_FILE;


end arc_writeFile;
