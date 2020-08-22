library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity readFile is
PORT(
input_top : OUT std_logic
);
end readFile;

architecture arc_readFile of readFile is
      signal input:           std_logic ;
    signal clk:             std_logic := '0';
    constant clk_period:    time := 10 ns;
begin
	input_top<=input;



read_proc: 
    process
	CONSTANT file_read_loc :string(1 to 45):="C:\Users\VladKo\Documents\MSc\BGU\Scanner.txt";
	file input_file : text open read_mode is file_read_loc;
     --   file input_file: TEXT is in "Scanner.txt";
     variable rdline:    LINE;

    begin       
        while not endfile(input_file) loop
            readline(input_file, rdline);
            for j in rdline'range loop
                if rdline(j) = '1' then 
                    input <= '1';
                else
                    input <= '0'; 
                end if;
                wait until falling_edge(clk);
            end loop;
        end loop;
        wait;  
    end process;

 
CLOCK:
    process
    begin
        wait for clk_period/2;
        clk <= not clk;
    end process;
	
end arc_readFile;
