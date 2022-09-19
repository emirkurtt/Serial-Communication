library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity SPI_master_tb is

end entity SPI_master_tb; 

architecture bench of SPI_master_tb is 
    component SPI_master is 
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
    end component SPI_master;
    
    constant DATA_WIDTH      : integer := 8;
    constant clk_per_bit     : integer := 4; 
    
    signal clk     :   std_logic;
    signal rst_n   :   std_logic;
    signal mode    :   std_logic_vector(1 downto 0);
    signal D_in    :   std_logic_vector(DATA_WIDTH-1 downto 0);
    signal DV      :   std_logic;                              
    signal MISO    :   std_logic;
    signal i_CS1   :   std_logic;
    signal i_CS2   :   std_logic;
    signal MOSI    :   std_logic;
    signal SCLK    :   std_logic;
    signal Tx_busy :   std_logic;
    signal Tx_end  :   std_logic;
    signal Rx_busy :   std_logic;
    signal Rx_end  :   std_logic;
    signal Rx_byte :   std_logic_vector(DATA_WIDTH-1 downto 0);
    signal CS1     :   std_logic;
    signal CS2     :   std_logic;
    
begin

    SPI_master_INST : SPI_master
    generic map(
        DATA_WIDTH  =>  DATA_WIDTH      ,
        clk_per_bit =>  clk_per_bit     
    )
    port map(
        clk     =>    clk               ,
        rst_n   =>    rst_n             ,
        mode    =>    mode              ,
        D_in    =>    D_in              ,
        DV      =>    DV                ,
        MISO    =>    MISO              ,
        i_CS1   =>    i_CS1             ,
        i_CS2   =>    i_CS2             ,
        MOSI    =>    MOSI              ,
        SCLK    =>    SCLK              ,
        Tx_busy =>    Tx_busy           ,
        Tx_end  =>    Tx_end            ,
        Rx_busy =>    Rx_busy           ,
        Rx_end  =>    Rx_end            ,
        Rx_byte =>    Rx_byte           ,
        CS1     =>    CS1               ,
        CS2     =>    CS2    
    );
    
    clk_generation : process 
    begin
        clk <= '0'; 
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    stimulus : process
    begin
        rst_n       <= '0';
        mode        <= "00";
        D_in        <= x"35";
        DV          <= '1';
        MISO        <= '1';
        i_CS1       <= '0';     -- active low Chip select
        i_CS2       <= '1';
        wait for 300 ns;
        rst_n <= '1';
        wait for 20 ns;
        MISO        <= '1';
        wait for 40 ns;
        MISO        <= '0';
        wait for 40 ns;
        MISO        <= '1';
        wait for 40 ns;
        MISO        <= '0';
        wait for 40 ns;
        MISO        <= '1';
        wait for 20 ns;
        MISO        <= '0';
        wait;
    end process;

end architecture;