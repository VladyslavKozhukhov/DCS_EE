LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;

ENTITY readFile IS
	PORT (
		input_top : OUT std_logic
	);
END readFile;

ARCHITECTURE arc_readFile OF readFile IS
	SIGNAL input : std_logic;
	SIGNAL clk : std_logic := '0';
	CONSTANT clk_period : TIME := 200 ns;
BEGIN
	input_top <= input;

	read_proc :
	PROCESS
		CONSTANT file_read_loc :string(1 to 61):="C:\Users\BAR\Desktop\DCS_new\DCS_EE\Final_Project\scanner.txt";
		-- CONSTANT file_read_loc : STRING(1 TO 45) := "C:\Users\VladKo\Documents\MSc\BGU\Scanner.txt";

		FILE input_file : text OPEN read_mode IS file_read_loc;
		-- file input_file: TEXT is in "Scanner.txt";
		VARIABLE rdline : LINE;

	BEGIN
		WHILE NOT endfile(input_file) LOOP
			readline(input_file, rdline);
			FOR j IN rdline'RANGE LOOP
				IF rdline(j) = '1' THEN
					input <= '1';
				ELSE
					input <= '0';
				END IF;
				WAIT UNTIL falling_edge(clk);
			END LOOP;
		END LOOP;
		WAIT;
	END PROCESS;
	CLOCK :
	PROCESS
	BEGIN
		WAIT FOR clk_period/2;
		clk <= NOT clk;
	END PROCESS;

END arc_readFile;