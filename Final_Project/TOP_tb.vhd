LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.Numeric_Std.ALL;

ENTITY TOP_tb IS
END TOP_tb;

ARCHITECTURE Behavioral OF TOP_tb IS

	COMPONENT TOP IS
		GENERIC (
			width_bus_AD : INTEGER;
			address_size : INTEGER;
			mem_size : INTEGER;
			d_width : INTEGER;
			SEL_WIDTH : NATURAL
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
			BUS_AD : INOUT STD_LOGIC_VECTOR(width_bus_AD - 1 DOWNTO 0);
			BHE : IN std_logic;
			barcode_out : OUT std_logic_vector(d_width-1 DOWNTO 0);
			HOLD : OUT std_logic;
			EOP : OUT std_logic
		);
	END COMPONENT;
	COMPONENT readFile
		PORT (
			input_top : OUT std_logic
		);
	END COMPONENT;
	COMPONENT writeFile
	GENERIC(d_width:INTEGER);
		PORT (
			input_top : IN std_logic_vector(d_width-1 DOWNTO 0);
			clk : IN std_logic;
			en : IN std_logic
		);
	END COMPONENT;
	SIGNAL width_bus_AD : INTEGER := 20;
	SIGNAL address_size : INTEGER := 13;
	SIGNAL d_width : INTEGER := 16;
	SIGNAL mem_size : INTEGER := 8000;
	SIGNAL SEL_WIDTH : NATURAL := 3;
	SIGNAL en_file_write : std_logic := '0';
	SIGNAL addr_count : INTEGER := 2;
	
	SIGNAL clk, clkWrite, reset, barcode_in, HOLDA, INT, INTA, ALE, BHE, HOLD, EOP : std_logic;
	SIGNAL barcode_out : std_logic_vector(15 DOWNTO 0);
	SIGNAL STRSCAN : std_logic := '0';
	SIGNAL BUS_AD : STD_LOGIC_VECTOR(width_bus_AD - 1 DOWNTO 0);



BEGIN
	STRSCAN <= '1' WHEN reset = '0' AND EOP = '0' ELSE
	           '0';
 
	RD : readFile PORT MAP(barcode_in);
 
 
 
 
	dut : TOP
		GENERIC MAP(
		width_bus_AD => width_bus_AD, 
		address_size => address_size, 
		mem_size => mem_size, 
		d_width => d_width, 
		SEL_WIDTH => SEL_WIDTH
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
			BUS_AD => BUS_AD, 
			barcode_out => barcode_out, 
			HOLD => HOLD, 
			EOP => EOP
		);

 
	WD : writeFile GENERIC MAP(d_width=>d_width)	PORT MAP(barcode_out, clk, en_file_write);

	read_form_mem_procc : PROCESS
	variable num_Iteration : INTEGER:= 108; -------#iter
	BEGIN
		ALE <= '0';
		BUS_AD <= (OTHERS => 'Z');
		WAIT UNTIL EOP = '1';
		WAIT FOR 50ns;

		FOR I IN 0 TO num_Iteration LOOP
		
			BUS_AD(width_bus_AD - 1 DOWNTO width_bus_AD - SEL_WIDTH) <= "100";--mem
			en_file_write <= '0';
			ALE <= '1';
			BUS_AD(address_size-1 DOWNTO 0) <= std_logic_vector(to_unsigned(addr_count, BUS_AD(address_size-1 DOWNTO 0)'length));
			
			WAIT FOR 50 ns;
			
			BUS_AD(address_size-1 DOWNTO 0) <= (OTHERS => 'Z');
			addr_count <= addr_count + 2;
			ALE <= '0';
			en_file_write <= '1';
				
			WAIT FOR 50 ns;
						
		END LOOP;
		en_file_write <= '0';
		WAIT;
	END PROCESS;

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
		ELSE
			INTA <= '0';
		END IF;
	END PROCESS;

	main_process : PROCESS
	BEGIN
		reset <= '1'; -- reset system
		WAIT FOR 75 ns;
		BHE <= '1';
		reset <= '0';
		WAIT;
	END PROCESS;
 
 

END Behavioral;