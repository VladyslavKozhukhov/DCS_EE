LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY DFF_tb IS
END DFF_tb;

ARCHITECTURE Behavioral OF DFF_tb IS

	COMPONENT DFF
		GENERIC (size : INTEGER);
		PORT (
			D : IN std_logic_vector(size - 1 DOWNTO 0);
			clk : IN std_logic;
			rst : IN std_logic;
			Q : OUT std_logic_vector(size - 1 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL size : INTEGER := 16;
	SIGNAL clk, rst : std_logic;
	SIGNAL D, Q : std_logic_vector(size - 1 DOWNTO 0);

BEGIN
	dut : DFF GENERIC MAP(size => size) PORT MAP(D => D, clk => clk, rst => rst, Q => Q);
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
		D <= x"0000";
		rst <= '1';
		WAIT FOR 25 ns;
		rst <= '0';
		WAIT FOR 25ns;
		D <= x"ffff";
		WAIT FOR 200ns;
		D <= x"efef";
		WAIT FOR 75ns;
		rst <= '1';
		WAIT FOR 75ns;
		rst <= '0';
		WAIT FOR 25ns;
		D <= x"fefe";
		WAIT;
	END PROCESS;
END Behavioral;