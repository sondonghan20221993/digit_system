--PASS_BUFFER.VHD

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY PASS_BUFFER IS
PORT (
    CLK         : IN  STD_LOGIC;                      -- SYSTEM CLOCK
    RESETN      : IN  STD_LOGIC;                      -- ACTIVE LOW RESET
    CLEAR       : IN  STD_LOGIC;                      -- BUFFER CLEAR PULSE
    STORE_EN    : IN  STD_LOGIC;                      -- STORE ENABLE PULSE
    DIGIT_IN    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);  -- 4-BIT NUMBER INPUT

    PASS_OUT    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- 4-DIGIT BUFFER
    DIGIT_COUNT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);  -- STORED DIGIT COUNT
    FULL        : OUT STD_LOGIC                       -- 4 DIGITS STORED
);
END PASS_BUFFER;

ARCHITECTURE HB OF PASS_BUFFER IS
    SIGNAL pass_reg   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL count_reg  : UNSIGNED(2 DOWNTO 0);
BEGIN

PROCESS(CLK, RESETN)
BEGIN
    IF RESETN = '0' THEN
        pass_reg  <= (OTHERS => '0');
        count_reg <= (OTHERS => '0');
    ELSIF rising_edge(CLK) THEN
        IF CLEAR = '1' THEN
            pass_reg  <= (OTHERS => '0');
            count_reg <= (OTHERS => '0');
        ELSIF STORE_EN = '1' THEN
            -- Shift left by 4 bits and store the new digit in the lowest 4 bits.
            pass_reg <= pass_reg(11 DOWNTO 0) & DIGIT_IN;

            IF count_reg < 4 THEN
                count_reg <= count_reg + 1;
            END IF;
        END IF;
    END IF;
END PROCESS;

PASS_OUT <= pass_reg;
DIGIT_COUNT <= STD_LOGIC_VECTOR(count_reg);
FULL <= '1' WHEN count_reg = 4 ELSE '0';

END HB;
