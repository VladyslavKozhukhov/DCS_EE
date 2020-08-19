LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Decoder IS 
	GENERIC (
		SEL_WIDTH: NATURAL := 3
	);
	PORT (
		sel:		IN std_logic_vector(SEL_WIDTH-1 DOWNTO 0);
		decoder_out: 	OUT std_logic_vector(2**SEL_WIDTH-1 DOWNTO 0)
	);
END Decoder;


ARCHITECTURE Decoder_arch OF Decoder IS

begin 
	process(sel)
	begin
		decoder_out <= (others => '0');
		decoder_out(to_integer(unsigned(sel))) <= '1';
	end process;

end Decoder_arch;