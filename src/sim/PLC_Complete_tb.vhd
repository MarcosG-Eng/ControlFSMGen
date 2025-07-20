----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.07.2025 
-- Design Name: 
-- Module Name: PLC_Complete_tb - Behavioral
-- Project Name: ControlFSMGen
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench para PLC con estímulos estructurados
-- 
-- Dependencies: PLC.vhd, FSM_PLC.vhd, y todos los componentes relacionados
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- Este testbench genera estímulos para visualización en waveform viewer
-- Analice el comportamiento del PLC en el cronograma de simulación
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PLC_Complete_tb is
end PLC_Complete_tb;

architecture Behavioral of PLC_Complete_tb is

    -- Parámetros del testbench
    constant K_TEST : natural := 3;   -- 3 entradas
    constant P_TEST : natural := 4;   -- 4 salidas  
    constant M_TEST : natural := 3;   -- 3 bits de estado
    constant CLK_PERIOD : time := 8 ns;
    constant RESET_TIME : time := 40 ns;
    
    -- Declaración del componente bajo test
    component PLC
        generic( k : natural := 32;
                 p : natural := 32;
                 m : natural := 32);
        Port ( x : in std_logic_vector(k-1 downto 0);
               y : out std_logic_vector(p-1 downto 0);
               Trigger : in STD_LOGIC;
               clk : in STD_LOGIC;
               cke : in STD_LOGIC;
               reset : in std_logic);
    end component;
    
    -- Señales de test
    signal clk_tb : STD_LOGIC := '0';
    signal reset_tb : STD_LOGIC := '1';
    signal cke_tb : STD_LOGIC := '1';
    signal Trigger_tb : STD_LOGIC := '0';
    signal x_tb : STD_LOGIC_VECTOR(K_TEST-1 downto 0) := (others => '0');
    signal y_tb : STD_LOGIC_VECTOR(P_TEST-1 downto 0);
    
    -- Control de simulación
    signal sim_finished : boolean := false;

