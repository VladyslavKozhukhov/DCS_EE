LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY DMA_tb IS
END DMA_tb;

ARCHITECTURE Behavioral OF DMA_tb IS

	COMPONENT DMA IS
		GENERIC (
			size : INTEGER;
			address_size : INTEGER
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
	END COMPONENT;

	SIGNAL size : INTEGER := 16;
	SIGNAL address_size : INTEGER := 7;
	SIGNAL clk, rst, en, DREQ0, DREQ1, HOLDA, HOLD, DACK0, DACK1, RW, EOP, ALE : std_logic;
	SIGNAL address : std_logic_vector(address_size - 1 DOWNTO 0);

BEGIN
	dut : DMA
	GENERIC MAP(size => size, address_size => address_size)
	PORT MAP(clk => clk, rst => rst, en => en, DREQ0 => DREQ0, DREQ1 => DREQ1, HOLDA => HOLDA, HOLD => HOLD, DACK0 => DACK0, DACK1 => DACK1, address => address, RW => RW, EOP => EOP, ALE => ALE);

	-- Clock process definitions
	clock_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR 25 ns;
		clk <= '1';
		WAIT FOR 25 ns;
	END PROCESS;

	gen_HOLDA : PROCESS
	BEGIN
		WAIT FOR 50 ns;
		IF (HOLD = '1') THEN
			HOLDA <= '1';
		ELSE
			HOLDA <= '0';
		END IF;
	END PROCESS;

	gen_DREQ : PROCESS
	BEGIN
		DREQ0 <= '1';
		WAIT UNTIL HOLDA = '1';
		WAIT FOR 50ns;
		DREQ0 <= '0';
		WAIT UNTIL HOLDA = '0';
		WAIT FOR 50ns;
	END PROCESS;

	-- Stimulus process
	stim_proc : PROCESS
	BEGIN
		rst <= '1';
		en <= '1';
		WAIT FOR 100 ns;
		rst <= '0';
		WAIT FOR 500 ns;
		en <= '0';
		WAIT FOR 100 ns;
		en <= '1';
		WAIT;
	END PROCESS;
END Behavioral;