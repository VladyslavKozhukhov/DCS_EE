LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;

ENTITY TOP IS
GENERIC(
width_bus_AD : INTEGER:=16;
address_size : INTEGER:=13
);
	PORT (
		STRSCAN : IN std_logic;
		clk : IN std_logic;
		reset: in std_logic;
		barcode_in: in std_logic;
		HLDA: in std_logic;
		INT : in std_logic;
		INTA : in std_logic;
		ALE : in std_logic;
		BHE  : in std_logic;
		barcode_out: out std_logic_vector(15 downto 0);
		HOLD : out std_logic;
		EOP : out std_logic
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
		data_out : OUT STD_LOGIC_VECTOR(d_width - 1 DOWNTO 0)); --output data read
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
			DREQ : IN std_logic;
			HOLDA : IN std_logic;
			HOLD : OUT std_logic;
			DACK : OUT std_logic; 
			address : OUT std_logic_vector(address_size - 1 DOWNTO 0);
			RW : OUT std_logic;
			EOP : OUT std_logic
		);
	END COMPONENT;

	COMPONENT Timer8254
		GENERIC (size : INTEGER := 16);
		PORT (
			barcode_in : IN std_logic;
			clk : IN std_logic;
			en : IN std_logic;
			DACK : IN std_logic;
			rst : IN std_logic;
			captured_width : OUT std_logic_vector(size - 1 DOWNTO 0);
			DREQ : OUT std_logic
		);
	END COMPONENT; 
	
	
	COMPONENT interrupt_controller 
  GENERIC (
    size: integer:=16
    );
  PORT (	
		clk:		    IN std_logic;
		rst:      IN std_logic;
		INTA:       IN std_logic;
		CS5:    IN std_logic;
		IR0:    IN std_logic;
		A0:     IN std_logic;
		INTR:    OUT std_logic

		);
	end COMPONENT;
	---------------------------------------------------------------------------------------------
	SIGNAL BUS_AD : STD_LOGIC_VECTOR(width_bus_AD-1 DOWNTO 0);
	SIGNAL BUS_Control : STD_LOGIC_VECTOR(width_bus_AD-1 DOWNTO 0);
	SIGNAL DACK0 : std_logic;
	SIGNAL DACK1 : std_logic;
	SIGNAL DREQ0 : std_logic;
	SIGNAL DREQ1 : std_logic;
	SIGNAL cs1 : std_logic;
	SIGNAL cs2 : std_logic;
	SIGNAL cs3 : std_logic;
	SIGNAL cs4 : std_logic;
	SIGNAL cs5 : std_logic;

	
	
	
	
	
	
BEGIN



White: Timer8254
		GENERIC MAP (size => width_bus_AD);
		PORT MAP(
			barcode_in =>barcode_in,
			clk=>clk,
			en => CS1,
			DACK =>DACK0,
			rst=>reset,
			captured_width =>BUS_AD,
			DREQ =>DREQ0
		);

Black: Timer8254
		GENERIC MAP (size => width_bus_AD);
		PORT MAP(
			barcode_in =>not barcode_in,
			clk=>clk,
			en => CS2,
			DACK =>DACK1,
			rst=>reset,
			captured_width =>BUS_AD,
			DREQ =>DREQ1
		);
		
		

DMA_isnt: DMA
		GENERIC MAP(
			size =>width_bus_AD;
			address_size =>address_size
		);
		PORT MAP (
			clk =>clk,
			rst =>reset,
			en =>Cs3,
			DREQ0 =>DREQ0,
			DREQ1 =>DREQ1,
			HOLDA : IN std_logic;
			HOLD : OUT std_logic;
			DACK : OUT std_logic; 
			address : OUT std_logic_vector(address_size - 1 DOWNTO 0);
			RW : OUT std_logic;
			EOP : OUT std_logic
		);
	
		

END arc_TOP;