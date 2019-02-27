library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH;
use IEEE.numeric_std.all;

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
        (START, MASK_ASK, POS_X_ASK, POS_Y_ASK, POS_Y_ACK, CEN_X_ASK, CEN_Y_ASK, CEN_Y_ACK, DIST_CALC, DIST_EVALUATE, COMPLETED);
        
        -- START: inizio, stato di reset
        -- MASK_ASK: chiede la maschera alla ram (indirizzo 0)
        -- POS_X_ASK: riceve la maschera dalla ram; chiede la posizione x alla ram (indirizzo 17)
        -- POS_Y_ASK: riceve la posx dalla ram; chiede la posizione y alla ram (indirizzo 18)
        -- POS_Y_ACK: riceve la posy dalla ram
        -- CEN_X_ASK: chiede la X di un centroide alla ram
        -- CEN_Y_ASK: riceve la X di un centroide dalla ram; chiede la Y di un centroide alla ram
        -- CEN_Y_ACK: riceve la Y di un centroide dalla ram
        -- DIST_CALC: calcola la distanza tra il punto e il centroide attuale
        -- DIST_EVALUATE: confronta la distanza con quella minima salvata
        -- COMPLETED: computazione completata
        
    signal state_cur: eg_state_type;
    signal current_x: std_logic_vector(7 downto 0);         -- coordinata x del centroide attualmente considerato 
    signal current_y: std_logic_vector(7 downto 0);         -- coordinata y del centroide attualmente considerato
    signal pos_x: std_logic_vector(7 downto 0);             -- coordinata x della posizione di partenza
    signal pos_y: std_logic_vector(7 downto 0);             -- coordinata y della posizione di partenza
    signal min_distance: std_logic_vector(8 downto 0);      -- l'attuale distanza minima trovata
    signal current_distance: std_logic_vector(8 downto 0);  -- la distanza del centroide attuale dal punto
    signal mask: std_logic_vector(7 downto 0);              -- maschera richiesta
    signal config_cursor: std_logic_vector(7 downto 0);     -- l'indirizzo da leggere dalla ram
    
    signal current_mask: std_logic_vector(7 downto 0);      -- la maschera del centroide attuale
    signal output_mask: std_logic_vector(7 downto 0);       -- output
    
    -- -- -- -- -- -- -- --
    
    signal state_next: eg_state_type;
    signal current_x_next: std_logic_vector(7 downto 0);         
    signal current_y_next: std_logic_vector(7 downto 0);         
    signal pos_x_next: std_logic_vector(7 downto 0);             
    signal pos_y_next: std_logic_vector(7 downto 0);             
    signal min_distance_next: std_logic_vector(8 downto 0);
    signal current_distance_next: std_logic_vector(8 downto 0);
    signal mask_next: std_logic_vector(7 downto 0);
    signal config_cursor_next: std_logic_vector(7 downto 0);
   
    signal current_mask_next: std_logic_vector(7 downto 0);
    signal output_mask_next: std_logic_vector(7 downto 0);      
        
                
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
                current_distance <= current_distance_next;
                mask <= mask_next;
                current_mask <= current_mask_next;
                config_cursor <= config_cursor_next;
                output_mask <= output_mask_next;
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
            current_distance_next <= current_distance;
            mask_next <= mask;
            current_mask_next <= current_mask;
            config_cursor_next <= config_cursor;
            output_mask_next <= output_mask;
            
            case state_cur is
                when START =>
                    -- codice
                    if (i_start = '1') then
                        current_x_next <= "00000000";
                        current_y_next <= "00000000";
                        pos_x_next <= "00000000";
                        pos_y_next <= "00000000";
                        min_distance_next <= "100000001";
                        current_distance_next <= "000000000";
                        current_mask_next <= "00000001";
                        output_mask_next <= "00000000";
                        config_cursor_next <= "00000001";
                                                
                        o_done <= '0';
                        
                        state_next <= MASK_ASK;
                    else
                        state_next <= START;
                    end if;
                when MASK_ASK =>
                    -- codice
                    o_en <= '1';
                    o_address <= "0000000000000000";
                    state_next <= POS_X_ASK;                
                when POS_X_ASK =>
                    -- codice
                    mask_next <= i_data;
                    
                    o_address <= "0000000000010001";
                    state_next <= POS_Y_ASK;
                when POS_Y_ASK =>
                    -- codice
                    pos_x_next <= i_data;
                    
                    o_address <= "0000000000010010";
                    state_next <= POS_Y_ACK;
                when POS_Y_ACK =>
                    -- codice
                    pos_y_next <= i_data;
                    o_en <= '0';
                    
                    state_next <= CEN_X_ASK;
                when CEN_X_ASK =>
                    -- codice
                    if (current_mask = "00000000") then
                        state_next <= COMPLETED;
                    else
                        if (unsigned(mask and current_mask) >= 1) then
                            o_en <= '1';
                            o_address <= "00000000"&config_cursor;
                            config_cursor_next <= std_logic_vector(unsigned(config_cursor) + 1);
                            state_next <= CEN_Y_ASK;
                        else
                            config_cursor_next <= std_logic_vector(unsigned(config_cursor) + 2);
                            current_mask_next <= current_mask(6 downto 0) & '0';
                            state_next <= CEN_X_ASK;
                        end if;                        
                    end if;                    
                when CEN_Y_ASK =>
                    -- codice
                    current_x_next <= i_data;
                    
                    o_address <= "00000000"&config_cursor;
                    
                    config_cursor_next <= std_logic_vector(unsigned(config_cursor) + 1);
                    
                    state_next <= CEN_Y_ACK;   
                when CEN_Y_ACK =>
                    -- codice
                    current_y_next <= i_data; 
                    o_en <= '0';
                    
                    state_next <= DIST_CALC;                                            
                when DIST_CALC =>
                    -- codice
                    current_distance_next <= std_logic_vector(abs(signed('0'&current_x) - signed('0'&pos_x)) + abs(signed('0'&current_y) - signed('0'&pos_y)));
                    
                    state_next <= DIST_EVALUATE;
                when DIST_EVALUATE =>
                    -- codice
                    if (unsigned(current_distance) = unsigned(min_distance)) then
                        output_mask_next <= output_mask or current_mask;
                        current_mask_next <= current_mask(6 downto 0) & '0';
                    else
                        if (unsigned(current_distance) < unsigned(min_distance)) then
                            output_mask_next <= current_mask;
                            current_mask_next <= current_mask(6 downto 0) & '0';
                            min_distance_next <= current_distance;
                        end if;
                    end if;
                    state_next <= CEN_X_ASK;

                when COMPLETED =>
                    -- codice
                    if (current_mask = "00000000") then
                        o_en <= '1';
                        o_we <= '1';
                        o_address <= "0000000000010011";
                        o_data <= output_mask;
                        current_mask <= "00000001";
                        state_next <= COMPLETED;
                   else
                        o_done <= '1';
                   end if;
            end case;
        end process;

end Behavioral;
