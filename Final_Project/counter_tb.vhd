library ieee;
use ieee.std_logic_1164.all;
 
entity counter_tb is
end counter_tb;

architecture Behavioral of counter_tb is

component counter 
  GENERIC (size: integer);
  PORT (clk:            IN  std_logic;
        rst:            IN  std_logic;
        en:             IN  std_logic;
        count_out:      OUT std_logic_vector(size-1 downto 0)
      );
end component;

signal size: integer := 16;
signal clk, rst, en: std_logic;
signal count_out:std_logic_vector(size-1 downto 0);

begin
dut: counter generic map (size=>size) port map (clk => clk, rst=>rst, en=>en, count_out => count_out);
   -- Clock process definitions
clock_process :process
begin
     clk <= '0';
     wait for 25 ns;
     clk <= '1';
     wait for 25 ns;
end process;


-- Stimulus process
stim_proc: process
begin        
    en <='0';
   wait for 25 ns; 
     rst <= '1';
   wait for 25 ns;    
    rst <= '0';
   wait for 25ns;
    en <= '1';
    wait for 200ns;
    en <= '0';
    wait for 75ns;
    rst <= '1';
    wait for 75ns;
    rst <= '0';
    wait for 25ns;
    en <= '1';
   wait;
end process;
end Behavioral;