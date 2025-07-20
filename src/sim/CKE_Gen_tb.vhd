----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.07.2025 
-- Design Name: 
-- Module Name: CKE_Gen_tb - Behavioral
-- Project Name: ControlFSMGen
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench para CKE_Gen con estímulos estructurados
-- 
-- Dependencies: CKE_Gen.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- Genera estímulos para visualización en waveform viewer
-- El CKE_Gen produce un pulso único al detectar flancos de subida
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CKE_Gen_tb is
end CKE_Gen_tb;

architecture Behavioral of CKE_Gen_tb is

    -- Declaración del componente bajo test
    component CKE_Gen
        Port ( I : in STD_LOGIC;
               O : out STD_LOGIC;
               reset : in STD_LOGIC;
               clk : in STD_LOGIC);
    end component;
    
    -- Constantes de tiempo
    constant CLK_PERIOD : time := 10 ns;
    constant RESET_TIME : time := 25 ns;
    
    -- Señales de test
    signal clk_tb : STD_LOGIC := '0';
    signal reset_tb : STD_LOGIC := '1';
    signal I_tb : STD_LOGIC := '0';
    signal O_tb : STD_LOGIC;
    
    -- Señal para controlar la simulación
    signal sim_finished : boolean := false;

begin

    -- Instanciación del DUT (Device Under Test)
    DUT: CKE_Gen 
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

    -- Proceso de reset
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
        
        -- Pulso corto en la entrada
        I_tb <= '1'; wait for CLK_PERIOD;
        I_tb <= '0'; wait for 5*CLK_PERIOD;
        
        -- Pulso largo en la entrada
        I_tb <= '1'; wait for 3*CLK_PERIOD;
        I_tb <= '0'; wait for 5*CLK_PERIOD;
        
        -- Múltiples pulsos consecutivos
        for i in 1 to 3 loop
            I_tb <= '1'; wait for CLK_PERIOD;
            I_tb <= '0'; wait for 2*CLK_PERIOD;
        end loop;
        
        wait for 3*CLK_PERIOD;
        
        -- Reset durante operación
        I_tb <= '1'; wait for CLK_PERIOD;
        reset_tb <= '1'; wait for CLK_PERIOD;
        reset_tb <= '0'; wait for 2*CLK_PERIOD;
        I_tb <= '0'; wait for 3*CLK_PERIOD;
        
        -- Entrada mantenida en alto
        I_tb <= '1'; wait for 10*CLK_PERIOD;
        I_tb <= '0'; wait for 5*CLK_PERIOD;
        
        -- Patrón de flancos rápidos
        I_tb <= '0'; wait for CLK_PERIOD;
        I_tb <= '1'; wait for CLK_PERIOD;
        I_tb <= '0'; wait for CLK_PERIOD;
        I_tb <= '1'; wait for CLK_PERIOD;
        I_tb <= '0'; wait for CLK_PERIOD;
        I_tb <= '1'; wait for CLK_PERIOD;
        I_tb <= '0'; wait for 5*CLK_PERIOD;
        
        sim_finished <= true;
        wait;
    end process;

end Behavioral;
