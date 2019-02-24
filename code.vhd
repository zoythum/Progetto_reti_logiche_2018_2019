----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.02.2019 20:06:21
-- Design Name: 
-- Module Name: code - Behavioral
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
use IEEE.STD_LOGIC_ARITH;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity code is
    port (
        i_clk : in std_logic;
        i_start : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
    );

end code;

architecture Behavioral of code is
    --- variabili
    type eg_state_type is
        (START, RAM_READ, DIST_CALC, DIST_LOWER, DIST_EQUAL, DIST_HIGHER, COMPLETED);
        -- START: inizio, stato di reset
        -- RAM_READ: legge le coordinate del centroide attuale
        -- DIST_CALC: calcola la distanza tra il punto e il centroide attuale
        -- DIST_LOWER: ha trovato un centroide con distanza minore della minima attuale
        -- DIST_EQUAL: ha trovato un centroide con distanza uguale della attuale attuale
        -- DIST_HIGHER: ha trovato un centroide con distanza maggiore della minima attuale
        -- COMPLETED: computazione completata
        
    signal
        state_cur, state_next: eg_state_type;
                
begin
    --- codice
    process (i_clk, i_rst)
        begin
            if (i_rst='1') then
              state_cur <= START;
            elsif (rising_edge(i_clk)) then
              state_cur <= state_next;
            end if;
       end process;
       
    process (state_cur, state_next)
        variable current_x: std_logic_vector(7 downto 0);         -- coordinata x del centroide attualmente considerato 
        variable current_y: std_logic_vector(7 downto 0);         -- coordinata y del centroide attualmente considerato
        variable pos_x: std_logic_vector(7 downto 0);             -- coordinata x della posizione di partenza
        variable pos_y: std_logic_vector(7 downto 0);             -- coordinata y della posizione di partenza
        variable min_distance: integer range 0 to 512 := 512;     -- l'attuale distanza minima trovata
        
        begin
        
            case state_cur is
                when START =>
                    -- codice
                when RAM_READ =>
                    -- codice
                when DIST_CALC =>
                    -- codice
                when DIST_LOWER =>
                    -- codice
                when DIST_EQUAL =>
                    -- codice
                when DIST_HIGHER =>
                    -- codice
                when COMPLETED =>
                    -- codice
            end case;
        end process;

end Behavioral;
