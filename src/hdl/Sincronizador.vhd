----------------------------------------------------------------------------------
-- File: Sincronizador.vhd
-- Purpose: Synchronize and debounce input signals for FSM triggers
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Sincronizador is
    generic ( N : natural := 4 );
    port    ( I     : in  STD_LOGIC;
              CKE   : out STD_LOGIC;
              reset : in  STD_LOGIC;
              clk   : in  STD_LOGIC );
end Sincronizador;

architecture Structure of Sincronizador is

signal    s1, s2 : STD_LOGIC;        -- Internal signals for the structure.

component Debouncer is generic ( n     : natural := 4 );
                       port    ( I     : in std_logic;
                                 O     : out std_logic;
                                 reset : in std_logic;
                                 clk   : in std_logic);
end component Debouncer;
component CKE_Gen is port( I : in std_logic; O : out std_logic; reset: in std_logic; clk: in std_logic);
end component CKE_Gen;

begin
DB:     Debouncer generic map( n )  
                  port    map (I=>I, O=>s2, reset=>reset,clk=>clk);
CKGEN:  CKE_Gen   port    map (I=>s2,O=>CKE,reset=>reset,clk=>clk);
end Structure;
