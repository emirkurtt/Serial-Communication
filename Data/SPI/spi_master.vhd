-- MSB First protocol
-- There are 4 modes on implementation of SPI and in my design, mode input is utilized for mode selection.
--
--                                      DATA is sampled on      ||  Outgoing DATA is shifted out on
--  Mode 0   => mode input = "00" =>    RISING_EDGE             ||  FALLING_EDGE                     -- POSITIVE CLOCK POLARITY
--  Mode 1   => mode input = "01" =>    FALLING_EDGE            ||  RISING_EDGE                      -- POSITIVE CLOCK POLARITY
--  Mode 2   => mode input = "10" =>    FALLING_EDGE            ||  RISING_EDGE                      -- NEGATIVE CLOCK POLARITY   
--  Mode 3   => mode input = "11" =>    RISING_EDGE             ||  FALLING_EDGE                     -- NEGATIVE CLOCK POLARITY   
--
--
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity SPI_master is 
    generic(
        DATA_WIDTH      : integer := 8;
        clk_per_bit     : integer := 4
    );
    port(
        clk     : in    std_logic;
        rst_n   : in    std_logic;
        mode    : in    std_logic_vector(1 downto 0);
        D_in    : in    std_logic_vector(DATA_WIDTH-1 downto 0);
        DV      : in    std_logic;                                  -- DATA VALID INPUT
        MISO    : in    std_logic;
        i_CS1   : in    std_logic;
        i_CS2   : in    std_logic;
        MOSI    : out   std_logic;
        SCLK    : out   std_logic;
        Tx_busy : out   std_logic;
        Tx_end  : out   std_logic;
        Rx_busy : out   std_logic;
        Rx_end  : out   std_logic;
        Rx_byte : out   std_logic_vector(DATA_WIDTH-1 downto 0);
        CS1     : out   std_logic;
        CS2     : out   std_logic
    );
end entity SPI_master;

architecture arch of SPI_master is
    type TX_FSM is (ST_TX_IDLE,ST_TX_SEND,ST_TX_DONE);
    type RX_FSM is (ST_RX_IDLE,ST_RX_RECV,ST_RX_DONE);
    signal TX_State             : TX_FSM;
    signal RX_State             : RX_FSM;
    signal SCLK_buf             : std_logic;
    signal clk_flag             : std_logic_vector (1 downto 0);
    signal MISO_Data_Buffer     : std_logic_vector (DATA_WIDTH-1 downto 0);
    signal clk_counter          : unsigned (10 downto 0);
    signal MOSI_Index_Ctr       : unsigned (4 downto 0);
    signal MISO_Index_Ctr       : unsigned (4 downto 0);
    
