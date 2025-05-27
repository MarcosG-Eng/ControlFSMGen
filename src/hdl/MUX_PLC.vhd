----------------------------------------------------------------------------------
-- File: MUX_PLC.vhd
-- Purpose: Generic multiplexer for FSM tables
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.PLC_Types.all;

entity MUX_PLC is
    generic(
        ADDR_WIDTH : natural := 3;
        DELAY      : time    := 10 ps
    );
    port(
        Address    : in  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
        Data       : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        Table_ROM  : in  FSM_Table(0 to 2**ADDR_WIDTH-1)
    );
end MUX_PLC;

architecture Behavioral of MUX_PLC is
begin
    Data <= transport Table_ROM(to_integer(unsigned(Address))) after DELAY;
end Behavioral;
