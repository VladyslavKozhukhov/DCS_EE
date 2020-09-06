
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
-------------------------------------------------------------
ENTITY tb_write IS
END tb_write;
------------- complete the top Architecture code --------------
ARCHITECTURE arc_tb_write OF tb_write IS
component writeFile 
	PORT(
input_top : in character;
clk : in std_logic
	);
END component;
signal input_read: character := 'y'; 
 signal clk:             std_logic ;

BEGIN
WD:writeFile PORT MAP(input_read, clk );

clock_process :process
begin
     clk <= '0';
     wait for 100 ns;
     clk <= '1';
     wait for 100 ns;
end process;


end arc_tb_write;