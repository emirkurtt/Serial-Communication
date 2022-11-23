library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity i2c_top is
    port(
        clk             : in    std_logic;
        rst_n           : in    std_logic;
        i2c_en          : in    std_logic;
        i2c_baudrate    : in    std_logic_vector(11 downto 0);
        SCL		        : inout std_logic;
        SDA	 	        : inout std_logic
    );
end entity;

architecture arch of i2c_top is
    component i2c_master is
    port(
        clk             : in    std_logic;
        rst_n           : in    std_logic;
        i2c_en          : in    std_logic;
        i2c_baudrate    : in    std_logic_vector(11 downto 0);
        i_mem_read      : in    std_logic_vector(7 downto 0);
        SCL             : inout std_logic;
        SDA             : inout std_logic;
        o_mem_addr      : out   std_logic_vector(7 downto 0);
        o_mem_write     : out   std_logic_vector(7 downto 0);
        o_mem_write_en  : out   std_logic
    );
    end component;
	-- end i2c_master
    component i2c_memory is
    port(
        clk             : in    std_logic;
        rst_n           : in    std_logic;
        addr            : in    std_logic_vector(7 downto 0);
        wr_data         : in    std_logic_vector(7 downto 0);
        wr_req          : in    std_logic;
        rd              : out   std_logic_vector(7 downto 0)
    );
    end component;
    -- end i2c_memory  
    signal wr_req       : std_logic;
    signal mem_rd_data  : std_logic_vector(7 downto 0);
    signal mem_addr     : std_logic_vector(7 downto 0);
    signal mem_wr_data  : std_logic_vector(7 downto 0);
    signal mem_wrreq    : std_logic;
begin
   I2C_MEM_INST : i2c_memory
   port map(
        clk             => clk,
        rst_n           => rst_n,
        addr            => mem_addr,
        wr_data         => mem_wr_data,
        wr_req          => mem_wrreq,
        rd              => mem_rd_data
   );
   I2C_MASTER_INST : i2c_master
   port map(
        clk             => clk,
        rst_n           => rst_n,
        i_mem_read      => mem_rd_data,
        o_mem_addr      => mem_addr,
        o_mem_write     => mem_wr_data,
        o_mem_write_en  => mem_wrreq,
        i2c_en          => i2c_en,      
        i2c_baudrate    => i2c_baudrate,
        SCL		        => SCL,        
        SDA	 	        => SDA	 	    
   );
end architecture;