begin
    SCLK    <= SCLK_buf;
    -- clk generator
    sclk_gen : process(rst_n,clk) is
    begin
        if rst_n = '0' then
            if mode(1) = '0' then           -- POSITIVE CLOCK POLARITY CASE
                SCLK_buf    <= '0';
            else                            -- NEGATIVE CLOCK POLARITY CASE
                SCLK_buf    <= '1';
            end if;
            clk_flag    <= "00";
            clk_counter     <= (others => '0');            
        elsif RISING_EDGE(clk) then
            if to_integer(clk_counter) = clk_per_bit then
                if SCLK_buf = '0' then          -- RISING EDGE OF SCLK
                    clk_flag        <= "01";                                     
                else                            -- FALLING EDGE OF SCLK
                    clk_flag        <= "10";                                     
                end if;
                clk_counter     <= (others => '0');
                SCLK_buf        <= not SCLK_buf;
            else
                clk_flag        <= "00";
                clk_counter     <= clk_counter + 1;
            end if;
        end if;
    end process;
    
    -- XMISSION PROCESS
    TX_proc: process(rst_n,clk) is 
    begin
        if rst_n = '0' then
            MOSI                <= 'Z';
            MOSI_Index_Ctr      <= (others => '0');
            Tx_busy             <= '0';
            Tx_end              <= '0';
            CS1                 <= '1'; -- Active low
            CS2                 <= '1';
        elsif RISING_EDGE(clk) then
            case TX_State is 
                when ST_TX_IDLE =>
                    MOSI                <= 'Z';
                    MOSI_Index_Ctr      <= (others => '0');
                    Tx_end              <= '0';
                    Tx_busy             <= '0';
                    if DV = '1' then
                        CS1         <= i_CS1;
                        CS2         <= i_CS2;
                        TX_State    <= ST_TX_SEND;
                        Tx_busy     <= '1';
                    else
                        CS1 <= '1';
                        CS2 <= '1';
                    end if;
                when ST_TX_SEND =>
                    if clk_flag = "01" and (mode = "00" or mode = "11" )then            -- sampling is done in RISING_EDGE of the clock for modes 0 and 3
                        if to_integer(MOSI_Index_Ctr) /= DATA_WIDTH-1 then
                            MOSI                <= D_in(DATA_WIDTH-1-to_integer(MOSI_Index_Ctr));
                            MOSI_Index_Ctr      <= MOSI_Index_Ctr + 1;
                            TX_State            <= ST_TX_SEND;
                        else
                            MOSI_Index_Ctr      <= (others => '0');
                            TX_State            <= ST_TX_DONE;
                        end if;
                    elsif clk_flag = "10" and (mode = "01" or mode = "10" )then          -- sampling is done in FALLING_EDGE of the clock for modes 1 and 2
                        if to_integer(MOSI_Index_Ctr) /= DATA_WIDTH-1 then
                            MOSI                <= D_in(DATA_WIDTH-1-to_integer(MOSI_Index_Ctr));
                            MOSI_Index_Ctr      <= MOSI_Index_Ctr + 1;
                            TX_State            <= ST_TX_SEND;
                        else
                            MOSI_Index_Ctr      <= (others => '0');
                            TX_State            <= ST_TX_DONE;
                        end if;
                    end if;
                when ST_TX_DONE =>
                    Tx_busy     <= '0';
                    Tx_end      <= '1';
                    TX_State    <= ST_TX_IDLE;
            end case;
        end if;
    end process;
    
    -- RECEIPTION PROCESS
    RX_proc: process(rst_n,clk) is 
    begin
        if rst_n = '0' then
            MISO_Index_Ctr      <= (others => '0');
            MISO_Data_Buffer    <= (others => '0');
            Rx_byte             <= (others => '0');
            Rx_end              <= '0';
            Rx_busy             <= '0';
        elsif RISING_EDGE(clk) then
            case RX_State is 
                when ST_RX_IDLE =>
                    MISO_Index_Ctr      <= (others => '0');
                    MISO_Data_Buffer    <= (others => '0');
                    Rx_end              <= '0';
                    if DV = '1' then
                        RX_State            <= ST_RX_RECV;
                        Rx_busy             <= '1';
                    else
                        Rx_busy             <= '0';
                    end if;
                when ST_RX_RECV =>
                    if clk_flag = "10" and (mode = "00" or mode = "11" ) then                   -- SAMPLING IS DONE IN THE FALLING_EDGE OF THE CLOCK FOR MODES 0 and 3
                        if to_integer(MISO_Index_Ctr) /= DATA_WIDTH-1 then
                            MISO_Data_Buffer(DATA_WIDTH-1-to_integer(MISO_Index_Ctr)) <= MISO;
                            MISO_Index_Ctr      <= MISO_Index_Ctr + 1;
                            RX_State            <= ST_RX_RECV;
                        else
                            MISO_Index_Ctr      <= (others => '0');
                            RX_State            <= ST_RX_DONE;
                        end if;
                    elsif clk_flag = "01" and (mode = "01" or mode = "10" ) then                   -- SAMPLING IS DONE IN THE RISING_EDGE OF THE CLOCK FOR MODES 1 and 2
                        if to_integer(MISO_Index_Ctr) /= DATA_WIDTH-1 then
                            MISO_Data_Buffer(DATA_WIDTH-1-to_integer(MISO_Index_Ctr)) <= MISO;
                            MISO_Index_Ctr      <= MISO_Index_Ctr + 1;
                            RX_State            <= ST_RX_RECV;
                        else
                            MISO_Index_Ctr      <= (others => '0');
                            RX_State            <= ST_RX_DONE;
                        end if;
                    end if;
                when ST_RX_DONE =>
                    Rx_busy     <= '0';
                    Rx_end      <= '1';
                    RX_State    <= ST_RX_IDLE;
            end case;
        end if;
    end process;
end architecture;