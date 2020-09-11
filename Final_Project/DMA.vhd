LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY DMA IS
	GENERIC (
		width_bus_AD : INTEGER := 20;
		sel_width : INTEGER :=3;
		d_width : INTEGER := 16
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
		address : OUT std_logic_vector(width_bus_AD - 1 DOWNTO 0);
		RW : OUT std_logic;
		ALE : BUFFER std_logic;
		EOP : OUT std_logic
	);
END DMA;

ARCHITECTURE DMA_behavioral OF DMA IS

BEGIN
	PROCESS (clk)
	VARIABLE transfers_count : INTEGER := 0;
	CONSTANT MAX_DMA_REQUESTS : INTEGER := 40;--99;
	BEGIN
		IF (rst = '1') THEN
			HOLD <= '0';
			DACK0 <= '0';
			DACK1 <= '0';
			address(width_bus_AD-1 downto  (width_bus_AD-sel_width)) <= "111";---ZZZZZZZZZZZZ 
			address((width_bus_AD -sel_width -1) downto 0) <= (OTHERS => 'Z'); 
			RW <= '0';
			transfers_count := 0; -- reset counter
			ALE <= '0';
			EOP <= '0';
		ELSE
			IF (en = '1') THEN
				IF (rising_edge(clk)) THEN
					IF (transfers_count < MAX_DMA_REQUESTS) THEN						  
					 
					IF ((DREQ0 = '1' OR DREQ1 = '1') AND HOLDA = '0') THEN
						HOLD <= '1'; -- send HOLD to CPU
						IF (DREQ0 = '1') THEN
							DACK0 <= '0';
						ELSE -- DREQ1 == '1'
							DACK1 <= '0';
						END IF;
						address(width_bus_AD-1 downto  (width_bus_AD-sel_width)) <= "111";---ZZZZZZZZZZZZ 
						address((width_bus_AD -sel_width -1) downto 0) <= (OTHERS => 'Z'); 
						RW <= '0';
					ELSIF (DREQ0 = '1' AND HOLDA = '1') THEN
						HOLD <= '0';
						address <= "000" & std_logic_vector(to_unsigned(transfers_count, (address'LENGTH - sel_width))); -- put MEM address
						ALE <= '1';
						RW <= '0';
						DACK0 <= '1';
						DACK1 <= '0';
						transfers_count := transfers_count + 2;
					ELSIF (DREQ1 = '1' AND HOLDA = '1') THEN
						HOLD <= '0';
						address <= "001" & std_logic_vector(to_unsigned(transfers_count, (address'LENGTH - sel_width))); -- put MEM address
						ALE <= '1';
						RW <= '0';
						DACK0 <= '0';
						DACK1 <= '1';
						transfers_count := transfers_count + 2;
					ELSE
						ALE <= '0';
	  
					END IF;
					ELSE
						transfers_count := 0;
						EOP <= '1';
						address <= (OTHERS => 'Z');
					END IF;
 
				ELSE
					HOLD <= '0';
					DACK0 <= '0';
					DACK1 <= '0';
					address <= (OTHERS => 'Z');
					IF (ALE = '1') then
					   RW <= '1';
					   ALE <= '0';
					else
					  RW <= '0';
					end if;
				END IF;
 
			ELSE -- if idle
				HOLD <= '0';
				DACK0 <= '0';
				DACK1 <= '0';
				address <= (OTHERS => 'Z');
				RW <= '1';
			END IF;
		END IF;
	END PROCESS;
END DMA_behavioral;
