----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.07.2023 18:42:20 (Updated: 20.07.2025)
-- Design Name: 
-- Module Name: PLC_tb - Behavioral
-- Project Name: ControlFSMGen
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench para PLC (Programmable Logic Controller)
-- 
-- Dependencies: PLC.vhd, FSM_PLC.vhd, Mis_Tipos_PLC.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.02 - Simplified for waveform analysis
-- Additional Comments:
-- Este testbench genera estímulos para el PLC. 
-- Use el waveform viewer para analizar el comportamiento.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PLC_tb is
--  Port ( );
end PLC_tb;

architecture Behavioral of PLC_tb is

    -- Parámetros del testbench
    constant CLK_PERIOD : time := 8 ns;
    constant RESET_TIME : time := 40 ns;
    constant k : natural := 2;    -- 2 entradas
    constant p : natural := 2;    -- 2 salidas  
    constant m : natural := 4;    -- 4 bits de estado (16 estados máximo)

    -- Declaración del componente bajo test
    component PLC
        generic( k : natural := 32;    -- k entradas.
                 p : natural := 32;    -- p salidas.
                 m : natural := 32);   -- 2^m estados
        Port ( x : in std_logic_vector(k-1 downto 0);
               y : out std_logic_vector(p-1 downto 0);
               Trigger : in STD_LOGIC;
               clk : in STD_LOGIC;
               cke : in STD_LOGIC;
               reset : in std_logic);
    end component; 

    -- Señales de test
    signal x_tb : std_logic_vector(k-1 downto 0) := (others => '0');
    signal y_tb : std_logic_vector(p-1 downto 0);
    signal reset_tb : std_logic := '1';
    signal clk_tb : std_logic := '0';
    signal Trigger_tb : std_logic := '0';
    signal cke_tb : std_logic := '1';
    
    -- Control de simulación
    signal sim_finished : boolean := false;
 
begin
    
    -- Instanciación del DUT (Device Under Test)
    DUT: PLC 
        generic map(k => k, p => p, m => m)
        port map(
            x => x_tb,
            y => y_tb,
            reset => reset_tb,
            Trigger => Trigger_tb,
            cke => cke_tb,
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
        
        -- Secuencia básica con CKE habilitado
        cke_tb <= '1';
        
        x_tb <= "00"; wait for 5*CLK_PERIOD;
        x_tb <= "01"; wait for 5*CLK_PERIOD;
        x_tb <= "10"; wait for 5*CLK_PERIOD;
        x_tb <= "11"; wait for 5*CLK_PERIOD;
        x_tb <= "00"; wait for 5*CLK_PERIOD;
        
        -- Cambio a modo Trigger
        cke_tb <= '0';
        x_tb <= "01";
        wait for 3*CLK_PERIOD;
        
        -- Pulsos de trigger
        Trigger_tb <= '1'; wait for CLK_PERIOD;
        Trigger_tb <= '0'; wait for 8*CLK_PERIOD;
        
        x_tb <= "10"; wait for 2*CLK_PERIOD;
        Trigger_tb <= '1'; wait for CLK_PERIOD;
        Trigger_tb <= '0'; wait for 8*CLK_PERIOD;
        
        x_tb <= "11"; wait for 2*CLK_PERIOD;
        Trigger_tb <= '1'; wait for CLK_PERIOD;
        Trigger_tb <= '0'; wait for 8*CLK_PERIOD;
        
        -- Volver a habilitar CKE
        cke_tb <= '1';
        x_tb <= "11"; wait for 4*CLK_PERIOD;
        x_tb <= "00"; wait for 4*CLK_PERIOD;
        x_tb <= "01"; wait for 4*CLK_PERIOD;
        
        -- Reset durante operación
        x_tb <= "10"; wait for 2*CLK_PERIOD;
        reset_tb <= '1'; wait for 2*CLK_PERIOD;
        reset_tb <= '0'; wait for 3*CLK_PERIOD;
        
        -- Secuencia específica de entradas
        cke_tb <= '1';
        x_tb <= "01"; wait for 5*CLK_PERIOD;
        x_tb <= "00"; wait for 8*CLK_PERIOD;
        x_tb <= "01"; wait for 5*CLK_PERIOD;
        x_tb <= "00"; wait for 8*CLK_PERIOD;
        x_tb <= "01"; wait for 5*CLK_PERIOD;
        x_tb <= "00"; wait for 5*CLK_PERIOD;
        x_tb <= "01"; wait for 5*CLK_PERIOD;
        
        -- CKE y Trigger simultáneos
        cke_tb <= '1';
        x_tb <= "10"; wait for CLK_PERIOD;
        Trigger_tb <= '1'; wait for CLK_PERIOD;
        Trigger_tb <= '0'; wait for 5*CLK_PERIOD;
        
        -- Cambios rápidos
        x_tb <= "00"; wait for CLK_PERIOD;
        x_tb <= "01"; wait for CLK_PERIOD;
        x_tb <= "10"; wait for CLK_PERIOD;
        x_tb <= "11"; wait for CLK_PERIOD;
        x_tb <= "00"; wait for CLK_PERIOD;
        x_tb <= "01"; wait for CLK_PERIOD;
        
        wait for 5*CLK_PERIOD;
        
        sim_finished <= true;
        wait;
    end process;

end Behavioral;
