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
        (START, RAM_READ, RAM_ACK, DIST_CALC, DIST_LOWER, DIST_EQUAL, DIST_HIGHER, COMPLETED);
        -- START: inizio, stato di reset
        -- RAM_READ: chiede alla ram
        -- RAM_ACK: legge la risposta della ram
        -- DIST_CALC: calcola la distanza tra il punto e il centroide attuale
        -- DIST_LOWER: ha trovato un centroide con distanza minore della minima attuale
        -- DIST_EQUAL: ha trovato un centroide con distanza uguale della attuale attuale
        -- DIST_HIGHER: ha trovato un centroide con distanza maggiore della minima attuale
        -- COMPLETED: computazione completata
        
    signal state_cur: eg_state_type;
    signal current_x: std_logic_vector(7 downto 0);         -- coordinata x del centroide attualmente considerato 
    signal current_y: std_logic_vector(7 downto 0);         -- coordinata y del centroide attualmente considerato
    signal pos_x: std_logic_vector(7 downto 0);             -- coordinata x della posizione di partenza
    signal pos_y: std_logic_vector(7 downto 0);             -- coordinata y della posizione di partenza
    signal min_distance: std_logic_vector(9 downto 0);      -- l'attuale distanza minima trovata
    signal mask: std_logic_vector(7 downto 0);              -- maschera richiesta
    
    signal centroid_cursor: std_logic_vector(7 downto 0);   -- l'indice dell'attuale centroide
    signal config_cursor: std_logic_vector(4 downto 0);     -- l'attuale centroide
    
    -- -- -- -- -- -- -- --
    
    signal state_next: eg_state_type;
    signal current_x_next: std_logic_vector(7 downto 0);         
    signal current_y_next: std_logic_vector(7 downto 0);         
    signal pos_x_next: std_logic_vector(7 downto 0);             
    signal pos_y_next: std_logic_vector(7 downto 0);             
    signal min_distance_next: std_logic_vector(9 downto 0);
    signal mask_next: std_logic_vector(7 downto 0);   
   
    signal centroid_cursor_next: std_logic_vector(7 downto 0);      
    signal config_cursor_next: std_logic_vector(4 downto 0);       
        
                
begin
    --- codice
    process (i_clk, i_rst)
        begin
            if (i_rst='1') then
                state_cur <= START;
            elsif (rising_edge(i_clk)) then
                state_cur <= state_next;
                
                current_x <= current_x_next;
                current_y <= current_y_next;
                pos_x <= pos_x_next;
                pos_y <= pos_y_next;
                min_distance <= min_distance_next;
                mask <= mask_next;
                centroid_cursor <= centroid_cursor_next;
                config_cursor <= config_cursor_next;
            end if;
       end process;
       
    process (state_cur)
        begin
            state_next <= state_cur;
            current_x_next <= current_x;
            current_y_next <= current_y;
            pos_x_next <= pos_x;
            pos_y_next <= pos_y;
            min_distance_next <= min_distance;
            mask_next <= mask;
            centroid_cursor_next <= centroid_cursor;
            config_cursor_next <= config_cursor;
            
            case state_cur is
                when START =>
                    -- codice
                    if (i_start = '1') then
                        current_x <= "00000000";
                        current_y <= "00000000";
                        pos_x <= "00000000";
                        pos_y <= "00000000";
                        min_distance <= "100000000";
                        centroid_cursor <= "00000000";
                        config_cursor <= "00000";
                                                
                        o_done <= '0';
                        
                        state_next <= RAM_READ;
                    else
                        state_next <= START;
                    end if;                    
                when RAM_READ =>
                    -- codice
                    if (centroid_cursor = "00000000") then
                        if (config_cursor = "00000") then       -- 0
                            o_en <= '1';
                            o_address <= "00000000";
                            config_cursor <= "10001";
                            state_next <= RAM_ACK;
                        elsif (config_cursor = "10001") then    -- 17
                            o_en <= '1';
                            o_address <= "00010001";
                            config_cursor <= "10010";
                            state_next <= RAM_ACK;
                        elsif (config_cursor = "10010") then    -- 18
                            o_en <= '1';
                            o_address <= "00010010";
                            config_cursor <= "10011";           -- posizione non valida
                            state_next <= RAM_ACK;
                        end if;
                    else
                        -- calcolare l'indirizzo da leggere
                        -- verificare la maschera
                        -- se ok procedere
                        -- se no skippare
                        
                    end if;
                    
                when RAM_ACK =>
                    -- codice
                    if (centroid_cursor = "00000000") then
                        if (config_cursor = "10001") then       -- leggo la maschera
                            mask_next <= i_data;
                            o_en <= '0';
                            state_next <= RAM_READ;
                        elsif (config_cursor = "10010") then    -- leggo la x
                            pos_x_next <= i_data;
                            o_en <= '0';
                            state_next <= RAM_READ;
                        elsif (config_cursor = "10011") then    -- leggo la y
                            pos_y_next <= i_data;
                            o_en <= '0';
                            state_next <= RAM_READ;
                            centroid_cursor <= "00000001";
                        end if;
                    else
                        -- ricordarsi di incrementare centroid_cursor se non è valido
                    end if;
                                                      
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
