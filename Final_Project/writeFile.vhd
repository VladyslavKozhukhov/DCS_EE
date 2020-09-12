LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;
USE ieee.numeric_std.ALL;

ENTITY writeFile IS
	GENERIC (d_width : INTEGER := 16);

	PORT (
		input_top : IN std_logic_vector(15 DOWNTO 0);
		clk : IN std_logic;
		en : IN std_logic
	);
END writeFile;

ARCHITECTURE arc_writeFile OF writeFile IS

BEGIN
	WRITE_FILE : PROCESS (clk, en)
		VARIABLE VEC_LINE : line;
		CONSTANT file_write_loc : STRING(1 TO 61) := "C:\Users\BAR\Desktop\DCS_new\DCS_EE\Final_Project\Barcode.txt";
		--CONSTANT file_write_loc :string(1 to 45):="C:\Users\VladKo\Documents\MSc\BGU\Barcode.txt";

		FILE output_file : text OPEN write_mode IS file_write_loc;
	BEGIN
		IF falling_edge(clk)AND en = '1' THEN
			write (VEC_LINE, to_integer(unsigned(input_top)));
			writeline (output_file, VEC_LINE);
		END IF;
	END PROCESS WRITE_FILE;
	
END arc_writeFile;