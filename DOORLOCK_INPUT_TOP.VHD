--DOORLOCK_INPUT_TOP.VHD

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY DOORLOCK_INPUT_TOP IS
PORT (
    CLK         : IN  STD_LOGIC;                       -- SYSTEM CLOCK
    RESETN      : IN  STD_LOGIC;                       -- ACTIVE LOW RESET
    BUTTON_IN   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);   -- BUTTON_SW1 ~ SWF
    DIP_IN      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);    -- BUS_SW1 ~ SW8

    LED_OUT     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);    -- INPUT CHECK LED
    KEY_VALID   : OUT STD_LOGIC;                       -- VALID KEY INPUT
    KEY_CODE    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    -- ENCODED KEY VALUE
    PASS_OUT    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);   -- 4-DIGIT PASSWORD BUFFER
    DIGIT_COUNT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);    -- STORED DIGIT COUNT
    FULL        : OUT STD_LOGIC                        -- BUFFER FULL FLAG
);
END DOORLOCK_INPUT_TOP;

ARCHITECTURE HB OF DOORLOCK_INPUT_TOP IS

    COMPONENT BUTTON_DEBOUNCE
    GENERIC (
        CLK_FREQ_HZ : INTEGER := 50000000;
        DEBOUNCE_MS : INTEGER := 20
    );
    PORT (
        CLK       : IN STD_LOGIC;
        RESETN    : IN STD_LOGIC;
        BTN_IN    : IN STD_LOGIC;
        BTN_STATE : OUT STD_LOGIC;
        BTN_PULSE : OUT STD_LOGIC
    );
    END COMPONENT;

    COMPONENT KEY_ENCODER
    PORT (
        KEY_IN     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        KEY_VALID  : OUT STD_LOGIC;
        KEY_CODE   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        KEY_IS_NUM : OUT STD_LOGIC;
        KEY_IS_FN  : OUT STD_LOGIC
    );
    END COMPONENT;

    COMPONENT PASS_BUFFER
    PORT (
        CLK         : IN  STD_LOGIC;
        RESETN      : IN  STD_LOGIC;
        CLEAR       : IN  STD_LOGIC;
        STORE_EN    : IN  STD_LOGIC;
        DIGIT_IN    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        PASS_OUT    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        DIGIT_COUNT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        FULL        : OUT STD_LOGIC
    );
    END COMPONENT;

    SIGNAL btn_state  : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL btn_pulse  : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL key_valid_s  : STD_LOGIC;
    SIGNAL key_is_num_s : STD_LOGIC;
    SIGNAL key_is_fn_s  : STD_LOGIC;
    SIGNAL key_code_s   : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL clear_s      : STD_LOGIC;
    SIGNAL store_en_s   : STD_LOGIC;

BEGIN

    DEB_0 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(0),  btn_state(0),  btn_pulse(0));
    DEB_1 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(1),  btn_state(1),  btn_pulse(1));
    DEB_2 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(2),  btn_state(2),  btn_pulse(2));
    DEB_3 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(3),  btn_state(3),  btn_pulse(3));
    DEB_4 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(4),  btn_state(4),  btn_pulse(4));
    DEB_5 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(5),  btn_state(5),  btn_pulse(5));
    DEB_6 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(6),  btn_state(6),  btn_pulse(6));
    DEB_7 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(7),  btn_state(7),  btn_pulse(7));
    DEB_8 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(8),  btn_state(8),  btn_pulse(8));
    DEB_9 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(9),  btn_state(9),  btn_pulse(9));
    DEB_10 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(10), btn_state(10), btn_pulse(10));
    DEB_11 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(11), btn_state(11), btn_pulse(11));
    DEB_12 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(12), btn_state(12), btn_pulse(12));
    DEB_13 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(13), btn_state(13), btn_pulse(13));
    DEB_14 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(14), btn_state(14), btn_pulse(14));
    DEB_15 : BUTTON_DEBOUNCE PORT MAP (CLK, RESETN, BUTTON_IN(15), btn_state(15), btn_pulse(15));

    ENC_0 : KEY_ENCODER
    PORT MAP (
        KEY_IN     => btn_pulse,
        KEY_VALID  => key_valid_s,
        KEY_CODE   => key_code_s,
        KEY_IS_NUM => key_is_num_s,
        KEY_IS_FN  => key_is_fn_s
    );

    -- A(1010): store current digit, C(1100): clear input buffer
    store_en_s <= key_valid_s AND key_is_num_s;
    clear_s    <= '1' WHEN (key_valid_s = '1' AND key_is_fn_s = '1' AND key_code_s = "1100") ELSE '0';

    BUF_0 : PASS_BUFFER
    PORT MAP (
        CLK         => CLK,
        RESETN      => RESETN,
        CLEAR       => clear_s,
        STORE_EN    => store_en_s,
        DIGIT_IN    => key_code_s,
        PASS_OUT    => PASS_OUT,
        DIGIT_COUNT => DIGIT_COUNT,
        FULL        => FULL
    );

    -- Upper 4 LEDs show debounced button group activity, lower 4 LEDs show lower DIP state.
    LED_OUT(7) <= btn_state(15) OR btn_state(14) OR btn_state(13) OR btn_state(12);
    LED_OUT(6) <= btn_state(11) OR btn_state(10) OR btn_state(9) OR btn_state(8);
    LED_OUT(5) <= btn_state(7) OR btn_state(6) OR btn_state(5) OR btn_state(4);
    LED_OUT(4) <= btn_state(3) OR btn_state(2) OR btn_state(1) OR btn_state(0);
    LED_OUT(3 DOWNTO 0) <= DIP_IN(3 DOWNTO 0);

    KEY_VALID <= key_valid_s;
    KEY_CODE  <= key_code_s;

END HB;
