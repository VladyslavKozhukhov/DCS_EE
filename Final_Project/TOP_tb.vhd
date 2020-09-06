LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY TOP_tb IS
END TOP_tb;

ARCHITECTURE Behavioral OF TOP_tb IS

	COMPONENT TOP IS
		GENERIC (
width_bus_AD : INTEGER;
address_size : INTEGER;
mem_size : INTEGER;
SEL_WIDTH   :NATURAL
		);
		PORT (
			STRSCAN : IN std_logic;
			clk : IN std_logic;
			reset : IN std_logic;
			barcode_in : IN std_logic;
			HOLDA : IN std_logic;
			INT : IN std_logic;
			INTA : IN std_logic;
			ALE : IN std_logic;
			BHE : IN std_logic;
			barcode_out : OUT std_logic_vector(15 DOWNTO 0);
			HOLD : OUT std_logic;
			EOP : OUT std_logic
		);
	END COMPONENT;
component readFile 
	PORT(
	input_top : OUT std_logic
	);
END component;
component writeFile 
	PORT(
input_top : in std_logic_vector(15 DOWNTO 0);
clk : in std_logic
	);
END component;
	SIGNAL width_bus_AD : INTEGER := 16;
	SIGNAL address_size : INTEGER := 13;

SIGNAL mem_size : INTEGER:=8000;
 SIGNAL SEL_WIDTH   :NATURAL := 3;
	SIGNAL  clk,clkWrite, reset, barcode_in, HOLDA, INT, INTA, ALE, BHE, HOLD, EOP : std_logic;
	SIGNAL barcode_out : std_logic_vector(15 DOWNTO 0);
	signal mem_out:std_logic_vector(15 DOWNTO 0);
	SIGNAL STRSCAN:std_logic:='0';
signal input_read:  std_logic;

BEGIN
STRSCAN<='1' when reset = '0' and EOP = '0' else 
			'0';
			
RD:readFile PORT MAP(barcode_in);
			
			
			
			
	dut : TOP
	GENERIC MAP(
		width_bus_AD => width_bus_AD,
		address_size => address_size,
		mem_size=>mem_size,
		SEL_WIDTH=>SEL_WIDTH
	)
	PORT MAP(
		STRSCAN => STRSCAN,
		clk => clk,
		reset => reset,
		barcode_in => barcode_in,
		HOLDA => HOLDA,
		INT => INT,
		INTA => INTA,
		ALE => ALE,
		BHE => BHE,
		barcode_out => barcode_out,
		HOLD => HOLD,
		EOP => EOP
	);

	-- Clock process definitions
	clock_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR 25 ns;
		clk <= '1';
		WAIT FOR 25 ns;
	END PROCESS;
---clock writeFile
	clockWrite_process : PROCESS
	BEGIN
		clkWrite <= '0';
		WAIT FOR 50 ns;
		clkWrite <= '1';
		WAIT FOR 50 ns;
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

	gen_INTA : PROCESS
	BEGIN
		WAIT FOR 50 ns;
		IF (EOP = '1') THEN
			INTA <= '1';
			--STRSCAN <= '0';
		ELSE
			INTA <= '0';
		END IF;
	END PROCESS;

	main_process : PROCESS
	BEGIN
		reset <= '1'; -- reset system
		--STRSCAN <= '0';
		WAIT FOR 75 ns;
		reset <= '0';
		--		STRSCAN <= '1';

		--WAIT FOR 25 ns;
		wait;
	END PROCESS;
	
	write_process: PROCESS
	BEGIN
	mem_out<=barcode_out;
	WAIT FOR 200 ns;
	end PROCESS;
	
WD:writeFile PORT MAP(barcode_out, clk );

END Behavioral;