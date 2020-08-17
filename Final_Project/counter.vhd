LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

ENTITY counter IS
  GENERIC (size: integer:=16);
  PORT (clk:            IN  std_logic;
        rst:            IN  std_logic;
        en:             IN  std_logic;
        count_out:      OUT std_logic_vector(size-1 downto 0)
      );
END counter;

architecture counter_arch of counter is 
begin
  process(clk)
    variable count: integer:=0;
    constant maxCount: integer:= (2**size-1);
    begin
      if (rising_edge (clk)) then
        if (rst = '1') then
          count := 0;
        elsif (en = '1') then
          if (count = maxCount) then  -- OVERFLOW
            count := 0;
          else
            count := count+1;
          end if;
        else  -- if disabled
          count := count;
        end if;
      end if;
      count_out <= std_logic_vector(to_unsigned(count, count_out'length));
    end process;
end counter_arch;