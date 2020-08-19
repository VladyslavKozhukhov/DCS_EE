library ieee;
use ieee.std_logic_1164.all;
 
entity DMA_tb is
end DMA_tb;

architecture Behavioral of DMA_tb is

component DMA IS
  GENERIC (
    size: integer;
    address_size: integer
    );
  PORT (	
		clk:		    IN std_logic;
		rst:      IN std_logic;
		en:       IN std_logic;
		DREQ:		   IN std_logic;
		HOLDA:    IN std_logic;
		HOLD:     OUT std_logic;
		DACK:     OUT std_logic;		
		address:  OUT std_logic_vector(address_size-1 downto 0);
		RW:       OUT std_logic;
		EOP:      OUT std_logic
		);
end component;

signal size: integer := 16;
signal address_size: integer := 7;
signal clk, rst, en, DREQ, HOLDA, HOLD, DACK, RW, EOP: std_logic;
signal address:std_logic_vector(address_size-1 downto 0);

begin
dut: DMA 
generic map (size=>size, address_size=>address_size) 
port map (clk => clk, rst=>rst, en=>en, DREQ=>DREQ, HOLDA=>HOLDA, HOLD=>HOLD, DACK=>DACK, address=>address, RW=>RW, EOP=>EOP);
  
   -- Clock process definitions
clock_process :process
begin
     clk <= '0';
     wait for 25 ns;
     clk <= '1';
     wait for 25 ns;
end process;

gen_HOLDA: process
begin
  wait for 50 ns;
  if (HOLD = '1') then
    HOLDA <= '1';
  else
    HOLDA <= '0';
  end if;
end process;

gen_DREQ: process
begin
  DREQ <= '1';
  wait until HOLDA = '1';
  wait for 50ns;
  DREQ <= '0';
  wait until HOLDA = '0';
  wait for 50ns;
end process;

-- Stimulus process
stim_proc: process
begin        
    rst <= '1';
    en <= '1';
    wait for 100 ns;    
    rst <= '0';
    wait for 500 ns;
    en <= '0';
    wait for 100 ns;
    en <= '1';
   wait;
end process;
end Behavioral;
