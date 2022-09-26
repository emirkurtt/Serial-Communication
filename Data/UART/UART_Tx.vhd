-- created by Emir KURT on 31.08.22

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- clk freq = 50 Mhz
-- work with a baud rate of 115200 
entity UART_Tx is 
    generic(
        DATA_WIDTH      : integer   := 8;
        clk_per_bit     : integer   := 434 -- 50.000.000/115200
        );
    
    port(
        clk             : in    std_logic;
        rst_n           : in    std_logic;
        parity_sel      : in    std_logic;                                          -- Parity select: 1 for EVEN Parity, 0 for ODD Parity
        Tx_Start        : in    std_logic;                                          -- Start action for transmission
        Data_in         : in    std_logic_vector(DATA_WIDTH-1 downto 0);
        Tx_Busy         : out   std_logic;                                          -- Shows if xmission is happening or not
        Tx_line         : out   std_logic;                                          -- outgoing line
        Tx_Done         : out   std_logic	                                          -- Shows xmission is terminated
    );
end entity UART_Tx;

architecture arch of UART_Tx is
    type FSM is (TX_ST_IDLE,TX_ST_START,TX_ST_DATA,TX_ST_PARITY,TX_ST_STOP);
    signal TX_State     : FSM;
    signal Data_index   : unsigned(4    downto 0);
    signal clk_counter  : unsigned(10   downto 0);
    signal parity_even  : std_logic;
begin
    process(rst_n,clk) is
    begin
        if rst_n = '0' then
            Tx_Busy         <= '0';
            Tx_Done         <= '0';
            Tx_line         <= '1';
            TX_State        <= TX_ST_IDLE;
            Data_index      <= (others => '0');
            clk_counter     <= (others => '0');
            parity_even     <= '0';
        elsif RISING_EDGE(clk) then
            case TX_State is
                when TX_ST_IDLE         =>
                    Tx_Busy         <= '0';
                    Tx_Done         <= '0';
                    Tx_line         <= '1';
                    Data_index      <= (others => '0');
                    clk_counter     <= (others => '0');
                    parity_even     <= '0';
                    if Tx_Start = '1' then
                        TX_State        <= TX_ST_START;
                        Tx_Busy         <= '1';
                    else
                        TX_State        <= TX_ST_IDLE;
                    end if;
                when TX_ST_START        =>
                    if clk_counter = clk_per_bit then
                        clk_counter     <= (others => '0');  
                        TX_State        <= TX_ST_DATA;
                        parity_even     <= parity_even xor '0';
                    else
                        clk_counter     <= clk_counter + 1;
                        Tx_line         <= '0';
                        TX_State        <= TX_ST_START;
                    end if;
                when TX_ST_DATA         =>
                    if to_integer(Data_index) /= DATA_WIDTH -1 then
                        if clk_counter = clk_per_bit then
                            clk_counter     <= (others => '0');  
                            TX_State        <= TX_ST_DATA;
                            parity_even     <= parity_even xor Data_in(to_integer(Data_index));
                            Data_index      <= Data_index + 1;
                        else 
                            clk_counter     <= clk_counter + 1;
                            Tx_line         <= Data_in(to_integer(Data_index));
                            TX_State        <= TX_ST_DATA;
                        end if;
                    else
                        if clk_counter = clk_per_bit then
                            clk_counter     <= (others => '0');  
                            Data_index      <= (others => '0');
                            TX_State        <= TX_ST_PARITY;
                            parity_even     <= parity_even xor Data_in(to_integer(Data_index));
                        else 
                            clk_counter     <= clk_counter + 1;
                            Tx_line         <= Data_in(to_integer(Data_index));
                            TX_State        <= TX_ST_DATA;
                        end if;
                    end if;
                when TX_ST_PARITY       =>
                    if clk_counter = clk_per_bit then
                        clk_counter     <= (others => '0');  
                        TX_State        <= TX_ST_STOP;
                        parity_even     <= '0';
                    else
                        clk_counter     <= clk_counter + 1;
                        TX_State        <= TX_ST_PARITY;
                        if parity_sel = '1' then
                            Tx_line     <= parity_even;
                        else
                            Tx_line     <= not parity_even;
                        end if;
                    end if;
                when TX_ST_STOP         =>
                    if clk_counter = clk_per_bit then
                        clk_counter     <= (others => '0');  
                        TX_State        <= TX_ST_IDLE;
                        Tx_Done         <= '1';
                        --Tx_Busy         <= '0';
                    else
                        clk_counter     <= clk_counter + 1;
                        TX_State        <= TX_ST_STOP;
                        Tx_line         <= '1';
                    end if;
                when others             =>
                    TX_State        <= TX_ST_IDLE;
            end case;
        end if;
    end process;
end architecture;
