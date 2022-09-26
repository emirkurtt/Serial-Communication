library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity clk_divider is
    generic(
        outclk_div_inclk    : integer := 2 -- out_clk_freq/in_clk_freq
    );
    port(
        clk_i       : in    std_logic;
        rst_n       : in    std_logic;
        clk_o       : out   std_logic
    );
end entity;

architecture arch of clk_divider is
    signal clk_counter : unsigned(7 downto 0);
    signal clk_o_buf   : std_logic;
begin
    clk_o <= clk_o_buf;
    process(rst_n,clk_i) is
    begin
        if rst_n = '0' then
            clk_o_buf   <= '0';
            clk_counter <= (others => '0');
        elsif RISING_EDGE(clk_i) then
            if to_integer(clk_counter) = (outclk_div_inclk-1) then
                clk_counter <= (others => '0');
                clk_o_buf   <= not clk_o_buf;
            else
                clk_counter <= clk_counter + 1;
            end if;
        end if;    
    end process;
end architecture;