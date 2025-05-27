----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.07.2023 23:57:19
-- Design Name: 
-- Module Name: SentidoPLC - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: FSM for direction control using truth tables
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
use IEEE.NUMERIC_STD.ALL;
use work.PLC_Types.all;

entity SentidoPLC is
    generic(
        K : natural := 32;
        P : natural := 32;
        M : natural := 32
    );
    port(
        x      : in  STD_LOGIC_VECTOR(K-1 downto 0);
        y      : out STD_LOGIC_VECTOR(P-1 downto 0);
        Trigger: in  STD_LOGIC;
        clk    : in  STD_LOGIC;
        cke    : in  STD_LOGIC;
        reset1 : in  STD_LOGIC
    );
end SentidoPLC;

architecture Behavioral of SentidoPLC is


    -- Intermediate signals





    component FSM_PLC is

        generic(k    : natural := 32;    -- k inputs.
                p    : natural := 32;    -- p outputs.
                m    : natural := 32;    -- m flip-flops. (Up to 16 states)
                T_DM : time    := 10 ps; -- Delay time from MUX direction change to Q output update.
                T_D  : time    := 10 ps; -- Delay time from active clock edge to Q output update.
                T_SU : time    := 10 ps; -- Setup time.
                T_H  : time    := 10 ps; -- Hold time.
                T_W  : time    := 10 ps); -- Pulse width.

        port   (   x : in  STD_LOGIC_VECTOR( k - 1 downto 0 );     -- x is the input bus.
             y : out STD_LOGIC_VECTOR( p - 1 downto 0 );     -- y is the output bus.
             Tabla_De_Estado : in Tabla_FSM( 0 to 2**m - 1 );  -- Contains the Moore-style State Table: Z(n+1)=T1(Z(n),x(n))
             Tabla_De_Salida : in Tabla_FSM( 0 to 2**m - 1 );  -- Contains the Moore-style Output Table: Y(n  )=T2(Z(n))
             clk     : in STD_LOGIC;   -- Clock signal.
             cke    : in STD_LOGIC;   -- Enable signal: if '1' the FSM advances with clk, if '0' Trigger controls it.              
             reset : in STD_LOGIC;   -- Reset signal.
             Trigger : in STD_LOGIC ); -- Trigger signal (single shot), asynchronous and possibly with bounces, for single-step advance. Must be synchronized.
    end component FSM_PLC;


    
    constant TablaE :Tabla_FSM(0 to 2**m-1):=
  (x"00000310",
                                                     x"00002111",
                                                     x"00002310",
                                                     x"00004333",
                                                     x"00004310",
                                                     (others => '0'),
                                                     (others => '0'),
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
                                                     x"00002222",
                                                     x"00002222",
                                                     x"00001111",
                                                     x"00001111",
                                                     (others => '0'),
                                                     (others => '0'),
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
        port  map(x=>x,y=>y,Tabla_de_estado=>TablaE,Tabla_de_Salida=>TablaS,clk=>clk,cke=>'1',reset=>reset1,Trigger=>Trigger);



end Behavioral;
