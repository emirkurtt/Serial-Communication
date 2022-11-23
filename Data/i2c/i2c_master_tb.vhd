library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity i2c_master_tb is
    
end entity;

architecture bench of i2c_master_tb is
    
    component i2c_top is
    port(
        clk             : in    std_logic;
        rst_n           : in    std_logic;
        i2c_en          : in    std_logic;
        i2c_baudrate    : in    std_logic_vector(11 downto 0);
        SCL		        : inout std_logic;
        SDA	 	        : inout std_logic
    );
	end component;
    
    signal clk             : std_logic;
    signal rst_n           : std_logic;
    signal i2c_en          : std_logic;
    signal i2c_baudrate    : std_logic_vector(11 downto 0);
    signal SCL             : std_logic;
    signal SDA             : std_logic;
    
begin
    I2C_MASTER_INST : i2c_top
        port map(
            clk                => clk                ,
            rst_n              => rst_n              ,
            i2c_en             => i2c_en             ,
            i2c_baudrate       => i2c_baudrate       ,
            SCL                => SCL                ,
            SDA                => SDA                
        );
    
    PROC_CLK_GEN : process is
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;
    
    PROC_STIMULUS : process is
    begin
        rst_n               <= '0';
        i2c_en              <= '1';
        i2c_baudrate        <= x"064";
        SDA                 <= 'Z';
        wait for 10 ns;
        rst_n <= '1';
        wait for 40400 ns;
        SDA                 <= '0';
        wait for 4040 ns;
        SDA                 <= 'Z';
        wait;
    end process;
    
end architecture;