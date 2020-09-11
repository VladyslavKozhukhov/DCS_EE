library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE iEEE.std_logic_arith.ALL;

ENTITY DFF IS
  GENERIC (d_width: integer:=16);
  PORT (	
		D: 	  		IN std_logic_vector(d_width-1 downto 0);
		clk:		  IN std_logic;
		rst:		  IN std_logic;
		Q: 			  BUFFER std_logic_vector(d_width-1 downto 0));
end DFF;

architecture dff_behavioral of DFF is

begin
	process(clk, rst)
	begin
	  if (rst = '1') then  -- async reset
      Q <= (others => '0');
    else
		  if (rising_edge(clk)) then
			 Q <= D;
			 else
			   Q <= Q;
		  end if;
		end if;
	end process;	
end dff_behavioral;