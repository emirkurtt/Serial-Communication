-- created by EMIRKURT on 15.09.22
-- SPI master with 2 CS's, this will be converted to a generic usage later.

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity SPI_master is 
    generic(
        DATA_WIDTH      : integer := 8
    )
    port(
        clk     : in    std_logic;
        rst_n   : in    std_logic;
        D_in    : in    std_logic_vector(DATA_WIDTH-1 downto 0);
        MISO    : in    std_logic;
        MOSI    : out   std_logic;
        SCLK    : out   std_logic;
        CS1     : out   std_logic;
        CS2     : out   std_logic
    );
end entity SPI_master;

architecture arch of SPI_master is

    signal clk_counter          : std_logic_vector (10 downto 0);
    signal clk_flag             : std_logic;
    signal DATA_Buf_from_MISO   : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    -- clk generator
    sclk_gen : process(rst_n,clk) is
    begin
        if rst_n = '0' then
        
        elsif RISING_EDGE(clk) then
        
        end if;
    end process;
    
    -- main process where transactions occure
    main_proc: process(rst_n,clk) is 
    begin
        if rst_n = '0' then
        
        elsif RISING_EDGE(clk) then
        
        end if;
    end process;
end architecture;
