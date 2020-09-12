LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Decoder_tb IS
END Decoder_tb;

ARCHITECTURE Behavioral OF Decoder_tb IS

	COMPONENT Decoder
		GENERIC (
			SEL_WIDTH : NATURAL
		);
		PORT (
			sel : IN std_logic_vector(SEL_WIDTH - 1 DOWNTO 0);
			decoder_out : OUT std_logic_vector(2 ** SEL_WIDTH - 1 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL SEL_WIDTH : INTEGER := 3;
	SIGNAL sel : std_logic_vector(SEL_WIDTH - 1 DOWNTO 0);
	SIGNAL decoder_out : std_logic_vector(2 ** SEL_WIDTH - 1 DOWNTO 0);

BEGIN
	dut : Decoder
	GENERIC MAP(SEL_WIDTH => SEL_WIDTH)
	PORT MAP(sel => sel, decoder_out => decoder_out);
	-- Stimulus process
	stim_proc : PROCESS
	BEGIN
		sel <= "000";
		WAIT FOR 50 ns;
		sel <= "001";
		WAIT FOR 50 ns;
		sel <= "010";
		WAIT FOR 50 ns;
		sel <= "011";
		WAIT FOR 50 ns;
		sel <= "100";
		WAIT FOR 50 ns;
		sel <= "101";
		WAIT FOR 50 ns;
		sel <= "110";
		WAIT FOR 50 ns;
		sel <= "111";
		WAIT FOR 50 ns;
		sel <= "000";
		WAIT;
	END PROCESS;
END Behavioral;