LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.Numeric_Std.ALL;

ENTITY ale_module IS
	GENERIC (address_size : INTEGER := 13);
	PORT (
		addr_data : IN std_logic_vector(address_size - 1 DOWNTO 0);
		en : IN std_logic;
		en_main : IN std_logic;
		reset : IN std_logic;
		addr_out : OUT std_logic_vector(address_size - 1 DOWNTO 0)
	);
END ale_module;

ARCHITECTURE arc_ale_module OF ale_module IS
	SIGNAL add_tmp : INTEGER;
BEGIN
	PROCESS (reset, addr_data, en)
	VARIABLE addr_out_tmp : INTEGER := 0;

	BEGIN
		IF (reset = '1') THEN
			addr_out_tmp := 0;
		ELSIF (en = '1' OR en_main = '1') THEN
			addr_out_tmp := to_integer(unsigned(addr_data(address_size - 1 DOWNTO 0)));
		ELSE
			addr_out_tmp := addr_out_tmp;
		END IF;
		add_tmp <= addr_out_tmp;
	END PROCESS;
	addr_out <= std_logic_vector(to_unsigned(add_tmp, addr_out'length));

END arc_ale_module;