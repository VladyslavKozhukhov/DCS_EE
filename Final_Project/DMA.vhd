LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY DMA IS
	GENERIC (
		size : INTEGER := 16;
		address_size : INTEGER := 7
	);
	PORT (
		clk : IN std_logic;
		rst : IN std_logic;
		en : IN std_logic;
		DREQ0 : IN std_logic;
		DREQ1 : IN std_logic;
		HOLDA : IN std_logic;
		HOLD : OUT std_logic;
		DACK0 : OUT std_logic; 
		DACK1 : OUT std_logic; 
		address : OUT std_logic_vector(address_size - 1 DOWNTO 0);
		RW : OUT std_logic;
		ALE : OUT std_logic;
		EOP : OUT std_logic
	);
END DMA;

ARCHITECTURE DMA_behavioral OF DMA IS
 
BEGIN
	PROCESS (clk)
	VARIABLE transfers_count : INTEGER := 0;
	CONSTANT MAX_DMA_REQUESTS : INTEGER :=5 ;--99;
	BEGIN
		IF (rst = '1') THEN
			HOLD <= '0';
			DACK0 <= '0';
			DACK1 <= '0';
			address <= (OTHERS => 'Z'); -- disconnect from bus
			RW <= '0';
			transfers_count := 0; -- reset counter
		ELSE
			IF (en = '1') THEN
				IF (rising_edge(clk)) THEN
					IF ((DREQ0 = '1' OR DREQ1 = '1') AND HOLDA = '0') THEN
						HOLD <= '1'; -- send HOLD to CPU
						IF (DREQ0 = '1') THEN
							DACK0 <= '0';
						ELSE -- DREQ1 == '1'
							DACK1 <= '0';
						END IF;
						address <= (OTHERS => 'Z'); -- disconnect from bus
						RW <= '0';
					ELSIF ((DREQ0 = '1' OR DREQ1 = '1') AND HOLDA = '1') THEN
						HOLD <= '0';
						IF (DREQ0 = '1') THEN
							DACK0 <= '1';
						ELSE -- DREQ1 == '1'
							DACK1 <= '1';
						END IF;
						address <= std_logic_vector(to_unsigned(transfers_count, address'length)); -- put MEM address
						RW <= '1';
						transfers_count := transfers_count + 1;
						-- EOP
						IF (transfers_count = MAX_DMA_REQUESTS) THEN
							transfers_count := 0;
							EOP <= '1';
						ELSE
							EOP <= '0';
						END IF;
					END IF;
				END IF;
			ELSE -- if idle
				HOLD <= '0';
				DACK0 <= '0';
				DACK1 <= '0';
				address <= (OTHERS => 'Z'); -- disconnect from bus
				RW <= '0';
			END IF;
		END IF;
	END PROCESS;
 
END DMA_behavioral;