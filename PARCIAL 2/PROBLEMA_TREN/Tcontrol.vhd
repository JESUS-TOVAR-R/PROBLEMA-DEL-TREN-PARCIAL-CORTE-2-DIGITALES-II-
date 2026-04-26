--========================================================
-- Controlador de Trenes - FSM
-- Basado en: Electric Train Controller
--========================================================

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Tcontrol IS
PORT(
    reset   : IN  STD_LOGIC;
    clock   : IN  STD_LOGIC;
    sensor1 : IN  STD_LOGIC;
    sensor2 : IN  STD_LOGIC;
    sensor3 : IN  STD_LOGIC;
    sensor4 : IN  STD_LOGIC;
    sensor5 : IN  STD_LOGIC;

    switch1 : OUT STD_LOGIC;
    switch2 : OUT STD_LOGIC;
    switch3 : OUT STD_LOGIC;

    dirA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    dirB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
);
END Tcontrol;

--========================================================

ARCHITECTURE Behavioral OF Tcontrol IS

-- Estados de la FSM
TYPE STATE_TYPE IS (ABout, Ain, Bin, Astop, Bstop);
SIGNAL state, next_state : STATE_TYPE;

-- Señales auxiliares
SIGNAL sensor12, sensor13, sensor24 : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN

--========================================================
-- COMBINACIÓN DE SENSORES
--========================================================
sensor12 <= sensor1 & sensor2;
sensor13 <= sensor1 & sensor3;
sensor24 <= sensor2 & sensor4;

--========================================================
-- REGISTRO DE ESTADO (SINCRONO)
--========================================================
PROCESS(clock, reset)
BEGIN
    IF reset = '1' THEN
        state <= ABout;
    ELSIF rising_edge(clock) THEN
        state <= next_state;
    END IF;
END PROCESS;

--========================================================
-- LÓGICA DE TRANSICIÓN (COMBINACIONAL)
--========================================================
PROCESS(state, sensor1, sensor2, sensor3, sensor4, sensor12, sensor13, sensor24)
BEGIN

    CASE state IS

        --====================================
        WHEN ABout =>
            CASE sensor12 IS
                WHEN "00" => next_state <= ABout;
                WHEN "01" => next_state <= Bin;
                WHEN "10" => next_state <= Ain;
                WHEN "11" => next_state <= Ain;
                WHEN OTHERS => next_state <= ABout;
            END CASE;

        --====================================
        WHEN Ain =>
            CASE sensor24 IS
                WHEN "00" => next_state <= Ain;
                WHEN "01" => next_state <= ABout;
                WHEN "10" => next_state <= Bstop;
                WHEN "11" => next_state <= ABout;
                WHEN OTHERS => next_state <= ABout;
            END CASE;

        --====================================
        WHEN Bin =>
            CASE sensor13 IS
                WHEN "00" => next_state <= Bin;
                WHEN "01" => next_state <= ABout;
                WHEN "10" => next_state <= Astop;
                WHEN "11" => next_state <= ABout;
                WHEN OTHERS => next_state <= ABout;
            END CASE;

        --====================================
        WHEN Astop =>
            IF sensor3 = '1' THEN
                next_state <= Ain;
            ELSE
                next_state <= Astop;
            END IF;

        --====================================
        WHEN Bstop =>
            IF sensor4 = '1' THEN
                next_state <= Bin;
            ELSE
                next_state <= Bstop;
            END IF;

    END CASE;

END PROCESS;

--========================================================
-- SALIDAS (MOORE)
--========================================================

-- Switch 3 fijo
switch3 <= '0';

-- Switch 1
WITH state SELECT
switch1 <= '0' WHEN ABout,
           '0' WHEN Ain,
           '1' WHEN Bin,
           '1' WHEN Astop,
           '0' WHEN Bstop;

-- Switch 2
WITH state SELECT
switch2 <= '0' WHEN ABout,
           '0' WHEN Ain,
           '1' WHEN Bin,
           '1' WHEN Astop,
           '0' WHEN Bstop;

-- Dirección Tren A
WITH state SELECT
dirA <= "01" WHEN ABout,
        "01" WHEN Ain,
        "01" WHEN Bin,
        "00" WHEN Astop,
        "01" WHEN Bstop;

-- Dirección Tren B
WITH state SELECT
dirB <= "01" WHEN ABout,
        "01" WHEN Ain,
        "01" WHEN Bin,
        "01" WHEN Astop,
        "00" WHEN Bstop;

END Behavioral;