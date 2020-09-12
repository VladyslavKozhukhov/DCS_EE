LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
-------------------------------------------------------------
ENTITY tb_read IS
END tb_read;
------------- complete the top Architecture code --------------
ARCHITECTURE arc_tb_read OF tb_read IS
	COMPONENT readFile
		PORT (
			input_top : OUT std_logic
		);
	END COMPONENT;
	SIGNAL input_read : std_logic;

BEGIN
	RD : readFile PORT MAP(input_read);
END arc_tb_read;