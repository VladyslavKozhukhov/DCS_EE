LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE iEEE.std_logic_arith.ALL;

ENTITY DFF IS
	GENERIC (d_width : INTEGER := 16);
	PORT (
		D : IN std_logic_vector(d_width - 1 DOWNTO 0);
		clk : IN std_logic;
		rst : IN std_logic;
		Q : BUFFER std_logic_vector(d_width - 1 DOWNTO 0));
END DFF;

ARCHITECTURE dff_behavioral OF DFF IS

BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF (rst = '1') THEN -- async reset
			Q <= (OTHERS => '0');
		ELSE
			IF (rising_edge(clk)) THEN
				Q <= D;
			ELSE
				Q <= Q;
			END IF;
		END IF;
	END PROCESS;
END dff_behavioral;