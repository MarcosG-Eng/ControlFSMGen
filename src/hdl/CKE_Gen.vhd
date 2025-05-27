----------------------------------------------------------------------------------
-- File: CKE_Gen.vhd
-- Purpose: Generate single clock enable pulse on button press
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CKE_Gen is
    port(
        I     : in  STD_LOGIC;
        O     : out STD_LOGIC;
        reset : in  STD_LOGIC;
        clk   : in  STD_LOGIC
    );
end CKE_Gen;

architecture FSM_Simple of CKE_Gen is
type Estado is ( E_1, E_2, E_3); -- 3 States.           
signal EA, PE : Estado; -- EA is the current state and PE is the next state.
begin


Secuencial: process(clk,reset)
			begin
				if reset='1' then
				    EA<= E_1;
				elsif rising_edge(clk) then
				    EA<= PE;
				end if;
			end process Secuencial;
	
			
Combinacional: process(I,EA)
				begin
					case EA is
					when E_1 =>
						O <= '0';
						if I='0' then
						  PE <= E_1;
						else
						  PE <= E_2;
						end if;
                    when E_2 =>
				        O  <= '1';
				        PE <= E_3;
			        when E_3 =>
				        O <= '0';
				        if I='0' then
				            PE <= E_1;
				        else
				            PE <= E_3;
				        end if;
			        end case;
		end process Combinacional;
end FSM_Simple;
