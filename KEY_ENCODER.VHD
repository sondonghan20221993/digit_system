--KEY_ENCODER.VHD

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY KEY_ENCODER IS
PORT (
    KEY_IN     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);  -- ONE-PULSE BUTTON INPUT
    KEY_VALID  : OUT STD_LOGIC;                      -- VALID KEY FLAG
    KEY_CODE   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);   -- ENCODED KEY VALUE
    KEY_IS_NUM : OUT STD_LOGIC;                      -- '1' WHEN NUMBER KEY
    KEY_IS_FN  : OUT STD_LOGIC                       -- '1' WHEN FUNCTION KEY
);
END KEY_ENCODER;

ARCHITECTURE HB OF KEY_ENCODER IS
BEGIN

PROCESS(KEY_IN)
BEGIN
    KEY_VALID  <= '1';
    KEY_IS_NUM <= '0';
    KEY_IS_FN  <= '0';
    KEY_CODE   <= "0000";

    CASE KEY_IN IS
        -- Number keys: BUTTON_SW1 ~ BUTTON_SWA => 0 ~ 9
        WHEN "0000000000000001" =>
            KEY_CODE   <= "0000";  -- 0
            KEY_IS_NUM <= '1';
        WHEN "0000000000000010" =>
            KEY_CODE   <= "0001";  -- 1
            KEY_IS_NUM <= '1';
        WHEN "0000000000000100" =>
            KEY_CODE   <= "0010";  -- 2
            KEY_IS_NUM <= '1';
        WHEN "0000000000001000" =>
            KEY_CODE   <= "0011";  -- 3
            KEY_IS_NUM <= '1';
        WHEN "0000000000010000" =>
            KEY_CODE   <= "0100";  -- 4
            KEY_IS_NUM <= '1';
        WHEN "0000000000100000" =>
            KEY_CODE   <= "0101";  -- 5
            KEY_IS_NUM <= '1';
        WHEN "0000000001000000" =>
            KEY_CODE   <= "0110";  -- 6
            KEY_IS_NUM <= '1';
        WHEN "0000000010000000" =>
            KEY_CODE   <= "0111";  -- 7
            KEY_IS_NUM <= '1';
        WHEN "0000000100000000" =>
            KEY_CODE   <= "1000";  -- 8
            KEY_IS_NUM <= '1';
        WHEN "0000001000000000" =>
            KEY_CODE   <= "1001";  -- 9
            KEY_IS_NUM <= '1';

        -- Function keys: BUTTON_SWB ~ BUTTON_SWF
        WHEN "0000010000000000" =>
            KEY_CODE <= "1010";    -- ENTER / CHECK
            KEY_IS_FN <= '1';
        WHEN "0000100000000000" =>
            KEY_CODE <= "1011";    -- CANCEL
            KEY_IS_FN <= '1';
        WHEN "0001000000000000" =>
            KEY_CODE <= "1100";    -- CHANGE
            KEY_IS_FN <= '1';
        WHEN "0010000000000000" =>
            KEY_CODE <= "1101";    -- DELETE
            KEY_IS_FN <= '1';
        WHEN "0100000000000000" =>
            KEY_CODE <= "1110";    -- CLEAR / RESET INPUT
            KEY_IS_FN <= '1';
        WHEN "1000000000000000" =>
            KEY_CODE <= "1111";    -- RESERVED
            KEY_IS_FN <= '1';

        WHEN OTHERS =>
            KEY_VALID <= '0';
    END CASE;
END PROCESS;

END HB;
