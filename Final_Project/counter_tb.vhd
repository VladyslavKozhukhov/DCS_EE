LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY counter_tb IS
END counter_tb;

ARCHITECTURE Behavioral OF counter_tb IS

	COMPONENT counter
		GENERIC (size : INTEGER);
		PORT (
			clk : IN std_logic;
			rst : IN std_logic;
			en : IN std_logic;
			count_out : OUT std_logic_vector(size - 1 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL size : INTEGER := 16;
	SIGNAL clk, rst, en : std_logic;
	SIGNAL count_out : std_logic_vector(size - 1 DOWNTO 0);

BEGIN
	dut : counter GENERIC MAP(size => size) PORT MAP(clk => clk, rst => rst, en => en, count_out => count_out);
	-- Clock process definitions
	clock_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR 25 ns;
		clk <= '1';
		WAIT FOR 25 ns;
	END PROCESS;
	-- Stimulus process
	stim_proc : PROCESS
	BEGIN
		en <= '0';
		WAIT FOR 25 ns;
		rst <= '1';
		WAIT FOR 25 ns;
		rst <= '0';
		WAIT FOR 25ns;
		en <= '1';
		WAIT FOR 200ns;
		en <= '0';
		WAIT FOR 75ns;
		rst <= '1';
		WAIT FOR 75ns;
		rst <= '0';
		WAIT FOR 25ns;
		en <= '1';
		WAIT;
	END PROCESS;
END Behavioral;