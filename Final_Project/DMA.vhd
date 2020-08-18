library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY DMA IS
  GENERIC (
    size: integer:=16;
    address_size: integer:=7
    );
  PORT (	
		clk:		    IN std_logic;
		rst:      IN std_logic;
		DREQ:		   IN std_logic;
		HOLDA:    IN std_logic;
		HOLD:     OUT std_logic;
		DACK:     OUT std_logic;		
		address:  OUT std_logic_vector(address_size-1 downto 0);
		RW:       OUT std_logic;
		EOP:      OUT std_logic
		);
end DMA;

architecture DMA_behavioral of DMA is
  
  begin
    process(clk) 
      variable transfers_count: integer:=0;
      constant MAX_DMA_REQUESTS: integer:=99;
      begin
      if (rising_edge(clk)) then
        if (DREQ = '1' and HOLDA = '0') then
          HOLD <= '1';  -- send HOLD to CPU
          DACK <= '0';
          address <= (others => 'Z'); -- disconnect from bus
          RW <= '0';
        elsif (DREQ = '1' and HOLDA = '1') then
          HOLD <= '0';  -- send HOLD to CPU
          DACK <= '1';  -- send DACK to Timer
          address <= (others => '1'); -- TODO: put MEM address
          RW <= '1';
          transfers_count := transfers_count+1;
          -- EOP
          if (transfers_count = MAX_DMA_REQUESTS) then
            transfers_count := 0;
            EOP <= '1';
          else
            EOP <= '0';
          end if;
        else  -- if idle or rst
          HOLD <= '0';
          DACK <= '0';
          address <= (others => 'Z'); -- disconnect from bus
          RW <= '0';
        end if;
      end if;
    end process;
    
end DMA_behavioral;
