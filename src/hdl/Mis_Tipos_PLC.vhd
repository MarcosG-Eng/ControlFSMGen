----------------------------------------------------------------------------------
-- File: PLC_Types.vhd
-- Purpose: Global types, constants, and parameters for PLC FSM project
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package PLC_Types is
    -- Global parameterization for the PLC FSM system
    constant DATA_WIDTH   : natural := 32; -- Data width for FSM tables
    constant K_MAX        : natural := 3;  -- Max number of inputs
    constant P_MAX        : natural := 4;  -- Max number of outputs
    constant M_MAX        : natural := 4;  -- Max number of state bits (up to 16 states)

    -- FSM Table type: array of vectors
    type FSM_Table is array(natural range <>) of STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
end PLC_Types;