begin

    -- Instanciación del DUT
    DUT: PLC 
        generic map (
            k => K_TEST,
            p => P_TEST,
            m => M_TEST
        )
        port map (
            x => x_tb,
            y => y_tb,
            Trigger => Trigger_tb,
            clk => clk_tb,
            cke => cke_tb,
            reset => reset_tb
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

    -- Proceso principal de estímulos
    stimulus_process: process
    begin
        -- Esperar que termine el reset
        wait until reset_tb = '0';
        wait for 3*CLK_PERIOD;
        
        -- Funcionamiento básico con CKE
        cke_tb <= '1';
        Trigger_tb <= '0';
        
        -- Entradas secuenciales básicas
        x_tb <= "000"; wait for 10*CLK_PERIOD;
        x_tb <= "001"; wait for 10*CLK_PERIOD;
        x_tb <= "010"; wait for 10*CLK_PERIOD;
        x_tb <= "011"; wait for 10*CLK_PERIOD;
        x_tb <= "100"; wait for 10*CLK_PERIOD;
        x_tb <= "101"; wait for 10*CLK_PERIOD;
        x_tb <= "110"; wait for 10*CLK_PERIOD;
        x_tb <= "111"; wait for 10*CLK_PERIOD;
        x_tb <= "000"; wait for 10*CLK_PERIOD;
        
        -- Cambio a modo Trigger
        cke_tb <= '0';  -- Deshabilitar CKE
        x_tb <= "001";
        wait for 5*CLK_PERIOD;
        
        -- Pulsos de Trigger con diferentes entradas
        Trigger_tb <= '1'; wait for CLK_PERIOD;
        Trigger_tb <= '0'; wait for 15*CLK_PERIOD;
        
        x_tb <= "010"; wait for 5*CLK_PERIOD;
        Trigger_tb <= '1'; wait for CLK_PERIOD;
        Trigger_tb <= '0'; wait for 15*CLK_PERIOD;
        
        x_tb <= "011"; wait for 5*CLK_PERIOD;
        Trigger_tb <= '1'; wait for CLK_PERIOD;
        Trigger_tb <= '0'; wait for 15*CLK_PERIOD;
        
        x_tb <= "100"; wait for 5*CLK_PERIOD;
        Trigger_tb <= '1'; wait for CLK_PERIOD;
        Trigger_tb <= '0'; wait for 15*CLK_PERIOD;
        
        -- Pulsos Trigger rápidos
        x_tb <= "101";
        wait for 3*CLK_PERIOD;
        
        -- Serie de pulsos Trigger
        for i in 1 to 8 loop
            Trigger_tb <= '1'; wait for CLK_PERIOD;
            Trigger_tb <= '0'; wait for 8*CLK_PERIOD;
        end loop;
        
        -- Combinación CKE y Trigger
        cke_tb <= '1';  -- Habilitar CKE nuevamente
        x_tb <= "110";
        wait for 5*CLK_PERIOD;
        
        -- Generar Trigger mientras CKE está activo
        Trigger_tb <= '1'; wait for CLK_PERIOD;
        Trigger_tb <= '0'; wait for 10*CLK_PERIOD;
        
        x_tb <= "111"; wait for 8*CLK_PERIOD;
        
        Trigger_tb <= '1'; wait for CLK_PERIOD;
        Trigger_tb <= '0'; wait for 10*CLK_PERIOD;
        
        -- Cambios rápidos de entrada
        cke_tb <= '1';
        
        x_tb <= "000"; wait for 2*CLK_PERIOD;
        x_tb <= "001"; wait for 2*CLK_PERIOD;
        x_tb <= "010"; wait for 2*CLK_PERIOD;
        x_tb <= "011"; wait for 2*CLK_PERIOD;
        x_tb <= "100"; wait for 2*CLK_PERIOD;
        x_tb <= "101"; wait for 2*CLK_PERIOD;
        x_tb <= "110"; wait for 2*CLK_PERIOD;
        x_tb <= "111"; wait for 2*CLK_PERIOD;
        
        wait for 10*CLK_PERIOD;
        
        -- Reset durante operación
        x_tb <= "101";
        cke_tb <= '1';
        wait for 8*CLK_PERIOD;
        
        -- Reset sincronizado
        reset_tb <= '1';
        wait for 5*CLK_PERIOD;
        reset_tb <= '0';
        wait for 5*CLK_PERIOD;
        
        -- Continuar después del reset
        x_tb <= "010";
        wait for 8*CLK_PERIOD;
        
        -- Patrones específicos
        cke_tb <= '1';
        
        -- Patrón ascendente y descendente
        x_tb <= "000"; wait for 6*CLK_PERIOD;
        x_tb <= "001"; wait for 6*CLK_PERIOD;
        x_tb <= "010"; wait for 6*CLK_PERIOD;
        x_tb <= "011"; wait for 6*CLK_PERIOD;
        x_tb <= "100"; wait for 6*CLK_PERIOD;
        x_tb <= "011"; wait for 6*CLK_PERIOD;
        x_tb <= "010"; wait for 6*CLK_PERIOD;
        x_tb <= "001"; wait for 6*CLK_PERIOD;
        x_tb <= "000"; wait for 6*CLK_PERIOD;
        
        -- Modo manual (solo Trigger)
        cke_tb <= '0';
        x_tb <= "000"; wait for 3*CLK_PERIOD;
        
        -- Secuencia de trabajo manual
        Trigger_tb <= '1'; wait for CLK_PERIOD; Trigger_tb <= '0'; wait for 12*CLK_PERIOD;
        
        x_tb <= "001"; wait for 3*CLK_PERIOD;
        Trigger_tb <= '1'; wait for CLK_PERIOD; Trigger_tb <= '0'; wait for 12*CLK_PERIOD;
        
        x_tb <= "011"; wait for 3*CLK_PERIOD;
        Trigger_tb <= '1'; wait for CLK_PERIOD; Trigger_tb <= '0'; wait for 12*CLK_PERIOD;
        
        x_tb <= "111"; wait for 3*CLK_PERIOD;
        Trigger_tb <= '1'; wait for CLK_PERIOD; Trigger_tb <= '0'; wait for 12*CLK_PERIOD;
        
        x_tb <= "000"; wait for 3*CLK_PERIOD;
        Trigger_tb <= '1'; wait for CLK_PERIOD; Trigger_tb <= '0'; wait for 12*CLK_PERIOD;
        
        -- Estabilización final
        cke_tb <= '1';
        x_tb <= "000";
        wait for 20*CLK_PERIOD;
        
        -- Finalizar simulación
        sim_finished <= true;
        wait;
    end process;

end Behavioral;
