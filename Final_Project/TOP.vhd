LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;

ENTITY TOP IS
	PORT (
		input_top : IN CHARACTER;
		clk : IN std_logic
	);
END TOP;

ARCHITECTURE arc_TOP OF TOP IS

	COMPONENT writeFile
		PORT (
			input_top : IN CHARACTER;
			clk : IN std_logic
		);
	END COMPONENT;

	COMPONENT readFile
		PORT (
			input_top : OUT std_logic
		);
	END COMPONENT;
	
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
    size: integer:=16;
    address_size: integer:=7
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
	
	
	
	
	
	
	
	
BEGIN




END arc_TOP;