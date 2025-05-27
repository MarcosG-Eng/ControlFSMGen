----------------------------------------------------------------------------------
-- File: Debouncer.vhd
-- Purpose: Debounce input signals using shift register and AND logic
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Debouncer is
    generic ( N : natural := 4 );
    port    ( I     : in  STD_LOGIC;
              O     : out STD_LOGIC;
              reset : in  STD_LOGIC;
              clk   : in  STD_LOGIC );
end Debouncer;

architecture Behavioral of Debouncer is

signal   s         : STD_LOGIC_VECTOR(N-1 downto 0);
signal   Resultado : STD_LOGIC; -- Contains the AND of all bits of s.
component Reg_Des is
    generic( n     : integer);
    port   ( d     : in STD_LOGIC;
             q     : out STD_LOGIC_VECTOR(n-1 downto 0);
             reset : in STD_LOGIC;
             des   : in STD_LOGIC;
             clk   : in STD_LOGIC);
end component Reg_Des;

begin

Registro: Reg_Des   generic map(N)
                    port map(d=>I,q=>s,reset=>reset, des=>'1', clk=>clk);
AND_n : process(s)
    variable Parcial : STD_LOGIC;
    begin
        parcial := '1';
        for i in 0 to N - 1 loop
            Parcial := Parcial and s( i );
        end loop;
        Resultado <= Parcial;
    end process AND_n;

    O <= transport '1' after 1 ns when Resultado = '1' else '0' after 1 ns;

end Behavioral;
