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
			BUS_AD : inout STD_LOGIC_VECTOR(width_bus_AD - 1 DOWNTO 0);
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
clk : in std_logic;
en : in std_logic
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
	SIGNAL BUS_AD:STD_LOGIC_VECTOR(width_bus_AD - 1 DOWNTO 0);

	SIGNAL en_write:std_logic:='0';
signal input_read:  std_logic;
		signal addr_count : INTEGER := 0;

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
		BUS_AD =>BUS_AD,
		barcode_out => barcode_out,
		HOLD => HOLD,
		EOP => EOP
	);

	
WD:writeFile PORT MAP(barcode_out, clk,en_write );

	read_procc: PROCESS
	BEGIN 
	ALE<='0';
	BUS_AD<=(others =>'Z');
	wait until EOP = '1';
	wait for 50ns;
	for I in 0 to 20 loop
		BUS_AD(15 downto 13) <= "100";
		en_write<='0';
		ALE <='1';
		BUS_AD(12 downto 0)<=std_logic_vector(to_unsigned(addr_count, BUS_AD(12 downto 0)'length));
		wait for 50 ns;
		BUS_AD(12 downto 0)<= (others => 'Z');
		addr_count<=addr_count+2;
		ALE <='0';
		en_write<='1';
		wait for 50 ns;
		if(I =20) then
		en_write <='0';
		end if;
	end loop;
	--en_write<='0';
	--ALE <='1';
	--BUS_AD<=x"0002";
	--wait for 50 ns;
	--ALE <='0';
	--en_write<='1';
	--wait for 50 ns;
	--	en_write<='0';
	--	ALE <='1';
	--BUS_AD<=x"0004";
--wait for 50 ns;
	--en_write<='1';

	wait;
	end PROCESS;

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
	
	

END Behavioral;