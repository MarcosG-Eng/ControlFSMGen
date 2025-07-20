----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.07.2025 
-- Design Name: 
-- Module Name: FSM_PLC_tb - Behavioral
-- Project Name: ControlFSMGen
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench profesional para FSM_PLC
-- 
-- Dependencies: FSM_PLC.vhd, MUX_PLC.vhd, Reg_PLC.vhd, Sincronizador.vhd, Mis_Tipos_PLC.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- Este testbench verifica el comportamiento de la FSM_PLC (Moore)
-- con tablas de estado y salida configurables
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Tipos_FSM_PLC.ALL;

entity FSM_PLC_tb is
end FSM_PLC_tb;

architecture Behavioral of FSM_PLC_tb is

    -- Parámetros del testbench
    constant K_TEST : natural := 3;   -- 3 entradas
    constant P_TEST : natural := 4;   -- 4 salidas
    constant M_TEST : natural := 3;   -- 3 bits de estado (8 estados máximo)
    constant CLK_PERIOD : time := 10 ns;
    constant RESET_TIME : time := 25 ns;
    
    -- Declaración del componente bajo test
    component FSM_PLC
        generic( k : natural := 32;
                 p : natural := 32;
                 m : natural := 32;
                 T_DM : time := 10 ps;
                 T_D : time := 10 ps;
                 T_SU : time := 10 ps;
                 T_H : time := 10 ps;
                 T_W : time := 10 ps);
        port ( x : in STD_LOGIC_VECTOR( k - 1 downto 0 );
               y : out STD_LOGIC_VECTOR( p - 1 downto 0 );
               Tabla_De_Estado : in Tabla_FSM( 0 to 2**m - 1 );
               Tabla_De_Salida : in Tabla_FSM( 0 to 2**m - 1 );
               clk : in STD_LOGIC;
               cke : in STD_LOGIC;
               reset : in STD_LOGIC;
               Trigger : in STD_LOGIC );
    end component;
    
    -- Señales de test
    signal clk_tb : STD_LOGIC := '0';
    signal reset_tb : STD_LOGIC := '1';
    signal cke_tb : STD_LOGIC := '0';
    signal Trigger_tb : STD_LOGIC := '0';
    signal x_tb : STD_LOGIC_VECTOR(K_TEST-1 downto 0) := (others => '0');
    signal y_tb : STD_LOGIC_VECTOR(P_TEST-1 downto 0);
    
    -- Tablas de estado y salida
    signal Tabla_Estado_tb : Tabla_FSM(0 to 2**M_TEST - 1);
    signal Tabla_Salida_tb : Tabla_FSM(0 to 2**M_TEST - 1);
    
    -- Control de simulación
    signal sim_finished : boolean := false;
    
    -- Función para convertir std_logic_vector a string
    function to_string(vec : std_logic_vector) return string is
        variable result : string(1 to vec'length);
        variable idx : integer := 1;
    begin
        for i in vec'high downto vec'low loop
            if vec(i) = '1' then
                result(idx) := '1';
            else
                result(idx) := '0';
            end if;
            idx := idx + 1;
        end loop;
        return result;
    end function;

begin

    -- Instanciación del DUT
    DUT: FSM_PLC 
        generic map (
            k => K_TEST,
            p => P_TEST,
            m => M_TEST,
            T_DM => 10 ps,
            T_D => 10 ps,
            T_SU => 10 ps,
            T_H => 10 ps,
            T_W => 10 ps
        )
        port map (
            x => x_tb,
            y => y_tb,
            Tabla_De_Estado => Tabla_Estado_tb,
            Tabla_De_Salida => Tabla_Salida_tb,
            clk => clk_tb,
            cke => cke_tb,
            reset => reset_tb,
            Trigger => Trigger_tb
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

    -- Inicialización de tablas (FSM de ejemplo: Contador de secuencia)
    init_tables: process
    begin
        -- Tabla de Estados: Contador 0->1->2->3->0...
        -- Estado actual -> Próximo estado para diferentes entradas
        -- Formato: bits de estado justificados a la derecha en 32 bits
        
        -- Estado 0 (000): 
        -- Si x="000" -> Estado 0, Si x="001" -> Estado 1, etc.
        Tabla_Estado_tb(0) <= x"00000001"; -- 8 posibles transiciones concatenadas: Estado 1
        
        -- Estado 1 (001):
        Tabla_Estado_tb(1) <= x"00000002"; -- Estado 2
        
        -- Estado 2 (010):
        Tabla_Estado_tb(2) <= x"00000003"; -- Estado 3
        
        -- Estado 3 (011):
        Tabla_Estado_tb(3) <= x"00000000"; -- Estado 0 (vuelta)
        
        -- Estados 4-7: No usados en este ejemplo
        for i in 4 to 7 loop
            Tabla_Estado_tb(i) <= x"00000000";
        end loop;
        
        -- Tabla de Salidas (Moore): Salida depende solo del estado actual
        Tabla_Salida_tb(0) <= x"00000001"; -- Estado 0 -> Salida "0001"
        Tabla_Salida_tb(1) <= x"00000003"; -- Estado 1 -> Salida "0011"  
        Tabla_Salida_tb(2) <= x"00000007"; -- Estado 2 -> Salida "0111"
        Tabla_Salida_tb(3) <= x"0000000F"; -- Estado 3 -> Salida "1111"
        
        for i in 4 to 7 loop
            Tabla_Salida_tb(i) <= x"00000000";
        end loop;
        
        wait;
    end process;

    -- Proceso de estímulos
    stimulus_process: process
    begin
        -- Esperar que termine el reset
        wait until reset_tb = '0';
        wait for 2*CLK_PERIOD;
        
        report "Iniciando testbench para FSM_PLC" severity note;
        report "Parámetros: k=" & integer'image(K_TEST) & 
               " p=" & integer'image(P_TEST) & 
               " m=" & integer'image(M_TEST) severity note;
        
        -- Test 1: Estado inicial después del reset
        report "Test 1: Verificación de estado inicial" severity note;
        assert y_tb = "0001" 
            report "Error: Salida inicial incorrecta. Esperado: 0001, Obtenido: " & 
                   to_string(y_tb) 
            severity error;
        
        -- Test 2: Avance con cke habilitado
        report "Test 2: Avance con cke habilitado" severity note;
        cke_tb <= '1';
        x_tb <= "000"; -- Entrada que cause transición
        
        -- Avanzar varios estados
        wait for CLK_PERIOD;
        assert y_tb = "0011" 
            report "Error: Transición al estado 1. Esperado: 0011, Obtenido: " & 
                   to_string(y_tb) 
            severity error;
        
        wait for CLK_PERIOD;
        assert y_tb = "0111" 
            report "Error: Transición al estado 2. Esperado: 0111, Obtenido: " & 
                   to_string(y_tb) 
            severity error;
        
        wait for CLK_PERIOD;
        assert y_tb = "1111" 
            report "Error: Transición al estado 3. Esperado: 1111, Obtenido: " & 
                   to_string(y_tb) 
            severity error;
        
        wait for CLK_PERIOD;
        assert y_tb = "0001" 
            report "Error: Vuelta al estado 0. Esperado: 0001, Obtenido: " & 
                   to_string(y_tb) 
            severity error;
        
        -- Test 3: Deshabilitar cke (no debe avanzar)
        report "Test 3: cke deshabilitado" severity note;
        cke_tb <= '0';
        wait for 3*CLK_PERIOD;
        assert y_tb = "0001" 
            report "Error: FSM avanzó con cke deshabilitado" 
            severity error;
        
        -- Test 4: Usar Trigger para avance único
        report "Test 4: Avance con Trigger" severity note;
        -- Generar pulso de Trigger
        Trigger_tb <= '1';
        wait for CLK_PERIOD;
        Trigger_tb <= '0';
        wait for 5*CLK_PERIOD; -- Esperar a que el sincronizador procese
        
        assert y_tb = "0011" 
            report "Error: Trigger no causó avance. Esperado: 0011, Obtenido: " & 
                   to_string(y_tb) 
            severity error;
        
        -- Test 5: Múltiples pulsos de Trigger
        report "Test 5: Múltiples pulsos de Trigger" severity note;
        for i in 1 to 3 loop
            Trigger_tb <= '1';
            wait for CLK_PERIOD;
            Trigger_tb <= '0';
            wait for 5*CLK_PERIOD;
        end loop;
        
        assert y_tb = "0001" 
            report "Error: Secuencia con Trigger incorrecta. Esperado: 0001, Obtenido: " & 
                   to_string(y_tb) 
            severity error;
        
        -- Test 6: Reset durante operación
        report "Test 6: Reset durante operación" severity note;
        cke_tb <= '1';
        wait for 2*CLK_PERIOD; -- Avanzar algunos estados
        
        reset_tb <= '1';
        wait for CLK_PERIOD;
        reset_tb <= '0';
        wait for CLK_PERIOD;
        
        assert y_tb = "0001" 
            report "Error: Reset no restauró estado inicial" 
            severity error;
        
        -- Test 7: Combinación de cke y Trigger
        report "Test 7: Combinación cke + Trigger" severity note;
        cke_tb <= '1';
        Trigger_tb <= '1';
        wait for CLK_PERIOD;
        Trigger_tb <= '0';
        cke_tb <= '0';
        wait for CLK_PERIOD;
        
        -- Debe haber avanzado por la OR lógica
        assert y_tb = "0011" 
            report "Error: Combinación cke+Trigger falló" 
            severity error;
        
        -- Test 8: Diferentes entradas (cambiar tabla si es necesario)
        report "Test 8: Diferentes valores de entrada" severity note;
        cke_tb <= '1';
        
        -- Probar diferentes valores de x
        for i in 0 to 2**K_TEST - 1 loop
            x_tb <= std_logic_vector(to_unsigned(i, K_TEST));
            wait for CLK_PERIOD;
            report "Entrada x=" & to_string(x_tb) & " -> Salida y=" & to_string(y_tb) severity note;
        end loop;
        
        -- Test 9: Secuencia completa de estados
        report "Test 9: Secuencia completa de estados" severity note;
        reset_tb <= '1';
        wait for CLK_PERIOD;
        reset_tb <= '0';
        wait for CLK_PERIOD;
        
        cke_tb <= '1';
        x_tb <= "000";
        
        -- Recorrer toda la secuencia 0->1->2->3->0
        for i in 0 to 7 loop -- Más de una vuelta completa
            wait for CLK_PERIOD;
            report "Ciclo " & integer'image(i) & ": Salida = " & to_string(y_tb) severity note;
        end loop;
        
        -- Test 10: Trigger con rebote simulado
        report "Test 10: Trigger con rebote" severity note;
        cke_tb <= '0';
        
        -- Simular rebote en Trigger
        Trigger_tb <= '1';
        wait for CLK_PERIOD/4;
        Trigger_tb <= '0';
        wait for CLK_PERIOD/4;
        Trigger_tb <= '1';
        wait for CLK_PERIOD/4;
        Trigger_tb <= '0';
        wait for CLK_PERIOD/4;
        Trigger_tb <= '1';
        wait for CLK_PERIOD;
        Trigger_tb <= '0';
        
        wait for 10*CLK_PERIOD; -- Esperar procesamiento del sincronizador
        
        -- Debe haber avanzado solo una vez
        report "Estado después de Trigger con rebote: " & to_string(y_tb) severity note;
        
        report "Simulación completada exitosamente" severity note;
        sim_finished <= true;
        wait;
    end process;

    -- Proceso de monitoreo continuo
    monitor_process: process
        variable last_state : std_logic_vector(P_TEST-1 downto 0) := (others => 'U');
    begin
        wait until reset_tb = '0';
        
        while not sim_finished loop
            wait until rising_edge(clk_tb) or sim_finished;
            
            if not sim_finished and y_tb /= last_state then
                last_state := y_tb;
                report "Estado cambió a: " & to_string(y_tb) & 
                       " con entrada x=" & to_string(x_tb) &
                       " cke=" & std_logic'image(cke_tb) &
                       " en tiempo: " & time'image(now) severity note;
            end if;
        end loop;
        wait;
    end process;

end Behavioral;
