 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY interrupt_controller IS
  GENERIC (
    size: integer:=16;
    address_size: integer:=7
    );
  PORT (	
		clk:		    IN std_logic;
		rst:      IN std_logic;
		INTA:       IN std_logic;
		CS5:    IN std_logic;
		IR0:    IN std_logic;
		A0:     IN std_logic;
		INTR:    OUT std_logic

		);
end interrupt_controller;
ARCHITECTURE arc_interrupt_controller OF interrupt_controller IS
component DFF
  GENERIC (size: integer:=16);
  PORT (	
		D: 	  		IN std_logic_vector(size-1 downto 0);
		clk:		  IN std_logic;
		rst:		  IN std_logic;
		Q: 			  BUFFER std_logic_vector(size-1 downto 0));
end component;


signal D_tmp	: std_logic_vector(0 downto 0);
signal Q_tmp	: std_logic_vector(0 downto 0);
BEGIN
dff_inst:DFF GENERIC MAP (size=>1) 
	PORT MAP(
		clk=>clk,
		rst=>rst,
		D=>D_tmp,
		Q=>Q_tmp
		);

D_tmp(0)<=CS5 and IR0;
INTR<=Q_tmp(0);	
	
end arc_interrupt_controller;