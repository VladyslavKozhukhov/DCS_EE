library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE iEEE.std_logic_arith.ALL;

entity ale_module is
GENERIC (size: integer:=16);
  PORT (	
		addr_data: 	  		IN std_logic_vector(size-1 downto 0);
		en:		  IN std_logic;
		reset: in std_logic;
		addr_out:		  OUT   std_logic_vector(size-1 downto 0));
end ale_module;

architecture arc_ale_module of ale_module is
SIGNAL addr_out_tmp  : std_logic_vector(size-1 downto 0);

BEGIN
	PROCESS (reset, addr_data,en)
		BEGIN
		IF (reset = '0') THEN
			addr_out_tmp <= (others => '0');
		ELSIF (en = '1') then
			addr_out_tmp <= addr_data;
		ELSE
			addr_out_tmp <= addr_out_tmp;
		END IF;
	end process ;
addr_out <= addr_out_tmp;

end arc_ale_module;
