-- Testbench for MUX_PLC
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.PLC_Types.all;

entity MUX_PLC_tb is
end MUX_PLC_tb;

architecture sim of MUX_PLC_tb is
    signal Address : std_logic_vector(2 downto 0) := (others => '0');
    signal Data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal Table_ROM : FSM_Table(0 to 7) := (
        0 => x"00000001",
        1 => x"00000002",
        2 => x"00000004",
        3 => x"00000008",
        4 => x"00000010",
        5 => x"00000020",
        6 => x"00000040",
        7 => x"00000080"
    );
    component MUX_PLC is
        generic(
            ADDR_WIDTH : natural := 3;
            DELAY      : time    := 10 ps
        );
        port(
            Address    : in  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
            Data       : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
            Table_ROM  : in  FSM_Table(0 to 2**ADDR_WIDTH-1)
        );
    end component;

begin
    UUT: MUX_PLC port map(Address => Address, Data => Data, Table_ROM => Table_ROM);
    stim_proc: process
    begin
        for i in 0 to 7 loop
            Address <= std_logic_vector(to_unsigned(i, 3));
            wait for 20 ns;
        end loop;
        wait;
    end process;
end sim;
