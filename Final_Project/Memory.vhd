LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.Numeric_Std.all;

ENTITY ram IS
	GENERIC(
		d_width	:	INTEGER := 16;    --width of each data word
		size		:	INTEGER := 8000);  --number of data words the memory can store
	PORT(
		clk		:	IN		STD_LOGIC;                             --system clock
		wr_ena	:	IN		STD_LOGIC;                             --write enable
		cs5     : IN  STD_LOGIC;
		BHE      : in STD_LOGIC;
		address		:	IN	std_logic_vector(12 downto 0);--	INTEGER RANGE 0 TO size-1;             --address to write/read
		data_in	:	IN		STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --input data to write
		data_out	:	OUT	STD_LOGIC_VECTOR(d_width-1 DOWNTO 0); --output data read
		reset       : IN STD_LOGIC);
END ram;

ARCHITECTURE logic OF ram IS
	TYPE memory IS ARRAY(size-1 DOWNTO 0) OF STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data type for memory
	SIGNAL ram			:	memory;                                                    --memory array
	SIGNAL addr_int	:	INTEGER RANGE 0 TO size-1;                                 --internal address register
	signal enable_odd : std_logic;
	signal enable_even: std_logic;
	signal tmp_data : STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);
BEGIN

	PROCESS(clk,reset)
	BEGIN
	IF(reset = '1') then
			FOR i IN 0 TO 8000 LOOP
				ram(i) <= (others => '0');
			END LOOP;
			data_out<= (others => '0');

		elsif(clk'EVENT AND clk = '1') THEN
			enable_odd<=cs5 and address(0);
			enable_even<=cs5 and BHE;
			IF(wr_ena = '1' and enable_odd ='1' and  enable_even ='1') THEN     --write enable is asserted
				ram(to_integer(unsigned(address))) <= data_in;  --write input data into memory
			elsif(wr_ena = '1' and enable_odd ='1') then -- LO
				tmp_data <= ram(to_integer(unsigned(address)));
				tmp_data<=tmp_data(15 downto 8) & data_in(7 downto 0);
				ram(to_integer(unsigned(address))) <=tmp_data;
			elsif( wr_ena = '1' and enable_even ='1') then  -- HI
				tmp_data <= ram(to_integer(unsigned(address)));
			    tmp_data<=data_in(7 downto 0)&tmp_data(7 downto 0); 
				ram(to_integer(unsigned(address))) <=tmp_data;
			END IF;
			
			addr_int <= (to_integer(unsigned(address)));         --store the address in the internal address register

		END IF;	
	END PROCESS;
	
	data_out <= ram(to_integer(unsigned(address)));      --output data at the stored address
	
END logic;