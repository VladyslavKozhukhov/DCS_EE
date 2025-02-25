LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Timer8254 IS
	GENERIC (d_width : INTEGER := 16);
	PORT (
		barcode_in : IN std_logic;
		clk : IN std_logic;
		en : IN std_logic;
		EOP : IN std_logic;
		DACK_main : IN std_logic;
		DACK_sec : IN std_logic;
		rst : IN std_logic;
		captured_width : OUT std_logic_vector(d_width - 1 DOWNTO 0);
		DREQ : OUT std_logic);
END Timer8254;

ARCHITECTURE Timer8254_behavioral OF Timer8254 IS

	SIGNAL barcode_in_not : std_logic;
	SIGNAL count_out : std_logic_vector(d_width - 1 DOWNTO 0);
	SIGNAL rising_DFF_out : std_logic_vector(d_width - 1 DOWNTO 0);
	SIGNAL falling_DFF_out : std_logic_vector(d_width - 1 DOWNTO 0);
	SIGNAL subtruct_result : std_logic_vector(d_width - 1 DOWNTO 0);
	SIGNAL dff_out : std_logic_vector(d_width - 1 DOWNTO 0);

	---COUNTER-----
	COMPONENT counter
		GENERIC (d_width : INTEGER := 16);
		PORT (
			clk : IN std_logic;
			rst : IN std_logic;
			en : IN std_logic;
			count_out : OUT std_logic_vector(d_width - 1 DOWNTO 0)
		);
	END COMPONENT;
	----------------

	-----DFF---------
	COMPONENT DFF IS
		GENERIC (d_width : INTEGER := 16);
		PORT (
			D : IN std_logic_vector(d_width - 1 DOWNTO 0);
			clk : IN std_logic;
			rst : IN std_logic;
			Q : OUT std_logic_vector(d_width - 1 DOWNTO 0));
	END COMPONENT;
	------------------

BEGIN
	barcode_in_not <= NOT barcode_in;
	PROCESS (EOP, rst, DACK_main, rising_DFF_out, DACK_sec)
	BEGIN
		IF (rst = '1') THEN
			subtruct_result <= (OTHERS => '0');
			DREQ <= '0';
			captured_width <= (OTHERS => 'Z');
		ELSE
			IF (falling_edge(DACK_main) AND en = '1') THEN
				captured_width <= dff_out;
				DREQ <= '0';
			ELSIF (rising_DFF_out'event) THEN
				subtruct_result <= std_logic_vector(ABS(signed(rising_DFF_out) - signed(falling_DFF_out)));
				DREQ <= '1';
				captured_width <= (OTHERS => 'Z');
			ELSE
				subtruct_result <= (OTHERS => '0');
				DREQ <= '0';
				captured_width <= (OTHERS => 'Z');
			END IF;

		END IF;
	END PROCESS;

	timer_internal_counter : counter
	GENERIC MAP(d_width => d_width)
	PORT MAP(
		en => '1',
		clk => clk,
		rst => rst,
		count_out => count_out);
	rising_DFF : DFF
	GENERIC MAP(d_width => d_width)
	PORT MAP(
		D => count_out,
		clk => barcode_in,
		rst => rst,
		Q => rising_DFF_out);
	falling_DFF : DFF
	GENERIC MAP(d_width => d_width)
	PORT MAP(
		D => count_out,
		clk => barcode_in_not,
		rst => rst,
		Q => falling_DFF_out);
	result_DFF : DFF
	GENERIC MAP(d_width => d_width)
	PORT MAP(
		D => subtruct_result,
		clk => clk,
		rst => rst,
		Q => dff_out);

END Timer8254_behavioral;