LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
-------------------------------------------------------------
ENTITY tb_write IS
END tb_write;
------------- complete the top Architecture code --------------
ARCHITECTURE arc_tb_write OF tb_write IS
	COMPONENT writeFile
		PORT (
			input_top : IN CHARACTER;
			clk : IN std_logic
		);
	END COMPONENT;
	SIGNAL input_read : CHARACTER := 'y';
	SIGNAL clk : std_logic;

BEGIN
	WD : writeFile PORT MAP(input_read, clk);

	clock_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR 100 ns;
		clk <= '1';
		WAIT FOR 100 ns;
	END PROCESS;

END arc_tb_write;