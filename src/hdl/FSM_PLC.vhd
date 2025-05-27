----------------------------------------------------------------------------------
-- File: FSM_PLC.vhd
-- Purpose: Parametric FSM using truth tables for state transitions and outputs
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.PLC_Types.all;

entity FSM_PLC is
    generic(
        K      : natural := 32;
        P      : natural := 32;
        M      : natural := 32;
        T_DM   : time    := 10 ps;
        T_D    : time    := 10 ps;
        T_SU   : time    := 10 ps;
        T_H    : time    := 10 ps;
        T_W    : time    := 10 ps
    );
    port(
        x         : in  STD_LOGIC_VECTOR(K-1 downto 0);
        y         : out STD_LOGIC_VECTOR(P-1 downto 0);
        StateTbl  : in  FSM_Table(0 to 2**M-1);
        OutputTbl : in  FSM_Table(0 to 2**M-1);
        clk       : in  STD_LOGIC;
        cke       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        Trigger   : in  STD_LOGIC
    );
end FSM_PLC;

architecture Structure of FSM_PLC is

component MUX_PLC is    -- Implements the state transition and output equations in Moore or Mealy style.
    generic( N_Bits_Dir : Natural := 3; 
             T_D        : time    := 10 ps ); -- Delay from direction change to output Q update.
    Port   ( Direccion  : in  STD_LOGIC_VECTOR ( N_Bits_Dir  - 1 downto 0 );
             Dato       : out STD_LOGIC_VECTOR ( N_Bits_Dato - 1 downto 0 );
             Tabla_ROM  : in  FSM_Table( 0 to 2**N_Bits_Dir - 1 ) );
end component MUX_PLC;

component Reg_PLC is    -- State register for the FSM in Moore or Mealy style.
   generic( N_Bits_Reg : integer := 8;
            T_D        : time := 10 ps ); -- Delay from clock edge to output Q update.
   Port   ( D          :  in STD_LOGIC_VECTOR( N_Bits_Reg - 1 downto 0 );
            Q          : out STD_LOGIC_VECTOR( N_Bits_Reg - 1 downto 0 );
            reset      :  in STD_LOGIC;
            cke        :  in STD_LOGIC;
            clk        :  in STD_LOGIC);
end component Reg_PLC;

component Sincronizador is -- Generates the debounce-free CKE with a duration of 1 clock cycle.
    generic ( n     : natural := 4 );
    Port    ( I     : in STD_LOGIC;
              CKE   : out STD_LOGIC;
              reset : in STD_LOGIC;
              clk   : in STD_LOGIC);
end component Sincronizador;

signal CurrentState       : STD_LOGIC_VECTOR( M - 1 downto 0 );
signal NextState          : STD_LOGIC_VECTOR( M - 1 downto 0 );
signal FormattedStates    : FSM_Table( 0 to 2**K - 1 );
signal FormattedOutputs    : FSM_Table( 0 to 2**K - 1 ); -- Only used for Mealy.
signal MuxOutput          : STD_LOGIC_VECTOR( N_Bits_Dato - 1 downto 0 ); -- Next state right-justified with zeros.
signal Output              : STD_LOGIC_VECTOR( N_Bits_Dato - 1 downto 0 ); -- Output right-justified with zeros.

signal IntermediateData1 : STD_LOGIC_VECTOR( N_Bits_Dato - 1 downto 0 );
signal IntermediateData2 : STD_LOGIC_VECTOR( N_Bits_Dato - 1 downto 0 ); -- Only used for Mealy.

signal TriggerPos  : STD_LOGIC; -- Filtered and debounced Trigger, with the width of one clock cycle.
signal ClockEnable : STD_LOGIC; -- Processed trigger and cke signal with an OR.


begin
--
-- Basic range and timing checks: NOT SYNTHESIZABLE!
--

Check_2kxm : process
                begin
                    assert( 2**K * M <= N_Bits_Dato )    report " Size restriction not met!" severity failure;
                    wait;
                end process Check_2kxm;

Check_2kxp : process
                begin
                    assert( 2**K * P <= N_Bits_Dato )    report " Size restriction not met!" severity failure;
                    wait;
                end process Check_2kxp;

