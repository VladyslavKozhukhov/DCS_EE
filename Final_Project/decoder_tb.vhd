library ieee;
use ieee.std_logic_1164.all;
 
entity Decoder_tb is
end Decoder_tb;

architecture Behavioral of Decoder_tb is

component Decoder 
	GENERIC (
		SEL_WIDTH: NATURAL
	);
	PORT (
		sel:		IN std_logic_vector(SEL_WIDTH-1 DOWNTO 0);
		decoder_out: 	OUT std_logic_vector(2**SEL_WIDTH-1 DOWNTO 0)
	);
END component;

signal SEL_WIDTH: integer := 3;
signal sel: std_logic_vector(SEL_WIDTH-1 DOWNTO 0);
signal decoder_out: std_logic_vector(2**SEL_WIDTH-1 DOWNTO 0);

begin
dut: Decoder 
generic map (SEL_WIDTH=>SEL_WIDTH) 
port map (sel=>sel, decoder_out=>decoder_out);  


-- Stimulus process
stim_proc: process
begin   
    sel <= "000";     
   wait for 50 ns;    
    sel <= "001";     
   wait for 50 ns;  
    sel <= "010";     
   wait for 50 ns;    
    sel <= "011";     
   wait for 50 ns;  
    sel <= "100";     
   wait for 50 ns;    
    sel <= "101";     
   wait for 50 ns;
    sel <= "110";     
   wait for 50 ns;    
    sel <= "111";     
  wait for 50 ns;    
    sel <= "000";     
   wait;
end process;
end Behavioral;

