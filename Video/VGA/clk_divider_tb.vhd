library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity clk_divider_tb is

end entity;

architecture bench of clk_divider_tb is
    component clk_divider is
        generic(
            outclk_div_inclk    : integer := 2 -- out_clk_freq/in_clk_freq
        );
        port(
            clk_i       : in    std_logic;
            rst_n       : in    std_logic;
            clk_o       : out   std_logic
        );
    end component;
    
    
    constant  outclk_div_inclk    : integer := 2 ;
    signal clk_i  :  std_logic;  
    signal rst_n  :  std_logic;  
    signal clk_o  :  std_logic;  
    
begin
    clk_divider_INST : clk_divider
    generic map(
        outclk_div_inclk => outclk_div_inclk
    )
    port map(
        clk_i => clk_i, 
        rst_n => rst_n, 
        clk_o => clk_o 
    );
    
    clk_gen : process is
    begin
        clk_i <= '0';
        wait for 10 ns;
        clk_i <= '1';
        wait for 10 ns;
    end process;
    
    stimulus : process is
    begin
        rst_n <= '0';
        wait for 100 ns;
        rst_n <= '1';
        wait;
    end process;
end architecture;
