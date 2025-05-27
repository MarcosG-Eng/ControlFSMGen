----------------------------------------------------------------------------------
-- File: Control_Unit.vhd
-- Purpose: Top-level control unit for PLC FSM system (Professional Redesign)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.PLC_Types.all;

entity Control_Unit is
    generic(
        K : natural := 2;
        P : natural := 2;
        M : natural := 4
    );
    Port(
        Trigger : in STD_LOGIC; -- Signal to activate pulse, clock is always active
        clk     : in STD_LOGIC; -- Clock with a period of 8ns (125MHz)
        sensor  : in std_logic_vector(1 downto 0); -- 2 photoelectric sensors from the table
        motor   : out std_logic_vector(2 downto 0); -- Frequency inverter signals for the motor [0]lock,[1] movement,[2]direction
        modo    : in std_logic; -- Switch to select between manual mode or FSM design
        sw      : in std_logic_vector(2 downto 0); -- Switches to manually operate the table
        E_Stop  : in std_logic; -- Emergency Stop button
        led1    : out std_logic;
        led2    : out std_logic;
        led3    : out std_logic;
        led4    : out std_logic;
        resetP  : in std_logic
    );
end Control_Unit;

architecture Behavioral of Control_Unit is
    -- Internal signals
    signal x1, x2 : std_logic_vector(K-1 downto 0);
    signal y1, y2 : std_logic_vector(P-1 downto 0);
    signal reset, reset2, Pos_resetP, Pos_E_Stop : std_logic;
    signal Parada : std_logic;
    signal cuenta1, cuenta2 : integer := 0;
    signal counter : integer := 0;
    signal reset_counter : natural := 0;

    -- FSM States for main control
    type state_type is (IDLE, AUTO, MANUAL, EMERGENCY_STOP);
    signal state, next_state : state_type := IDLE;

    -- Component declarations
    component Sincronizador is
        generic ( n : natural := 4 );
        Port ( I : in STD_LOGIC;
               CKE : out STD_LOGIC;
               reset : in STD_LOGIC;
               clk : in STD_LOGIC);
    end component;

    component PLC is
        generic(
            K : natural := 2;
            P : natural := 2;
            M : natural := 4
        );
        Port (
            x : in std_logic_vector(K-1 downto 0);
            y : out std_logic_vector(P-1 downto 0);
            Trigger : in STD_LOGIC;
            clk : in STD_LOGIC;
            cke : in STD_LOGIC;
            reset : in std_logic
        );
    end component;

    component SentidoPLC is
        generic(
            K : natural := 2;
            P : natural := 2;
            M : natural := 4
        );
        Port (
            x : in std_logic_vector(K-1 downto 0);
            y : out std_logic_vector(P-1 downto 0);
            Trigger : in STD_LOGIC;
            clk : in STD_LOGIC;
            cke : in STD_LOGIC;
            reset1 : in std_logic
        );
    end component;

begin
    -- Debounce and synchronize reset and emergency stop
    Sincronizacion_reset: Sincronizador
        generic map(4)
        port map(I => resetP, CKE => Pos_resetP, reset => '0', clk => clk);

    Sincronizacion_E_STOP: Sincronizador
        generic map(4)
        port map(I => E_Stop, CKE => Pos_E_Stop, reset => Pos_resetP, clk => clk);

    -- Assign input signals
    x2 <= sensor & (K-1 downto 2 => '0') when K > 2 else sensor;
    x1(0) <= sensor(0) or sensor(1); -- Piece counting FSM input is an OR de los sensores
    x1(K-1 downto 1) <= (others => '0') when K > 1 else (others => '0');
    x2(K-1 downto 1) <= (others => '0') when K > 1 else (others => '0');

    -- PLC FSM instantiation (piece counter)
    Contador: PLC
        generic map(K => K, P => P, M => M)
        port map(x => x1, y => y1, Trigger => Trigger, clk => clk, cke => '1', reset => reset);

    -- Direction FSM instantiation
    Sentido: SentidoPLC
        generic map(K => K, P => P, M => M)
        port map(x => x2, y => y2, Trigger => Trigger, clk => clk, cke => '1', reset1 => Pos_resetP);

    -- Main FSM: Control logic
    process(clk, Pos_resetP)
    begin
        if Pos_resetP = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    process(state, modo, Pos_E_Stop)
    begin
        next_state <= state;
        case state is
            when IDLE =>
                if Pos_E_Stop = '1' then
                    next_state <= EMERGENCY_STOP;
                elsif modo = '0' then
                    next_state <= AUTO;
                else
                    next_state <= MANUAL;
                end if;
            when AUTO =>
                if Pos_E_Stop = '1' then
                    next_state <= EMERGENCY_STOP;
                elsif modo = '1' then
                    next_state <= MANUAL;
                end if;
            when MANUAL =>
                if Pos_E_Stop = '1' then
                    next_state <= EMERGENCY_STOP;
                elsif modo = '0' then
                    next_state <= AUTO;
                end if;
            when EMERGENCY_STOP =>
                if Pos_E_Stop = '0' then
                    next_state <= IDLE;
                end if;
            when others =>
                next_state <= IDLE;
        end case;
    end process;

    -- Output logic
    process(state, y1, y2, sw)
    begin
        -- Default assignments
        motor <= (others => '0');
        led1 <= '0';
        led2 <= '0';
        led3 <= y2(1);
        led4 <= y2(0);
        case state is
            when AUTO =>
                motor(2 downto 1) <= y2(1 downto 0); -- direction and movement from FSM
                motor(0) <= y1(0); -- lock from FSM
                led1 <= '1';
            when MANUAL =>
                motor <= sw;
                led2 <= '1';
            when EMERGENCY_STOP =>
                motor <= (others => '0');
            when others =>
                motor <= (others => '0');
        end case;
    end process;

    -- Reset logic for PLC
    reset <= Pos_resetP or reset2;

end Behavioral;