LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;
use ieee.numeric_std.all;

ENTITY TOP IS
	GENERIC (
		width_bus_AD : INTEGER := 16;
		address_size : INTEGER := 13;
		mem_size : INTEGER := 8000;
		SEL_WIDTH : NATURAL := 3
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
		BUS_AD : inout STD_LOGIC_VECTOR(width_bus_AD - 1 DOWNTO 0);
		barcode_out : OUT std_logic_vector(15 DOWNTO 0);
		HOLD : OUT std_logic;
		EOP : OUT std_logic
	);
END TOP;

ARCHITECTURE arc_TOP OF TOP IS

	--COMPONENT writeFile
	--	PORT (
	--		input_top : IN CHARACTER;
	--		clk : IN std_logic
	--	);
	--END COMPONENT;

	--COMPONENT readFile
	--	PORT (
	--		input_top : OUT std_logic
	--	);
	--END COMPONENT;

	COMPONENT ram
		GENERIC (
			d_width : INTEGER := 16; --width of each data word
			size : INTEGER := 8000); --number of data words the memory can store
		PORT (
			clk : IN STD_LOGIC; --system clock
			wr_ena : IN STD_LOGIC; --write enable
			cs5 : IN STD_LOGIC;
			BHE : IN STD_LOGIC;
			address : IN std_logic_vector(12 DOWNTO 0);-- INTEGER RANGE 0 TO size-1; --address to write/read
			data_in : IN STD_LOGIC_VECTOR(d_width - 1 DOWNTO 0); --input data to write
			data_out : OUT STD_LOGIC_VECTOR(d_width - 1 DOWNTO 0);
			reset : IN STD_LOGIC);
		--output data read
	END COMPONENT;
	COMPONENT Decoder
		GENERIC (
			SEL_WIDTH : NATURAL := 3
		);
		PORT (
			sel : IN std_logic_vector(SEL_WIDTH - 1 DOWNTO 0);
			decoder_out : OUT std_logic_vector(2 ** SEL_WIDTH - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT DMA
		GENERIC (
			size : INTEGER := 16;
			address_size : INTEGER := 7
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
			address : OUT std_logic_vector(size - 1 DOWNTO 0);
			RW : OUT std_logic;
			ALE : OUT std_logic;
			EOP : OUT std_logic
		);
	END COMPONENT;

	COMPONENT Timer8254
		GENERIC (size : INTEGER := 16);
		PORT (
			barcode_in : IN std_logic;
			clk : IN std_logic;
			en : IN std_logic;
			EOP : IN std_logic;
			DACK_main : IN std_logic;
			DACK_sec : IN std_logic;
			rst : IN std_logic;
			captured_width : OUT std_logic_vector(size - 1 DOWNTO 0);
			DREQ : OUT std_logic
		);
	END COMPONENT;
	COMPONENT interrupt_controller
		GENERIC (
			size : INTEGER := 16
		);
		PORT (
			clk : IN std_logic;
			rst : IN std_logic;
			INTA : IN std_logic;
			CS5 : IN std_logic;
			IR0 : IN std_logic;
			A0 : IN std_logic;
			INTR : OUT std_logic

		);
	END COMPONENT;
	
	
	
	COMPONENT Memory_interleaving 
	GENERIC (
		d_width : INTEGER := 16; --width of each data word
		add_width : INTEGER := 13;
		size : INTEGER := 8000); --number of data words the memory can store
	PORT (
		clk : IN STD_LOGIC; --system clock
		wr_ena : IN STD_LOGIC; --write enable
		cs5 : IN STD_LOGIC;
		BHE : IN STD_LOGIC;
		address : IN std_logic_vector(add_width - 1 DOWNTO 0);--	INTEGER RANGE 0 TO size-1;             --address to write/read
		data_in : IN STD_LOGIC_VECTOR(d_width - 1 DOWNTO 0); --input data to write
		data_out : OUT STD_LOGIC_VECTOR(d_width - 1 DOWNTO 0); --output data read
		reset : IN STD_LOGIC);
END COMPONENT;
	
	
	
	COMPONENT ale_module
		GENERIC (size : INTEGER := 16);
		PORT (
			addr_data : IN std_logic_vector(size - 1 DOWNTO 0);
			en : IN std_logic;
			en_main : IN std_logic;
			reset : IN std_logic;
			addr_out : OUT std_logic_vector(size - 1 DOWNTO 0));
	END COMPONENT;
	---------------------------------------------------------------------------------------------
	--SIGNAL BUS_AD : STD_LOGIC_VECTOR(width_bus_AD - 1 DOWNTO 0);
	--SIGNAL BUS_AD_tmp : STD_LOGIC_VECTOR(width_bus_AD - 1 DOWNTO 0);
	SIGNAL ALE_out : STD_LOGIC_VECTOR(width_bus_AD - 1 DOWNTO 0);
	SIGNAL decoder_out : STD_LOGIC_VECTOR(2 ** SEL_WIDTH - 1 DOWNTO 0);
	SIGNAL DACK0 : std_logic;
	SIGNAL DACK1 : std_logic;
	SIGNAL DREQ0 : std_logic;
	SIGNAL DREQ1 : std_logic;
	SIGNAL ALE_Dma : std_logic;
	SIGNAL ALE_IN : std_logic;
	SIGNAL cs1 : std_logic;
	SIGNAL cs2 : std_logic;
	SIGNAL cs3 : std_logic;
	SIGNAL cs4 : std_logic;
	SIGNAL cs5 : std_logic;
	SIGNAL RW : std_logic;
	SIGNAL EOP_tmp : std_logic;
	SIGNAL barcode_in_tmp : std_logic;
	SIGNAL barcode_in_not_tmp : std_logic;
	SIGNAL Mem_out : STD_LOGIC_VECTOR(width_bus_AD - 1 DOWNTO 0);
	signal delay : integer :=0;
BEGIN

--BUS_AD<=  BUS_AD_MEM when   else
	--	  BUS_AD_ADDR when   else
		--  BUS_AD_TIMER when  else
		 -- OTHERS => '0';
ALE_IN<=ALE_Dma or ALE;
	---	ALE_Dma;
		  
	cs1 <= decoder_out(0);
	cs2 <= decoder_out(1);
	cs3 <= decoder_out(2);
	cs4 <= decoder_out(3);
	cs5 <= decoder_out(4);
	barcode_in_tmp <= '1' WHEN barcode_in = '1' ELSE '0';
	barcode_in_not_tmp <= '0' WHEN barcode_in = '1' ELSE '1';
	barcode_out <= Mem_out;

	--PROCESS (clk )
--	BEGIN
--		IF (ALE ='1' ) THEN
		--	iF(delay=7) then
				--BUS_AD<=x"0002";
		--		ALE_Dma<='1';
		--		wait for 25ns;
----wait;
			--	delay <= 0;
			--else
				--delay <=delay +1;
			--end if;
		--ELSE
			--barcode_out <= (OTHERS => 'Z');
	--	END IF;
	--END PROCESS;
	White : Timer8254
	GENERIC MAP(size => width_bus_AD)
	PORT MAP(
		barcode_in => barcode_in_tmp,
		clk => clk,
		en => cs1,
		EOP => EOP_tmp,
		DACK_main => DACK0,
		DACK_sec => DACK1,
		rst => reset,
		captured_width => BUS_AD,
		DREQ => DREQ0
	);

	Black : Timer8254
	GENERIC MAP(size => width_bus_AD)
	PORT MAP(
		barcode_in => barcode_in_not_tmp,
		clk => clk,
		en => cs2,
		EOP => EOP_tmp,
		DACK_main => DACK1,
		DACK_sec => DACK0,
		rst => reset,
		captured_width => BUS_AD,
		DREQ => DREQ1
	);

	DMA_isnt : DMA
	GENERIC MAP(
		size => width_bus_AD,
		address_size => address_size
	)
	PORT MAP(
		clk => clk,
		rst => reset,
		en => '1', --Cs3,
		DREQ0 => DREQ0,
		DREQ1 => DREQ1,
		DACK0 => DACK0,
		DACK1 => DACK1,
		HOLDA => HOLDA,
		HOLD => HOLD,
		address => BUS_AD(15 DOWNTO 0),
		RW => RW,
		ALE => ALE_Dma,
		EOP => EOP_tmp
	);
	Dec : Decoder
	GENERIC MAP(
		SEL_WIDTH => SEL_WIDTH
	)
	PORT MAP(
		sel => BUS_AD(15 DOWNTO 13),
		decoder_out => decoder_out
	);
	IC : interrupt_controller
	GENERIC MAP(
		size => width_bus_AD
	)
	PORT MAP(
		clk => clk,
		rst => reset,
		INTA => INTA,
		CS5 => '1', --cs5,
		IR0 => EOP_tmp,
		A0 => '0',
		INTR => EOP
	);
	
	
	
	
	
	
	Dmem : Memory_interleaving
	GENERIC MAP (
		d_width  => 16, --width of each data word
		add_width =>13,
		size => 8000) --number of data words the memory can store
	PORT MAP(
		clk => clk,
		wr_ena =>RW,
		cs5 =>cs5,
		BHE =>'1',
		address => ALE_out(12 DOWNTO 0), --	INTEGER RANGE 0 TO size-1;             --address to write/read
		data_in => BUS_AD, --input data to write
		data_out =>Mem_out, --output data read
		reset => reset );

		

	ALE_MD : ale_module
	GENERIC MAP(size => width_bus_AD)
	PORT MAP(
		addr_data => BUS_AD,
		en => ALE_Dma, --ALE_Dma??,
		en_main=> ALE,
		reset => reset,
		addr_out => ALE_out);
END arc_TOP;