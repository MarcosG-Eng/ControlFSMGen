----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.07.2025 
-- Design Name: 
-- Module Name: Debouncer_tb - Behavioral
-- Project Name: ControlFSMGen
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench para Debouncer con estímulos estructurados
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

entity Debouncer_tb is
end Debouncer_tb;

architecture Behavioral of Debouncer_tb is

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
    
    -- Procedimiento para simular rebote
    procedure simulate_bounce(signal input_sig : out std_logic;
                            constant final_value : std_logic;
                            constant bounce_duration : time;
                            constant bounce_period : time) is
    begin
        for i in 1 to integer(bounce_duration / bounce_period) loop
            input_sig <= not final_value;
            wait for bounce_period / 2;
            input_sig <= final_value;
            wait for bounce_period / 2;
        end loop;
        input_sig <= final_value;
    end procedure;

begin

    -- Instanciación del DUT
    DUT: Debouncer 
        generic map (n => N_BITS_TEST)
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
        
        report "Iniciando testbench para Debouncer con n=" & integer'image(N_BITS_TEST) severity note;
        
        -- Test 1: Verificar estado inicial
        report "Test 1: Verificación de estado inicial" severity note;
        assert O_tb = '0' 
            report "Error: La salida inicial no es '0'" 
            severity error;
        
        -- Test 2: Entrada estable en '0' (no debería cambiar)
        report "Test 2: Entrada estable en '0'" severity note;
        I_tb <= '0';
        wait for DEBOUNCE_TIME + 2*CLK_PERIOD;
        assert O_tb = '0' 
            report "Error: La salida cambió con entrada estable en '0'" 
            severity error;
        
        -- Test 3: Transición limpia de '0' a '1' (sin rebote)
        report "Test 3: Transición limpia 0->1" severity note;
        I_tb <= '1';
        wait for DEBOUNCE_TIME + CLK_PERIOD;
        assert O_tb = '1' 
            report "Error: No se detectó transición limpia 0->1" 
            severity error;
        
        -- Test 4: Entrada estable en '1'
        report "Test 4: Entrada estable en '1'" severity note;
        wait for DEBOUNCE_TIME;
        assert O_tb = '1' 
            report "Error: La salida no se mantiene en '1'" 
            severity error;
        
        -- Test 5: Transición limpia de '1' a '0'
        report "Test 5: Transición limpia 1->0" severity note;
        I_tb <= '0';
        wait for DEBOUNCE_TIME + CLK_PERIOD;
        assert O_tb = '0' 
            report "Error: No se detectó transición limpia 1->0" 
            severity error;
        
        -- Test 6: Pulso muy corto (menor que el tiempo de debounce)
        report "Test 6: Pulso muy corto (debería ser filtrado)" severity note;
        I_tb <= '1';
        wait for CLK_PERIOD; -- Pulso de solo 1 ciclo
        I_tb <= '0';
        wait for DEBOUNCE_TIME + CLK_PERIOD;
        assert O_tb = '0' 
            report "Error: El pulso corto no fue filtrado" 
            severity error;
        
        -- Test 7: Simulación de rebote en flanco de subida
        report "Test 7: Rebote en flanco de subida" severity note;
        simulate_bounce(I_tb, '1', 3*CLK_PERIOD, CLK_PERIOD/2);
        wait for DEBOUNCE_TIME + CLK_PERIOD;
        assert O_tb = '1' 
            report "Error: No se filtró correctamente el rebote de subida" 
            severity error;
        
        -- Test 8: Simulación de rebote en flanco de bajada
        report "Test 8: Rebote en flanco de bajada" severity note;
        simulate_bounce(I_tb, '0', 3*CLK_PERIOD, CLK_PERIOD/2);
        wait for DEBOUNCE_TIME + CLK_PERIOD;
        assert O_tb = '0' 
            report "Error: No se filtró correctamente el rebote de bajada" 
            severity error;
        
        -- Test 9: Reset durante operación
        report "Test 9: Reset durante operación" severity note;
        I_tb <= '1';
        wait for DEBOUNCE_TIME/2;
        reset_tb <= '1';
        wait for CLK_PERIOD;
        reset_tb <= '0';
        wait for CLK_PERIOD;
        assert O_tb = '0' 
            report "Error: Reset durante operación no funciona" 
            severity error;
        
        -- Test 10: Múltiples transiciones rápidas (glitches)
        report "Test 10: Múltiples glitches" severity note;
        I_tb <= '0';
        wait for CLK_PERIOD;
        
        -- Generar varios glitches
        for i in 1 to 5 loop
            I_tb <= '1';
            wait for CLK_PERIOD/4;
            I_tb <= '0';
            wait for CLK_PERIOD/2;
        end loop;
        
        wait for DEBOUNCE_TIME + CLK_PERIOD;
        assert O_tb = '0' 
            report "Error: Los glitches no fueron filtrados correctamente" 
            severity error;
        
        -- Test 11: Transición válida después de glitches
        report "Test 11: Transición válida después de glitches" severity note;
        I_tb <= '1';
        wait for DEBOUNCE_TIME + CLK_PERIOD;
        assert O_tb = '1' 
            report "Error: Transición válida después de glitches falló" 
            severity error;
        
        -- Test 12: Patrón complejo de entrada
        report "Test 12: Patrón complejo de entrada" severity note;
        
        -- Secuencia: rebote -> estable -> glitch -> estable
        I_tb <= '0';
        wait for CLK_PERIOD;
        
        -- Rebote inicial
        simulate_bounce(I_tb, '1', 2*CLK_PERIOD, CLK_PERIOD/3);
        
        -- Mantener estable
        wait for DEBOUNCE_TIME + CLK_PERIOD;
        assert O_tb = '1' report "Error en patrón complejo (parte 1)" severity error;
        
        -- Glitch breve
        I_tb <= '0';
        wait for CLK_PERIOD/2;
        I_tb <= '1';
        
        -- Mantener estable
        wait for DEBOUNCE_TIME;
        assert O_tb = '1' report "Error en patrón complejo (parte 2)" severity error;
        
        -- Test 13: Verificar tiempo exacto de debounce
        report "Test 13: Verificación de tiempo exacto de debounce" severity note;
        I_tb <= '0';
        wait for DEBOUNCE_TIME + CLK_PERIOD;
        
        I_tb <= '1';
        -- Verificar que no cambia antes del tiempo requerido
        wait for DEBOUNCE_TIME - CLK_PERIOD;
        assert O_tb = '0' 
            report "Error: Cambió antes del tiempo de debounce" 
            severity error;
        
        -- Verificar que cambia después del tiempo requerido
        wait for 2*CLK_PERIOD;
        assert O_tb = '1' 
            report "Error: No cambió después del tiempo de debounce" 
            severity error;
        
        report "Simulación completada exitosamente" severity note;
        sim_finished <= true;
        wait;
    end process;

    -- Proceso de monitoreo
    monitor_process: process
        variable last_input : std_logic := 'U';
        variable last_output : std_logic := 'U';
    begin
        wait until reset_tb = '0';
        
        while not sim_finished loop
            wait until rising_edge(clk_tb) or sim_finished;
            
            if not sim_finished then
                if I_tb /= last_input then
                    last_input := I_tb;
                    report "Entrada cambió a: " & std_logic'image(I_tb) severity note;
                end if;
                
                if O_tb /= last_output then
                    last_output := O_tb;
                    report "Salida cambió a: " & std_logic'image(O_tb) severity note;
                end if;
            end if;
        end loop;
        wait;
    end process;

end Behavioral;
