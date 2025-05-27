-- Testbench for CKE_Gen
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CKE_Gen_tb is
end CKE_Gen_tb;

architecture sim of CKE_Gen_tb is
    signal I, O, reset, clk : std_logic := '0';
    component CKE_Gen is
        port(
            I     : in  STD_LOGIC;
            O     : out STD_LOGIC;
            reset : in  STD_LOGIC;
            clk   : in  STD_LOGIC
        );
    end component;

begin
    UUT: CKE_Gen port map(I => I, O => O, reset => reset, clk => clk);
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
