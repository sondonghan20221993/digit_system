--BUTTON_DEBOUNCE.VHD

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY BUTTON_DEBOUNCE IS
GENERIC (
    CLK_FREQ_HZ : INTEGER := 50000000;
    DEBOUNCE_MS : INTEGER := 20
);
PORT (
    CLK       : IN STD_LOGIC;   -- SYSTEM CLOCK
    RESETN    : IN STD_LOGIC;   -- ACTIVE LOW RESET
    BTN_IN    : IN STD_LOGIC;   -- RAW BUTTON INPUT
    BTN_STATE : OUT STD_LOGIC;  -- DEBOUNCED BUTTON LEVEL
    BTN_PULSE : OUT STD_LOGIC   -- 1-CLOCK PULSE ON BUTTON PRESS
);
END BUTTON_DEBOUNCE;

ARCHITECTURE HB OF BUTTON_DEBOUNCE IS
    CONSTANT MAX_COUNT : INTEGER := (CLK_FREQ_HZ / 1000) * DEBOUNCE_MS;

    SIGNAL sync_0      : STD_LOGIC;
    SIGNAL sync_1      : STD_LOGIC;
    SIGNAL stable_btn  : STD_LOGIC;
    SIGNAL prev_btn    : STD_LOGIC;
    SIGNAL counter     : INTEGER RANGE 0 TO MAX_COUNT;
BEGIN

PROCESS(CLK, RESETN)
BEGIN
    IF RESETN = '0' THEN
        sync_0     <= '0';
        sync_1     <= '0';
        stable_btn <= '0';
        prev_btn   <= '0';
        counter    <= 0;
        BTN_PULSE  <= '0';
    ELSIF rising_edge(CLK) THEN
        sync_0 <= BTN_IN;
        sync_1 <= sync_0;

        BTN_PULSE <= '0';

        IF sync_1 = stable_btn THEN
            counter <= 0;
        ELSE
            IF counter = MAX_COUNT THEN
                stable_btn <= sync_1;
                counter <= 0;
            ELSE
                counter <= counter + 1;
            END IF;
        END IF;

        IF prev_btn = '0' AND stable_btn = '1' THEN
            BTN_PULSE <= '1';
        END IF;

        prev_btn <= stable_btn;
    END IF;
END PROCESS;

BTN_STATE <= stable_btn;

END HB;