Check_TSUH: process -- Passive process for Setup and Hold time verification.
                begin
                    wait until rising_edge(clk);
                    assert (NextState'Stable( T_SU ) ) report " Setup time not met!" severity failure;
	                wait for T_H;
                    assert (NextState'Stable( T_H  ) ) report " Hold time not met!"  severity failure;
end process Check_TSUH;

Check_TW:   process -- Passive process for pulse width (Width) verification.
                begin
                    wait until rising_edge(clk); --IMPORTANT! THIS LINE REPLACES THE NEXT ONE FOR SYNTHESIS.(IT IS REALLY EQUIVALENT)
--                    wait until NextState'Event; -- D represents the signal to be measured (std_Logic_Vector).
                    assert (NextState'Delayed'Stable( T_W ) ) report " Pulse width not met!" severity Error;
                end process Check_TW;



-- FSM Processes.                
Synchronization: Sincronizador
                generic map( 4 ) -- The synchronizer has 32 stages in the FIR (Finite Impulse Response) filter.
                port    map( I     => Trigger,
                             CKE   => TriggerPos,
                             reset => reset,
                             clk   => clk );
                             
ClockGeneration: ClockEnable <= TriggerPos or cke;

StateRegister:   Reg_PLC -- State register of the FSM.
                generic map( M, 10 ps )
                Port    map( D     => NextState,
                             Q     => CurrentState,
                             reset => reset,
                             cke   => ClockEnable,
                             clk   => clk);


--
-- State transition equation in Mealy and Moore styles.
--
                                                                                                                         
-- right-justifies with zero padding, m bits of the State to N_Bits_Dato bits of the mux data.
Assign_MUX : process( IntermediateData1 )
    begin
        for i in 0 to 2**K - 1 loop
            FormattedStates( i ) <= std_logic_vector( resize( unsigned( IntermediateData1( M * ( i + 1 ) - 1 downto M * i ) ), N_Bits_Dato ) );
        end loop;
    end process Assign_MUX;
    
TransitionEquation_1: MUX_PLC generic map( M, T_DM ) -- Selects all possible next states from the current state.
                                  Port    map( Direccion => CurrentState,
                                               Dato      => IntermediateData1,
                                               Tabla_ROM => StateTbl);
TransitionEquation_2: MUX_PLC generic map( K, T_DM ) -- Selects the next state from the current input.
                                  Port    map( Direccion => x,
                                               Dato      => MuxOutput,
                                               Tabla_ROM => FormattedStates);
                                               
Assign_NextState: NextState <= MuxOutput( M - 1 downto 0 );  -- adjusts from N_Bits_Dato bits of the mux data to m bits of the state.  
                                                                                         
--
-- Moore style output equation:
-- Uncomment for Moore, comment for Mealy:
     


                                                                                                                
MooreOutputEquation: MUX_PLC generic map( M, T_DM ) -- Selects the output from the current state.
                                  Port    map( Direccion => CurrentState,
                                               Dato      => Output,
                                               Tabla_ROM => OutputTbl);    
Y <= Output( P - 1 downto 0 );


--
--End Uncomment for Moore, comment for Mealy
--
                       
--
-- Mealy style output equation:
-- Uncomment for Mealy, comment for Moore:
--

-- right-justifies with zero padding, p bits of the output to N_Bits_Dato bits of the mux data.


--Assign_MUX_Mealy : process( IntermediateData2 )
--    begin
--        for i in 0 to 2**K - 1 loop
--            FormattedOutputs( i ) <= std_logic_vector( resize( unsigned( IntermediateData2( P * ( i + 1 ) - 1 downto P * i ) ), N_Bits_Dato ) );
--        end loop;
--    end process Assign_MUX_Mealy;
                                                                      
--MealyOutputEquation_1: MUX_PLC generic map( M, T_DM ) -- Selects all possible outputs from the current state.
--                                  Port    map( Direccion => CurrentState,
--                                               Dato      => IntermediateData2,
--                                               Tabla_ROM => OutputTbl);
--MealyOutputEquation_2: MUX_PLC generic map( K, T_DM ) -- Selects the output from the current input.
--                                  Port    map( Direccion => x,
--                                               Dato      => Output,
--                                               Tabla_ROM => FormattedOutputs);
--Y <= Output( P - 1 downto 0 );     


                  
--
--End Uncomment for Mealy, comment for Moore
--
  
  
                                                                      
end Structure;
