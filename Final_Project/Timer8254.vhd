library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY Timer8254 IS
  GENERIC (size: integer:=16);
  PORT (	
		barcode_in: 	  		 IN std_logic;
		clk:		            IN std_logic;
		DACK:		           IN std_logic;
		rst:              IN std_logic;
		captured_width: 		OUT std_logic_vector(size-1 downto 0);
		DREQ:             OUT std_logic);
end Timer8254;

architecture Timer8254_behavioral of Timer8254 is

signal barcode_in_not:    std_logic;
signal count_out:         std_logic_vector(size-1 downto 0);-- := (others => '0');
signal rising_DFF_out:    std_logic_vector(size-1 downto 0);-- := (others => '0');
signal falling_DFF_out:   std_logic_vector(size-1 downto 0);-- := (others => '0');
signal subtruct_result:   std_logic_vector(size-1 downto 0);-- := (others => '0');

COMPONENT counter
  GENERIC (size: integer:=16);
  PORT (clk:            IN  std_logic;
        rst:            IN  std_logic;
        en:             IN  std_logic;
        count_out:      OUT std_logic_vector(size-1 downto 0)
      );
END COMPONENT;

COMPONENT DFF IS
  GENERIC (size: integer:=16);
  PORT (	
		D: 	  		IN std_logic_vector(size-1 downto 0);
		clk:		  IN std_logic;
		rst:		  IN std_logic;
		Q: 			  OUT std_logic_vector(size-1 downto 0));
end COMPONENT;


begin
  barcode_in_not<= not barcode_in;

  process(rst, DACK, rising_DFF_out) begin
    if (rst = '1') then
      subtruct_result <= (others => '0');
      DREQ <= '0';
    elsif (rising_edge(DACK)) then
      DREQ <= '0';
    elsif (rising_DFF_out'event) then
      subtruct_result <= std_logic_vector(abs(signed(rising_DFF_out) - signed(falling_DFF_out)));
      DREQ <= '1';
    end if;
  end process;
	
	
timer_internal_counter: counter
GENERIC MAP (size=>size)
PORT MAP (en=>'1', 
          clk=>clk,
          rst=>rst,
          count_out=>count_out);

rising_DFF: DFF
GENERIC MAP (size=>size)
PORT MAP (D=>count_out, 
          clk=>barcode_in,
          rst=>rst,
          Q=>rising_DFF_out);

falling_DFF: DFF
GENERIC MAP (size=>size)
PORT MAP (D=>count_out, 
          clk=>barcode_in_not,
          rst=>rst,
          Q=>falling_DFF_out);
          
result_DFF: DFF
GENERIC MAP (size=>size)
PORT MAP (D=>subtruct_result, 
          clk=>clk,
          rst=>rst,
          Q=>captured_width);

end Timer8254_behavioral;