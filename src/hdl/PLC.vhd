----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.07.2023 12:34:48
-- Design Name: 
-- Module Name: PLC - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.Tipos_FSM_PLC.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PLC is
    generic(   k    : natural := 32;    -- k entradas.
            p    : natural := 32;    -- p salidas.
            m    : natural := 32);   --2^m estados
    Port (
    
        x:in std_logic_vector(k-1 downto 0);
        y:out std_logic_vector(p-1 downto 0);
        Trigger : in STD_LOGIC;
        clk     : in STD_LOGIC;
        cke     : in STD_LOGIC;
        reset   : in std_logic);
              
--        sensores:in std_logic_vector(1 downto 0);
--        modo: in STD_LOGIC;
--        motor : out std_logic_vector(2 downto 0);
--        sw: in std_logic_vector(2 downto 0));

end PLC;

architecture Comportamiento of PLC is


--señales intermedias





    component FSM_PLC is

        generic(k    : natural := 32;    -- k entradas.
                p    : natural := 32;    -- p salidas.
                m    : natural := 32;    -- m biestables. (Hasta 16 estados)
                T_DM : time    := 10 ps; -- Tiempo de retardo desde el cambio de dirección del MUX hasta la actualización de la salida Q.
                T_D  : time    := 10 ps; -- Tiempo de retardo desde el flanco activo del reloj hasta la actualización de la salida Q.
                T_SU : time    := 10 ps; -- Tiempo de Setup.
                T_H  : time    := 10 ps; -- Tiempo de Hold.
                T_W  : time    := 10 ps); -- Anchura de pulso.
        port   (   x : in  STD_LOGIC_VECTOR( k - 1 downto 0 );     -- x es el bus de entrada.
             y : out STD_LOGIC_VECTOR( p - 1 downto 0 );     -- y es el bus de salida.
             Tabla_De_Estado : in Tabla_FSM( 0 to 2**m - 1 );  -- Contiene la Tabla de Estado estilo Moore: Z(n+1)=T1(Z(n),x(n))
             Tabla_De_Salida : in Tabla_FSM( 0 to 2**m - 1 );  -- Contiene la Tabla de Salida estilo Moore: Y(n  )=T2(Z(n))
             clk     : in STD_LOGIC;   -- La señal de reloj.
             cke     : in STD_LOGIC;   -- La señal de habilitación de avance: si vale '1' el autómata avanza a ritmo de clk y si vale '0' manda Trigger.              
             reset   : in STD_LOGIC;   -- La señal de inicialización.
             Trigger : in STD_LOGIC ); -- La señal de disparo (single shot) asíncrono y posíblemente con rebotes para hacer un avance único. Ha de llevar un sincronizador.
    end component FSM_PLC;



    constant TablaE :Tabla_FSM(0 to 2**m-1):=
    (x"00000001",
                                                     x"00000021",
                                                     x"00000023",
                                                     x"00000043",
                                                     x"00000045",
                                                     x"00000065",
                                                     x"00000066",
                                                     (others => '0'),
                                                     (others => '0'),
                                                     (others => '0'),
                                                     (others => '0'),
                                                     (others => '0'),
                                                     (others => '0'),
                                                     (others => '0'),
                                                     (others => '0'),
                                                     (others => '0'));

    constant TablaS :Tabla_FSM(0 to 2**m-1):=
 (x"00000000",
                                                     x"00000011",
                                                     x"00000011",
                                                     x"00000022",
                                                     x"00000022",
                                                     x"00000033",
                                                     x"00000033",
                                                     (others => '0'),
                                                     (others => '0'),
                                                     (others => '0'),
                                                     (others => '0'),
                                                     (others => '0'),
                                                     (others => '0'),
                                                     (others => '0'),
                                                     (others => '0'),
                                                     (others => '0'));


begin


    FSM:FSM_PLC
        generic map(k=>k,p=>p,m=>m)
        port  map(x=>x,y=>y,Tabla_de_estado=>TablaE,Tabla_de_Salida=>TablaS,clk=>clk,cke=>'1',reset=>reset,Trigger=>Trigger);

  

end Comportamiento;