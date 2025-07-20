----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.07.2025 
-- Design Name: 
-- Module Name: Reg_Des_tb - Behavioral
-- Project Name: ControlFSMGen
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench para Reg_Des (Registro de Desplazamiento)
-- 
-- Dependencies: Reg_Des.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- Este testbench genera estímulos para verificar manualmente el comportamiento
-- del registro de desplazamiento. Use el waveform viewer para analizar resultados.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Reg_Des_tb is
end Reg_Des_tb;

architecture Behavioral of Reg_Des_tb is

    -- Parámetros del testbench
    constant N_BITS : integer := 8;
    constant CLK_PERIOD : time := 10 ns;
    constant RESET_TIME : time := 25 ns;
    
    -- Declaración del componente bajo test
    component Reg_Des
        generic( n : integer := 8);
        Port ( d : in STD_LOGIC;
               q : out STD_LOGIC_VECTOR(n-1 downto 0);
               reset : in STD_LOGIC;
               des : in STD_LOGIC;
               clk : in STD_LOGIC);
    end component;
    
    -- Señales de test
    signal clk_tb : STD_LOGIC := '0';
    signal reset_tb : STD_LOGIC := '1';
    signal d_tb : STD_LOGIC := '0';
    signal des_tb : STD_LOGIC := '0';
    signal q_tb : STD_LOGIC_VECTOR(N_BITS-1 downto 0);
    
    -- Control de simulación
    signal sim_finished : boolean := false;

begin

    -- Instanciación del DUT
    DUT: Reg_Des 
        generic map (n => N_BITS)
        port map (
            d => d_tb,
            q => q_tb,
            reset => reset_tb,
            des => des_tb,
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
        variable test_pattern : std_logic_vector(7 downto 0) := "10110101";
    begin
        -- Esperar que termine el reset
        wait until reset_tb = '0';
        wait for 2*CLK_PERIOD;
        
        -- Test 1: Estado inicial después del reset
        report "Test 1: Verificando estado inicial" severity note;
        wait for 2*CLK_PERIOD;
        
        -- Test 2: Desplazamiento deshabilitado
        report "Test 2: Probando con desplazamiento deshabilitado" severity note;
        des_tb <= '0';
        d_tb <= '1';
        wait for 3*CLK_PERIOD;
        
        -- Test 3: Habilitar desplazamiento y enviar patrón conocido
        report "Test 3: Enviando patrón 10110101" severity note;
        des_tb <= '1';
        
        -- Desplazar el patrón bit por bit (MSB primero)
        for i in test_pattern'high downto test_pattern'low loop
            d_tb <= test_pattern(i);
            wait for CLK_PERIOD;
        end loop;
        
        -- Esperar estabilización
        wait for CLK_PERIOD;
        
        -- Test 4: Continuar desplazando con ceros
        report "Test 4: Enviando secuencia de ceros" severity note;
        d_tb <= '0';
        for i in 1 to N_BITS loop
            wait for CLK_PERIOD;
        end loop;
        
        -- Test 5: Patrón alternante
        report "Test 5: Enviando patrón alternante" severity note;
        for i in 1 to N_BITS*2 loop
            d_tb <= '1' when (i mod 2 = 1) else '0';
            wait for CLK_PERIOD;
        end loop;
        
        -- Test 6: Reset durante operación
        report "Test 6: Aplicando reset durante operación" severity note;
        d_tb <= '1';
        wait for CLK_PERIOD;
        reset_tb <= '1';
        wait for CLK_PERIOD;
        reset_tb <= '0';
        wait for CLK_PERIOD;
        
        -- Test 7: Control de habilitación
        report "Test 7: Probando control de habilitación" severity note;
        des_tb <= '1';
        d_tb <= '1';
        wait for 2*CLK_PERIOD;
        des_tb <= '0';  -- Deshabilitar
        wait for 2*CLK_PERIOD;
        des_tb <= '1';  -- Volver a habilitar
        wait for 2*CLK_PERIOD;
        
        -- Test 8: Secuencia completa de unos
        report "Test 8: Enviando secuencia de unos" severity note;
        d_tb <= '1';
        for i in 1 to N_BITS loop
            wait for CLK_PERIOD;
        end loop;
        
        -- Test 9: Patrón de prueba final
        report "Test 9: Patrón final 11001010" severity note;
        test_pattern := "11001010";
        for i in test_pattern'high downto test_pattern'low loop
            d_tb <= test_pattern(i);
            wait for CLK_PERIOD;
        end loop;
        
        wait for 5*CLK_PERIOD;
        report "Generación de estímulos completada - Analice waveforms" severity note;
        sim_finished <= true;
        wait;
    end process;

    -- Proceso de monitoreo informativo
    monitor_process: process
    begin
        wait until reset_tb = '0';
        
        while not sim_finished loop
            wait until rising_edge(clk_tb);
            -- Solo reportar información cuando hay actividad
            if des_tb = '1' then
                report "Shift: d=" & std_logic'image(d_tb) & 
                       " | Output q=" & integer'image(to_integer(unsigned(q_tb))) & 
                       " (bin)" severity note;
            end if;
        end loop;
        wait;
    end process;

end Behavioral;
