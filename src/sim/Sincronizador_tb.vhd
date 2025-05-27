-- Testbench for Sincronizador
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Sincronizador_tb is
end Sincronizador_tb;

architecture sim of Sincronizador_tb is
    signal I, CKE, reset, clk : std_logic := '0';
    component Sincronizador is
        generic ( N : natural := 4 );
        port    ( I     : in  STD_LOGIC;
                  CKE   : out STD_LOGIC;
                  reset : in  STD_LOGIC;
                  clk   : in  STD_LOGIC );
    end component;

begin
    UUT: Sincronizador generic map(N => 4) port map(I => I, CKE => CKE, reset => reset, clk => clk);
    clk_process: process
    begin
        while now < 500 ns loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
        wait;
    end process;
    stim_proc: process
    begin
        reset <= '1'; wait for 20 ns;
        reset <= '0'; wait for 10 ns;
        I <= '1'; wait for 20 ns;
        I <= '0'; wait for 20 ns;
        I <= '1'; wait for 10 ns;
        I <= '0'; wait for 20 ns;
        wait;
    end process;
end sim;
