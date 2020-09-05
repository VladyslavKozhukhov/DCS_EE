LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Memory_interleaving_tb IS
END Memory_interleaving_tb;

ARCHITECTURE Behavioral OF Memory_interleaving_tb IS

	COMPONENT Memory_interleaving IS
		GENERIC (
			d_width : INTEGER ; --width of each data word
			add_width : INTEGER;
			size : INTEGER ); --number of data words the memory can store
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


	SIGNAL d_width : INTEGER := 16;
	SIGNAL add_width : INTEGER := 13;
	SIGNAL size : INTEGER := 8000;
	SIGNAL clk, wr_ena, cs5, BHE, reset : std_logic;
	SIGNAL address : std_logic_vector(add_width - 1 DOWNTO 0);
	SIGNAL data_in : std_logic_vector(d_width - 1 DOWNTO 0);
	SIGNAL data_out : std_logic_vector(d_width - 1 DOWNTO 0);
	

BEGIN
	dut : Memory_interleaving
		GENERIC MAP(size => size, add_width => add_width, d_width => d_width)
	PORT MAP(
		clk => clk,
		wr_ena => wr_ena,
		cs5 => cs5,
		BHE => BHE,
		address => address,
		data_in => data_in,
		data_out => data_out,
		reset => reset
		);
 
	-- Clock process definitions
	clock_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR 25 ns;
		clk <= '1';
		WAIT FOR 25 ns;
	END PROCESS;

	gen_add : PROCESS
	variable count: integer:=0;
	BEGIN
		WAIT FOR 50 ns;
		address <= std_logic_vector(to_unsigned(count, address'length));
		count := count + 1;
	END PROCESS;

	gen_data_in : PROCESS
	variable data: integer:=1;
	BEGIN
		WAIT FOR 50 ns;
		data_in <= std_logic_vector(to_unsigned(data, data_in'length));
		data := data * 2;
	END PROCESS;

	gen_BHE : PROCESS
	BEGIN
		BHE <= '0';
		WAIT FOR 50 ns;
		BHE <= '1';
		WAIT FOR 50 ns;
	END PROCESS;

	-- Stimulus process
	stim_proc : PROCESS
	BEGIN
		reset <= '1';
		cs5 <= '1';
		WAIT FOR 75 ns; 
		reset <= '0';
		WAIT FOR 25 ns; 
		WAIT;
	END PROCESS;
END Behavioral;