library ieee;
use ieee.std_logic_1164.all;
 
entity DFF_tb is
end DFF_tb;

architecture Behavioral of DFF_tb is

component DFF 
  GENERIC (size: integer);
  PORT (D:    IN  std_logic_vector(size-1 downto 0);
        clk:  IN  std_logic;
        rst:  IN  std_logic;
        Q:    OUT std_logic_vector(size-1 downto 0)
      );
end component;

signal size: integer := 16;
signal clk, rst: std_logic;
signal D, Q:std_logic_vector(size-1 downto 0);

begin
dut: DFF generic map (size=>size) port map (D=>D, clk => clk, rst=>rst, Q=>Q);
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
    D <= x"0000";     
    rst <= '1';
   wait for 25 ns;    
    rst <= '0';
   wait for 25ns;
    D <= x"ffff";
    wait for 200ns;
    D <= x"efef";
    wait for 75ns;
    rst <= '1';
    wait for 75ns;
    rst <= '0';
    wait for 25ns;
    D <= x"fefe";
   wait;
end process;
end Behavioral;
