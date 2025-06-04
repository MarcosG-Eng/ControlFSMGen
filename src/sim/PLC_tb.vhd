----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.07.2023 18:42:20
-- Design Name: 
-- Module Name: Test_Contador - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Test_Contador is
--  Port ( );
end Test_Contador;

architecture Behavioral of Test_Contador is


component PLC
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
  end component; 
  

 --Declaracion de las señales
 constant Periodo :time:= 8ns;
 constant k    : natural:=2;
 constant p    : natural:=2;
 constant m    : natural:=4;
 signal x :  std_logic_vector(k-1 downto 0);
 signal y :  std_logic_vector(p-1 downto 0);
 signal reset:  std_logic;
 signal clk:  std_logic;
 signal Trigger:std_logic;
 
begin
DUT:PLC         generic map(k=>k,p=>p,m=>m)
                port map(x=>x,y=>y,
                 reset=>reset,Trigger=>Trigger,cke=>'1',clk=>clk);

      
Init:process
     begin
        reset <='1';
        wait for 20ns;
        reset <='0';
        wait;
     end process Init;                       
   
                           
 Reloj:process
      begin
        clk<='0';
        wait for Periodo/2;
        clk<='1';
        wait for Periodo/2;
      end process Reloj;
   
   
   
   
       
x<="01","00" after 30 ns,"01" after 40 ns,"00" after 55 ns, "01" after 65 ns, "00" after 70ns,"01" after 80ns;


end Behavioral;
