----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.07.2025 
-- Design Name: 
-- Module Name: Simple_Debouncer_tb - Behavioral
-- Project Name: ControlFSMGen
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench simple para Debouncer con estímulos estructurados
-- 
-- Dependencies: Debouncer.vhd, Reg_Des.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- Genera estímulos para visualizar el comportamiento del debouncer
-- en el waveform viewer. Elimina rebotes de señales de entrada.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Simple_Debouncer_tb is
end Simple_Debouncer_tb;

architecture Behavioral of Simple_Debouncer_tb is

    -- Parámetros del testbench
    constant N_BITS_TEST : natural := 4;
    constant CLK_PERIOD : time := 10 ns;
    constant RESET_TIME : time := 25 ns;
    constant DEBOUNCE_TIME : time := N_BITS_TEST * CLK_PERIOD;
    
    -- Declaración del componente bajo test
    component Debouncer
        generic ( n : natural := 4 );
        Port ( I : in STD_LOGIC;
               O : out STD_LOGIC;
               reset : in STD_LOGIC;
               clk : in STD_LOGIC );
    end component;
    
    -- Señales de test
    signal clk_tb : STD_LOGIC := '0';
    signal reset_tb : STD_LOGIC := '1';
    signal I_tb : STD_LOGIC := '0';
    signal O_tb : STD_LOGIC;
    
    -- Control de simulación
    signal sim_finished : boolean := false;

begin

    -- Instanciación del DUT
    DUT: Debouncer 
        generic map ( n => N_BITS_TEST )
        port map (
            I => I_tb,
            O => O_tb,
            reset => reset_tb,
            clk => clk_tb
        );

    -- Generador de reloj
    clk_process: process
    begin
        while not sim_finished loop
            clk_tb <= '0';
            wait for CLK_PERIOD/2;
            clk_tb <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Proceso de reset inicial
    reset_process: process
    begin
        reset_tb <= '1';
        wait for RESET_TIME;
        reset_tb <= '0';
        wait;
    end process;

    -- Proceso de estímulos
    stimulus_process: process
    begin
        -- Esperar que termine el reset
        wait until reset_tb = '0';
        wait for 2*CLK_PERIOD;
        
        -- Estado inicial - entrada estable en '0'
        I_tb <= '0';
        wait for DEBOUNCE_TIME + 2*CLK_PERIOD;
        
        -- Transición limpia de '0' a '1'
        I_tb <= '1';
        wait for DEBOUNCE_TIME + CLK_PERIOD;
        
        -- Mantener entrada estable en '1'
        wait for DEBOUNCE_TIME;
        
        -- Transición limpia de '1' a '0'
        I_tb <= '0';
        wait for DEBOUNCE_TIME + CLK_PERIOD;
        
        -- Pulso muy corto (debería ser filtrado)
        I_tb <= '1'; wait for CLK_PERIOD;
        I_tb <= '0'; wait for DEBOUNCE_TIME + CLK_PERIOD;
        
        -- Simulación de rebote mecánico
        -- Rebote en flanco de subida
        I_tb <= '1'; wait for CLK_PERIOD/4;
        I_tb <= '0'; wait for CLK_PERIOD/4;
        I_tb <= '1'; wait for CLK_PERIOD/4;
        I_tb <= '0'; wait for CLK_PERIOD/4;
        I_tb <= '1'; wait for CLK_PERIOD/4;
        I_tb <= '0'; wait for CLK_PERIOD/4;
        I_tb <= '1'; -- Estado final estable
        wait for DEBOUNCE_TIME + CLK_PERIOD;
        
        -- Rebote en flanco de bajada
        I_tb <= '0'; wait for CLK_PERIOD/4;
        I_tb <= '1'; wait for CLK_PERIOD/4;
        I_tb <= '0'; wait for CLK_PERIOD/4;
        I_tb <= '1'; wait for CLK_PERIOD/4;
        I_tb <= '0'; -- Estado final estable
        wait for DEBOUNCE_TIME + CLK_PERIOD;
        
        -- Reset durante operación
        I_tb <= '1';
        wait for DEBOUNCE_TIME/2;
        reset_tb <= '1'; wait for CLK_PERIOD;
        reset_tb <= '0'; wait for CLK_PERIOD;
        
        -- Múltiples glitches
        I_tb <= '0'; wait for CLK_PERIOD;
        
        for i in 1 to 5 loop
            I_tb <= '1'; wait for CLK_PERIOD/4;
            I_tb <= '0'; wait for CLK_PERIOD/2;
        end loop;
        
        wait for DEBOUNCE_TIME + CLK_PERIOD;
        
        -- Transición final válida
        I_tb <= '1';
        wait for DEBOUNCE_TIME + 2*CLK_PERIOD;
        I_tb <= '0';
        wait for DEBOUNCE_TIME + 2*CLK_PERIOD;
        
        sim_finished <= true;
        wait;
    end process;

end Behavioral;
