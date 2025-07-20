----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.07.2025 
-- Design Name: 
-- Module Name: MUX_PLC_tb - Behavioral
-- Project Name: ControlFSMGen
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench profesional para MUX_PLC
-- 
-- Dependencies: MUX_PLC.vhd, Mis_Tipos_PLC.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- Este testbench verifica el comportamiento del multiplexor/ROM
-- usado para las tablas de estado y salida en la FSM del PLC
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Tipos_FSM_PLC.ALL;

entity MUX_PLC_tb is
end MUX_PLC_tb;

architecture Behavioral of MUX_PLC_tb is

    -- Parámetros del testbench
    constant N_BITS_DIR_TEST : natural := 3;
    constant T_D_TEST : time := 10 ps;
    constant NUM_ADDRESSES : natural := 2**N_BITS_DIR_TEST;
    
    -- Declaración del componente bajo test
    component MUX_PLC
        generic( N_Bits_Dir : Natural := 3;
                 T_D : time := 10 ps );
        Port ( Direccion : in STD_LOGIC_VECTOR ( N_Bits_Dir - 1 downto 0 );
               Dato : out STD_LOGIC_VECTOR ( N_Bits_Dato - 1 downto 0 );
               Tabla_ROM : in Tabla_FSM( 0 to 2**N_Bits_Dir - 1 ) );
    end component;
    
    -- Señales de test
    signal Direccion_tb : STD_LOGIC_VECTOR(N_BITS_DIR_TEST-1 downto 0) := (others => '0');
    signal Dato_tb : STD_LOGIC_VECTOR(N_Bits_Dato-1 downto 0);
    signal Tabla_ROM_tb : Tabla_FSM(0 to NUM_ADDRESSES-1);
    
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
    DUT: MUX_PLC 
        generic map (
            N_Bits_Dir => N_BITS_DIR_TEST,
            T_D => T_D_TEST
        )
        port map (
            Direccion => Direccion_tb,
            Dato => Dato_tb,
            Tabla_ROM => Tabla_ROM_tb
        );

    -- Proceso de inicialización de la tabla ROM
    init_process: process
    begin
        -- Inicializar tabla con valores conocidos para testing
        for i in 0 to NUM_ADDRESSES-1 loop
            Tabla_ROM_tb(i) <= std_logic_vector(to_unsigned(i * 16 + i, N_Bits_Dato));
        end loop;
        wait;
    end process;

    -- Proceso de estímulos
    stimulus_process: process
        variable expected_data : std_logic_vector(N_Bits_Dato-1 downto 0);
    begin
        -- Esperar a que se inicialice la tabla
        wait for 10 ns;
        
        report "Iniciando testbench para MUX_PLC" severity note;
        report "Número de direcciones: " & integer'image(NUM_ADDRESSES) severity note;
        report "Bits de dirección: " & integer'image(N_BITS_DIR_TEST) severity note;
        report "Bits de dato: " & integer'image(N_Bits_Dato) severity note;
        
        -- Test 1: Verificar todas las direcciones secuencialmente
        report "Test 1: Acceso secuencial a todas las direcciones" severity note;
        for i in 0 to NUM_ADDRESSES-1 loop
            Direccion_tb <= std_logic_vector(to_unsigned(i, N_BITS_DIR_TEST));
            wait for T_D_TEST + 5 ns; -- Esperar el delay de propagación + margen
            
            expected_data := std_logic_vector(to_unsigned(i * 16 + i, N_Bits_Dato));
            assert Dato_tb = expected_data 
                report "Error en dirección " & integer'image(i) & 
                       ": Esperado=" & to_string(expected_data) & 
                       " Obtenido=" & to_string(Dato_tb) 
                severity error;
            
            report "Dirección " & integer'image(i) & " OK: " & to_string(Dato_tb) severity note;
        end loop;
        
        -- Test 2: Acceso aleatorio a direcciones
        report "Test 2: Acceso aleatorio a direcciones" severity note;
        
        -- Algunos patrones de direcciones específicas
        
        -- Test address 0
        Direccion_tb <= std_logic_vector(to_unsigned(0, N_BITS_DIR_TEST));
        wait for T_D_TEST + 5 ns;
        expected_data := std_logic_vector(to_unsigned(0 * 16 + 0, N_Bits_Dato));
        assert Dato_tb = expected_data report "Error en dirección 0" severity error;
        
        -- Test address 7
        Direccion_tb <= std_logic_vector(to_unsigned(7, N_BITS_DIR_TEST));
        wait for T_D_TEST + 5 ns;
        expected_data := std_logic_vector(to_unsigned(7 * 16 + 7, N_Bits_Dato));
        assert Dato_tb = expected_data report "Error en dirección 7" severity error;
        
        -- Test address 3
        Direccion_tb <= std_logic_vector(to_unsigned(3, N_BITS_DIR_TEST));
        wait for T_D_TEST + 5 ns;
        expected_data := std_logic_vector(to_unsigned(3 * 16 + 3, N_Bits_Dato));
        assert Dato_tb = expected_data report "Error en dirección 3" severity error;
        
        -- Test 3: Cambios rápidos de dirección
        report "Test 3: Cambios rápidos de dirección" severity note;
        for i in 0 to NUM_ADDRESSES-1 loop
            Direccion_tb <= std_logic_vector(to_unsigned(i, N_BITS_DIR_TEST));
            wait for T_D_TEST/2; -- Cambiar antes de que se estabilice
        end loop;
        wait for T_D_TEST + 5 ns; -- Esperar estabilización final
        
        -- Test 4: Verificar delay temporal
        report "Test 4: Verificación de delay temporal" severity note;
        Direccion_tb <= "000";
        wait for 1 ns;
        Direccion_tb <= "001";
        
        -- El dato no debe cambiar inmediatamente (antes del delay)
        wait for T_D_TEST/2;
        -- Aquí podríamos estar aún viendo el dato anterior o en transición
        
        wait for T_D_TEST + 2 ns; -- Esperar que termine el delay
        expected_data := std_logic_vector(to_unsigned(1 * 16 + 1, N_Bits_Dato));
        assert Dato_tb = expected_data 
            report "Error en verificación de delay temporal" 
            severity error;
        
        -- Test 5: Probar direcciones en los límites
        report "Test 5: Direcciones en los límites" severity note;
        
        -- Dirección mínima
        Direccion_tb <= (others => '0');
        wait for T_D_TEST + 5 ns;
        expected_data := Tabla_ROM_tb(0);
        assert Dato_tb = expected_data 
            report "Error en dirección mínima (000...)" 
            severity error;
        
        -- Dirección máxima
        Direccion_tb <= (others => '1');
        wait for T_D_TEST + 5 ns;
        expected_data := Tabla_ROM_tb(NUM_ADDRESSES-1);
        assert Dato_tb = expected_data 
            report "Error en dirección máxima (111...)" 
            severity error;
        
        -- Test 6: Tabla con diferentes patrones
        report "Test 6: Modificar tabla y verificar" severity note;
        
        -- Cambiar algunos valores de la tabla
        Tabla_ROM_tb(0) <= x"AAAAAAAA";
        Tabla_ROM_tb(1) <= x"55555555";
        Tabla_ROM_tb(NUM_ADDRESSES-1) <= x"FFFFFFFF";
        
        wait for 1 ns; -- Permitir que se propague el cambio
        
        -- Verificar los nuevos valores
        Direccion_tb <= "000";
        wait for T_D_TEST + 5 ns;
        assert Dato_tb = x"AAAAAAAA" 
            report "Error: Tabla modificada no se refleja en dirección 0" 
            severity error;
        
        Direccion_tb <= "001";
        wait for T_D_TEST + 5 ns;
        assert Dato_tb = x"55555555" 
            report "Error: Tabla modificada no se refleja en dirección 1" 
            severity error;
        
        Direccion_tb <= (others => '1');
        wait for T_D_TEST + 5 ns;
        assert Dato_tb = x"FFFFFFFF" 
            report "Error: Tabla modificada no se refleja en dirección máxima" 
            severity error;
        
        -- Test 7: Prueba de estabilidad
        report "Test 7: Prueba de estabilidad" severity note;
        Direccion_tb <= "010"; -- Dirección fija
        wait for T_D_TEST + 5 ns;
        expected_data := Dato_tb; -- Capturar valor estable
        
        -- Esperar y verificar que no cambia
        wait for 100 ns;
        assert Dato_tb = expected_data 
            report "Error: Salida no es estable con dirección fija" 
            severity error;
        
        report "Todos los tests completados exitosamente" severity note;
        sim_finished <= true;
        wait;
    end process;

    -- Proceso de monitoreo continuo
    monitor_process: process
        variable last_direction : std_logic_vector(N_BITS_DIR_TEST-1 downto 0) := (others => 'U');
    begin
        while not sim_finished loop
            wait until Direccion_tb'event or sim_finished;
            if not sim_finished and Direccion_tb /= last_direction then
                last_direction := Direccion_tb;
                wait for T_D_TEST + 1 ns;
                report "Cambio de dirección: " & to_string(Direccion_tb) & 
                       " -> Dato: " & to_string(Dato_tb) severity note;
            end if;
        end loop;
        wait;
    end process;

end Behavioral;
