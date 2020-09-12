LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.numeric_std.ALL;

ENTITY counter IS
	GENERIC (d_width : INTEGER := 16);
	PORT (
		clk : IN std_logic;
		rst : IN std_logic;
		en : IN std_logic;
		count_out : OUT std_logic_vector(d_width - 1 DOWNTO 0)
	);
END counter;

ARCHITECTURE counter_arch OF counter IS
BEGIN
	PROCESS (clk)
		VARIABLE count : INTEGER := 0;
		CONSTANT maxCount : INTEGER := (2 ** d_width - 1);
	BEGIN
		IF (rising_edge (clk)) THEN
			IF (rst = '1') THEN
				count := 0;
			ELSIF (en = '1') THEN
				IF (count = maxCount) THEN -- OVERFLOW
					count := 0;
				ELSE
					count := count + 1;
				END IF;
			ELSE -- if disabled
				count := count;
			END IF;
		END IF;
		count_out <= std_logic_vector(to_unsigned(count, count_out'length));
	END PROCESS;
END counter_arch;