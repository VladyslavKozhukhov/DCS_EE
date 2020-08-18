library ieee;
use ieee.std_logic_1164.all;
 
entity Timer8254_tb is
end Timer8254_tb;

architecture Behavioral of Timer8254_tb is

component Timer8254
  GENERIC (size: integer);
  PORT (	
		barcode_in: 	  		 IN std_logic;
		clk:		            IN std_logic;
		DACK:		           IN std_logic;
		rst:              IN std_logic;
		captured_width: 		OUT std_logic_vector(size-1 downto 0);
		DREQ:             OUT std_logic);
end component;

signal size: integer := 16;
signal barcode_in, DACK, clk, rst, DREQ: std_logic;
signal captured_width:  std_logic_vector(size-1 downto 0);

begin
dut: Timer8254 
generic map (size=>size) 
port map (barcode_in=>barcode_in, clk => clk, DACK=>DACK, rst=>rst, captured_width=>captured_width, DREQ=>DREQ);
  
-- Clock process definitions
clock_process :process
begin
     clk <= '0';
     wait for 25 ns;
     clk <= '1';
     wait for 25 ns;
end process;

handshake: process begin
  if (DREQ = '1') then
    DACK <= '1';
  else
    DACK <= '0';
  end if;
  wait for 100 ns;
end process;


-- Stimulus process
stim_proc: process
begin   
    barcode_in <= '1';     
    rst <= '1';
   wait for 100 ns;    
    rst <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '0';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';
wait for 200ns;
barcode_in <= '1';



   wait;
end process;
end Behavioral;

