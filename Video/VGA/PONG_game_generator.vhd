library IEEE; 
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


-- also a debouncer is required 

entity PONG_game_generator is 
    port(
        clk                         : in std_logic;
        rst_n                       : in std_logic;
        button_player1_left         : in std_logic;                         -- left button of 1st player
        button_player1_right        : in std_logic;                         -- right button of 1st player
        button_player2_left         : in std_logic;                         -- left button of 2nd player
        button_player2_right        : in std_logic;                         -- right button of 2nd player
        DE                          : in std_logic;                         -- Data Enable coming from VGA timing generator
        h_counter                   : in std_logic_vector(11 downto 0);     -- horizontal counter coming from VGA timing generator 
        v_counter                   : in std_logic_vector(11 downto 0);     -- vertical counter coming from VGA timing generator
        rgb_out                     : out std_logic_vector(23 downto 0)
    );
end entity;


architecture arch of PONG_game_generator is
    constant NUMBER_ZERO: std_logic_vector(1679 downto 0) :=    (   x"000000000000000000000000000000"&
                                                                    x"000000000000000000000000000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffff000000ffffff000000"&
                                                                    x"000000ffffff000000ffffff000000"&
                                                                    x"000000ffffff000000ffffff000000"&
                                                                    x"000000ffffff000000ffffff000000"&
                                                                    x"000000ffffff000000ffffff000000"&
                                                                    x"000000ffffff000000ffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000000000000000000000000000"&
                                                                    x"000000000000000000000000000000"
                                                                );
    constant NUMBER_ONE : std_logic_vector(1679 downto 0) :=    (   x"000000000000000000000000000000"&
                                                                    x"000000000000ffffff000000000000"&
                                                                    x"000000000000ffffff000000000000"&
                                                                    x"000000000000ffffff000000000000"&
                                                                    x"000000000000ffffff000000000000"&
                                                                    x"000000000000ffffff000000000000"&
                                                                    x"000000000000ffffff000000000000"&
                                                                    x"000000000000ffffff000000000000"&
                                                                    x"000000000000ffffff000000000000"&
                                                                    x"000000000000ffffff000000000000"&
                                                                    x"000000000000ffffff000000000000"&
                                                                    x"000000000000ffffff000000000000"&
                                                                    x"000000000000fffffff00000000000"&
                                                                    x"000000000000000000000000000000"
                                                                );
    constant NUMBER_TWO : std_logic_vector(1679 downto 0) :=    (   x"000000000000000000000000000000"&
                                                                    x"000000000000000000000000000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000000000000000ffffff000000"&
                                                                    x"000000000000000000ffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffff000000000000000000"&
                                                                    x"000000ffffff000000000000000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000000000000000000000000000"&
                                                                    x"000000000000000000000000000000"
                                                                );
    constant NUMBER_THRE: std_logic_vector(1679 downto 0) :=    (   x"000000000000000000000000000000"&
                                                                    x"000000000000000000000000000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000000000000000ffffff000000"&
                                                                    x"000000000000000000ffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000000000000000ffffff000000"&
                                                                    x"000000000000000000ffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000000000000000000000000000"&
                                                                    x"000000000000000000000000000000"
                                                                );
    constant NUMBER_FOUR: std_logic_vector(1679 downto 0) :=    (   x"000000000000000000000000000000"&
                                                                    x"000000000000000000000000000000"&
                                                                    x"000000ffffff000000000000000000"&
                                                                    x"000000ffffff000000000000000000"&
                                                                    x"000000ffffff000000000000000000"&
                                                                    x"000000ffffff000000000000000000"&
                                                                    x"000000ffffff000000ffffff000000"&
                                                                    x"000000ffffff000000ffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000000000000000ffffff000000"&
                                                                    x"000000000000000000ffffff000000"&
                                                                    x"000000000000000000000000000000"&
                                                                    x"000000000000000000000000000000"
                                                                );
    constant NUMBER_FIVE: std_logic_vector(1679 downto 0) :=    (   x"000000000000000000000000000000"&
                                                                    x"000000000000000000000000000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffff000000000000000000"&
                                                                    x"000000ffffff000000000000000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000000000000000ffffff000000"&
                                                                    x"000000000000000000ffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000ffffffffffffffffff000000"&
                                                                    x"000000000000000000000000000000"&
                                                                    x"000000000000000000000000000000"
                                                                );
    constant TOTAL_BIT_COUNT_IN_SCOREBOARD_MIN_ONE                  : std_logic_vector(12 downto 0) := "011000011101"; -- 3357 
    constant v_ball_area_low                                        : std_logic_vector(11 downto 0) := x"000" ;     -- tbd
    constant v_ball_area_high                                       : std_logic_vector(11 downto 0) := x"000" ;
    constant h_ball_area_low                                        : std_logic_vector(11 downto 0) := x"000" ;
    constant h_ball_area_high                                       : std_logic_vector(11 downto 0) := x"000" ;
    constant v_player1_bar_low                                      : std_logic_vector(11 downto 0) := x"000" ;
    constant v_player1_bar_high                                     : std_logic_vector(11 downto 0) := x"000" ;
    constant h_player1_bar_high                                     : std_logic_vector(11 downto 0) := x"000" ;
    constant h_player1_bar_low                                      : std_logic_vector(11 downto 0) := x"000" ;
    constant v_player2_bar_low                                      : std_logic_vector(11 downto 0) := x"000" ;
    constant v_player2_bar_high                                     : std_logic_vector(11 downto 0) := x"000" ;
    constant h_player2_bar_low                                      : std_logic_vector(11 downto 0) := x"000" ;
    constant h_player2_bar_high                                     : std_logic_vector(11 downto 0) := x"000" ;
    constant v_scoreboard_area_low                                  : std_logic_vector(11 downto 0) := x"000" ;
    constant v_scoreboard_area_high                                 : std_logic_vector(11 downto 0) := x"000" ;
    constant h_scoreboard_area_low                                  : std_logic_vector(11 downto 0) := x"000" ;
    constant h_scoreboard_area_high
    
    signal score_changed                                    : std_logic;
    signal rgb_numbers_buf                                  : std_logic_vector(TOTAL_BIT_COUNT_IN_SCOREBOARD_MIN_ONE downto 0);   -- buffer to hold numbers in a buffer
    signal rgb_numbers_buf2                                 : std_logic_vector(TOTAL_BIT_COUNT_IN_SCOREBOARD_MIN_ONE downto 0);   -- buffer to hold numbers in a buffer
    signal number_of_bits_put_onto_screen_from_scoreboard   : unsigned(12 downto 0);
