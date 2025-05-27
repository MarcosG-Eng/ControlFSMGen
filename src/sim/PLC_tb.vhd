-- Testbench for PLC
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PLC_tb is
end PLC_tb;

architecture sim of PLC_tb is
    constant K : natural := 2;
    constant P : natural := 2;
    constant M : natural := 4;
    signal x : std_logic_vector(K-1 downto 0) := (others => '0');
    signal y : std_logic_vector(P-1 downto 0);
    signal Trigger, clk, cke, reset : std_logic := '0';
    component PLC is
        generic(
            K : natural := 2;
            P : natural := 2;
            M : natural := 4
        );
        port(
            x      : in  STD_LOGIC_VECTOR(K-1 downto 0);
            y      : out STD_LOGIC_VECTOR(P-1 downto 0);
            Trigger: in  STD_LOGIC;
            clk    : in  STD_LOGIC;
            cke    : in  STD_LOGIC;
            reset  : in  STD_LOGIC
        );
    end component;

begin
    UUT: PLC generic map(K => K, P => P, M => M) port map(x => x, y => y, Trigger => Trigger, clk => clk, cke => cke, reset => reset);
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
        Trigger <= '1'; wait for 10 ns;
        Trigger <= '0'; wait for 20 ns;
        x <= "01"; wait for 20 ns;
        x <= "10"; wait for 20 ns;
        wait;
    end process;
end sim;
