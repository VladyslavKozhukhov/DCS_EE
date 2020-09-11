LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.Numeric_Std.ALL;

ENTITY Memory_interleaving IS
	GENERIC (
		d_width : INTEGER := 16; --width of each data word
	    address_size : INTEGER := 13; --addr size
		size : INTEGER := 8000); --number of data words the memory can store
	PORT (
		clk : IN STD_LOGIC; --system clock
		wr_ena : IN STD_LOGIC; --write enable
		en : IN STD_LOGIC;
		BHE : IN STD_LOGIC;
		address : IN std_logic_vector(address_size - 1 DOWNTO 0);--	INTEGER RANGE 0 TO size-1;             --address to write/read
		data_in : IN STD_LOGIC_VECTOR(d_width - 1 DOWNTO 0); --input data to write
		data_out : OUT STD_LOGIC_VECTOR(d_width - 1 DOWNTO 0); --output data read
		reset : IN STD_LOGIC);
END Memory_interleaving;

ARCHITECTURE ram_logic OF Memory_interleaving IS
	TYPE memory IS ARRAY(size*2 - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(d_width/2 - 1 DOWNTO 0); -- 8000*8
	--SIGNAL ram_even : memory;
	--SIGNAL ram_odd : memory;
	SIGNAL ram : memory;
	SIGNAL addr_int : INTEGER RANGE 0 TO size - 1; --internal address register
	SIGNAL enable_odd : std_logic;
	SIGNAL enable_even : std_logic;

BEGIN

	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
			ram <= (OTHERS => (OTHERS => '0'));
			--ram_odd <= (OTHERS => (OTHERS => '0'));
			data_out <= (OTHERS => 'Z');

		ELSIF (rising_edge(clk)) THEN
			IF (wr_ena = '1') THEN	--write
				data_out <= (OTHERS => 'Z');
				IF (BHE = '0' and address(0) = '0') THEN	-- Write whole word
					ram(to_integer(unsigned(address))) <= data_in(d_width/2 - 1 DOWNTO 0);
					ram(to_integer(unsigned(address))+1) <= data_in(d_width-1 DOWNTO d_width/2);
				ELSIF (BHE = '0' and address(0) = '1') THEN	--  Upper byte to odd address
					ram(to_integer(unsigned(address))+1) <= data_in(d_width-1 DOWNTO d_width/2);
				ELSIF (BHE = '1' and address(0) = '0') THEN	-- Lower byte to even address
					ram(to_integer(unsigned(address))) <= data_in(d_width/2 - 1 DOWNTO 0);
				--ELSE -- (BHE = '1' and address(0) = '1')	-- None
					
				END IF;
			ELSif (en = '1') then	-- read
				IF (BHE = '0' and address(0) = '0') THEN	-- Read whole word
					data_out <= ram(to_integer(unsigned(address))+1) & ram(to_integer(unsigned(address)));
				ELSIF (BHE = '0' and address(0) = '1') THEN	--  Upper byte from odd address
					data_out <= ram(to_integer(unsigned(address))+1) & (d_width/2 - 1 DOWNTO 0 => '0');
				ELSIF (BHE = '1' and address(0) = '0') THEN	-- Lower byte from even address
					data_out <= (d_width/2 - 1 DOWNTO 0 => '0') & ram(to_integer(unsigned(address)));
				ELSE -- (BHE = '1' and address(0) = '1')	-- None
					data_out <= (OTHERS => 'Z');
				END IF;
			END IF;
		END IF;
	END PROCESS;

END ram_logic;