begin
    PROC_VIDEO : process(rst_n,clk) is
    begin
        if rst_n = '0' then
            rgb_out         <= x"ffffff";               -- print white screen when reset is active
            number_of_bits_put_onto_screen_from_scoreboard <= (others => '0');
        elsif RISING_EDGE(clk) then 
            -- check score first to update scoreboard
            if score_changed = '1' then
                rgb_numbers_buf2 <= rgb_numbers_buf;
            end if;
            -- 
            if (not ((v_counter > v_ball_area_low and v_counter < v_ball_area_high) and (h_counter > h_ball_area_low and h_counter < h_ball_area_high) )) and DE= '1' then  -- if there is no ball around
                if (not ((v_counter > v_scoreboard_area_low and v_counter < v_scoreboard_area_high) and (h_counter > h_scoreboard_area_low and h_counter < h_scoreboard_area_high) )) and DE= '1' then-- and if there is no scoreboard around
                    rgbout <= x"0000ff";                -- hockey pitch is blue
                    if (v_counter > v_player1_bar_low and v_counter <= v_player1_bar_high) and (h_counter > h_player1_bar_low and h_counter <= h_player1_bar_high) then
                        rgb_out <= x"ffffff";   -- first bar will be white
                    elsif (v_counter > v_player2_bar_low and v_counter <= v_player2_bar_high) and (h_counter > h_player2_bar_low and h_counter <= h_player2_bar_high) then
                        rgb_out <= x"ffffff";   -- second bar will be white
                    end if;
                elsif ((v_counter > v_scoreboard_area_low and v_counter < v_scoreboard_area_high) and (h_counter > h_scoreboard_area_low and h_counter < h_scoreboard_area_high) )) and DE= '1'   -- scoreboard area 
                    if to_integer(number_of_bits_put_onto_screen_from_scoreboard) < to_integer(unsigned(TOTAL_BIT_COUNT_IN_SCOREBOARD_MIN_ONE)) then
                        rgb_out <= rgb_numbers_buf2(to_integer(unsigned(TOTAL_BIT_COUNT_IN_SCOREBOARD_MIN_ONE)) downto (to_integer(unsigned(TOTAL_BIT_COUNT_IN_SCOREBOARD_MIN_ONE)) - 23));
                        rgb_numbers_buf2 <= rgb_numbers_buf2(3333 downto 0) & x"000000";
                        number_of_bits_put_onto_screen_from_scoreboard <= number_of_bits_put_onto_screen_from_scoreboard + "0000000011000";
                    end if;
                end if; 
            end if;
        end if;
    end process;
    
    PROC_SCORE : process(rst_n,clk) is  -- determine what should scoreboard be
    begin
        if rst_n = '0' then 
            rgb_numbers_buf <= (others => '0');
            score_changed   <= '0';
        elsif RISING_EDGE(clk) then
            
        end if;
    end process;
    
end architecture;
