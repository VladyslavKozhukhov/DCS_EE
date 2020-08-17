library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE iEEE.std_logic_arith.ALL;

ENTITY DFF IS
  GENERIC (size: integer:=16);
  PORT (	
		D: 	  		IN std_logic_vector(size-1 downto 0);
		clk:		  IN std_logic;
		rst:		  IN std_logic;
		Q: 			  OUT std_logic_vector(size-1 downto 0));
end DFF;

architecture dff_behavioral of DFF is

begin
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				q <= (others => '0');
			else 
				q <= d;
			end if;
		end if;
	end process;	
end dff_behavioral;