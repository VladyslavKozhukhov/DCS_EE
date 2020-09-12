LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY interrupt_controller IS
	PORT (
		clk : IN std_logic;
		rst : IN std_logic;
		INTA : IN std_logic;
		en : IN std_logic;
		IR0 : IN std_logic;
		A0 : IN std_logic;
		INTR : OUT std_logic;
		reset : IN std_logic
	);
END interrupt_controller;
ARCHITECTURE arc_interrupt_controller OF interrupt_controller IS
	COMPONENT DFF
		GENERIC (d_width : INTEGER := 16);
		PORT (
			D : IN std_logic_vector(d_width - 1 DOWNTO 0);
			clk : IN std_logic;
			rst : IN std_logic;
			Q : BUFFER std_logic_vector(d_width - 1 DOWNTO 0));
	END COMPONENT;
	SIGNAL D_tmp : std_logic_vector(0 DOWNTO 0);
	SIGNAL Q_tmp : std_logic_vector(0 DOWNTO 0);
BEGIN

	dff_inst : DFF GENERIC MAP(d_width => 1)
	PORT MAP(
		clk => clk,
		rst => rst,
		D => D_tmp,
		Q => Q_tmp
	);

	D_tmp(0) <= en AND IR0;
	INTR <= Q_tmp(0) AND (NOT reset);

END arc_interrupt_controller;