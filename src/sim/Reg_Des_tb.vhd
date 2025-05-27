-- Testbench for Reg_Des
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Reg_Des_tb is
end Reg_Des_tb;

architecture sim of Reg_Des_tb is
    signal d, reset, des, clk : std_logic := '0';
    signal q : std_logic_vector(7 downto 0);
    component Reg_Des is
        generic( n : integer := 8);
        Port   ( d     : in STD_LOGIC;
                 q     : out STD_LOGIC_VECTOR(n-1 downto 0);
                 reset : in STD_LOGIC;
                 des   : in STD_LOGIC;
                 clk   : in STD_LOGIC);
    end component;

begin
    UUT: Reg_Des generic map(n => 8) port map(d => d, q => q, reset => reset, des => des, clk => clk);
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
        des <= '1';
        d <= '1'; wait for 10 ns;
        d <= '0'; wait for 10 ns;
        d <= '1'; wait for 10 ns;
        des <= '0'; wait for 20 ns;
        wait;
    end process;
end sim;
