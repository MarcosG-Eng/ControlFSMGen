-- Testbench for Reg_PLC
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Reg_PLC_tb is
end Reg_PLC_tb;

architecture sim of Reg_PLC_tb is
    signal D, Q : std_logic_vector(7 downto 0) := (others => '0');
    signal reset, cke, clk : std_logic := '0';
    component Reg_PLC is
        generic( N_Bits_Reg : integer := 8;
                  T_D        : time := 10 ps );
        Port   ( D : in  STD_LOGIC_VECTOR(N_Bits_Reg-1 downto 0);
                 Q : out STD_LOGIC_VECTOR(N_Bits_Reg-1 downto 0);
                 reset : in STD_LOGIC;
                 cke : in STD_LOGIC;
                 clk : in STD_LOGIC);
    end component;

begin
    UUT: Reg_PLC generic map(N_Bits_Reg => 8) port map(D => D, Q => Q, reset => reset, cke => cke, clk => clk);
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
        cke <= '1';
        D <= x"AA"; wait for 10 ns;
        D <= x"55"; wait for 10 ns;
        cke <= '0'; wait for 20 ns;
        wait;
    end process;
end sim;
