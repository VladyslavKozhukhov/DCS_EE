LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE iEEE.std_logic_arith.ALL;

ENTITY ale_module IS
	GENERIC (size : INTEGER := 16);
	PORT (
		addr_data : IN std_logic_vector(size - 1 DOWNTO 0);
		en : IN std_logic;
		reset : IN std_logic;
		addr_out : OUT std_logic_vector(size - 1 DOWNTO 0));
END ale_module;

ARCHITECTURE arc_ale_module OF ale_module IS
	SIGNAL addr_out_tmp : std_logic_vector(size - 1 DOWNTO 0);

BEGIN
	PROCESS (reset, addr_data, en)
	BEGIN
		IF (reset = '1') THEN
			addr_out_tmp <= (OTHERS => '0');
		ELSIF (en = '1') THEN
			addr_out_tmp <= addr_data;
		ELSE
			addr_out_tmp <= addr_out_tmp;
		END IF;
	END PROCESS;
	addr_out <= addr_out_tmp;

END arc_ale_module;