LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;

ENTITY TOP IS
GENERIC(
width_bus_AD : INTEGER:=16;
address_size : INTEGER:=13;
mem_size : INTEGER:=8000;
SEL_WIDTH   :NATURAL := 3
);
	PORT (
		STRSCAN : IN std_logic;
		clk : IN std_logic;
		reset: in std_logic;
		barcode_in: in std_logic;
		HOLDA: in std_logic;
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
		data_out : OUT STD_LOGIC_VECTOR(d_width - 1 DOWNTO 0);
		reset       : IN STD_LOGIC);
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
		address : OUT std_logic_vector(address_size - 1 DOWNTO 0);
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
	
	
	
	
COMPONENT ale_module
GENERIC (size: integer:=16);
  PORT (	
		addr_data: 	  		IN std_logic_vector(size-1 downto 0);
		en:		  IN std_logic;
		reset: in std_logic;
		addr_out:		  OUT   std_logic_vector(size-1 downto 0));
end COMPONENT;
	---------------------------------------------------------------------------------------------
	SIGNAL BUS_AD : STD_LOGIC_VECTOR(width_bus_AD-1 DOWNTO 0);
	SIGNAL BUS_Control : STD_LOGIC_VECTOR(width_bus_AD-1 DOWNTO 0);
	SIGNAL ALE_out : STD_LOGIC_VECTOR(width_bus_AD-1 DOWNTO 0);
	SIGNAL decoder_out : STD_LOGIC_VECTOR(2**SEL_WIDTH-1 DOWNTO 0);
	SIGNAL DACK0 : std_logic;
	SIGNAL DACK1 : std_logic;
	SIGNAL DREQ0 : std_logic;
	SIGNAL DREQ1 : std_logic;
	SIGNAL ALE_Dma : std_logic;
	SIGNAL cs1 : std_logic;
	SIGNAL cs2 : std_logic;
	SIGNAL cs3 : std_logic;
	SIGNAL cs4 : std_logic;
	SIGNAL cs5 : std_logic;
	SIGNAL RW : std_logic;
	SIGNAL EOP_tmp: std_logic;
	SIGNAL barcode_in_tmp: std_logic;
	SIGNAL barcode_in_not_tmp: std_logic;
	signal Mem_out:STD_LOGIC_VECTOR(width_bus_AD-1 DOWNTO 0);
	

BEGIN
	
	cs1<=decoder_out(0);
	cs2<=decoder_out(1);
	cs3<=decoder_out(2);
	cs4<=decoder_out(3);
	cs5<=decoder_out(4);
	barcode_in_tmp<='1' When barcode_in='1' else '0';
	barcode_in_not_tmp<= '0' when barcode_in ='1' else '1';
	
	process(clk)
	begin
		if (rising_edge(clk) and STRSCAN ='1') then
			barcode_out<=Mem_out;
		else
			barcode_out <= (others => 'Z');
		end if;
	end process;


White: Timer8254
		GENERIC MAP (size => width_bus_AD)
		PORT MAP(
			barcode_in =>barcode_in_tmp,
			clk=>clk,
			en => CS1,
			DACK =>DACK0,
			rst=>reset,
			captured_width =>BUS_AD,
			DREQ =>DREQ0
		);

Black: Timer8254
		GENERIC MAP (size => width_bus_AD)
		PORT MAP(
			barcode_in =>barcode_in_not_tmp,
			clk=>clk,
			en => CS2,
			DACK =>DACK1,
			rst=>reset,
			captured_width =>BUS_AD,
			DREQ =>DREQ1
		);
		
		

DMA_isnt: DMA
		GENERIC MAP(
			size =>width_bus_AD,
			address_size =>address_size
		)
		PORT MAP (
			clk =>clk,
			rst =>reset,
			en =>Cs3,
			DREQ0 =>DREQ0,
			DREQ1 =>DREQ1,
			DACK0=>DACK0,
			DACK1=>DACK1,
			HOLDA =>HOLDA,
			HOLD =>HOLD,
			address =>BUS_AD(12 downto 0),
			RW =>RW,
			ALE=>ALE_Dma,
			EOP =>EOP_tmp
		);
Dec: Decoder
		GENERIC MAP(
			SEL_WIDTH =>SEL_WIDTH
		)
		PORT MAP (
			sel=>ALE_out(15 downto 13),
			decoder_out =>decoder_out
		);
IC: interrupt_controller 
  GENERIC MAP(
    size =>width_bus_AD
    )
  PORT MAP(	
		clk=>clk,
		rst=>reset,
		INTA=>INTA,
		CS5=>cs5,
		IR0=>EOP_tmp,
		A0=>'0',
		INTR=>EOP
		);		      
Dmem: ram
		GENERIC MAp(
			d_width =>width_bus_AD,--width of each data word
		size=>mem_size --number of data words the memory can store
		)
		PORT MAp(
			clk =>clk,
			wr_ena =>RW,
			cs5 =>cs5,
			BHE =>BHE,
			address =>BUS_AD(12 downto 0),-- INTEGER RANGE 0 TO size-1; --address to write/read
			data_in =>BUS_AD,--input data to write
		data_out => Mem_out,
				reset =>reset); --output data read
 
ALE_MD:ale_module
GENERIC map(size=>width_bus_AD)
  PORT map(	
		addr_data=>BUS_AD,
		en=>ALE_Dma,--ALE??,
		reset=>reset,
		addr_out=>ALE_out);
 

END arc_TOP;