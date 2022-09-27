library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity VGA_Video_Generator is
    port(
        clk         : in    std_logic;
        rst_n       : in    std_logic;
        HSYNC       : in    std_logic;
        VSYNC       : in    std_logic;
        DE          : in    std_logic;
        v_counter   : in    std_logic_vector(11 downto 0);
        h_counter   : in    std_logic_vector(11 downto 0);
        o_red       : out   std_logic_vector(7 downto 0);
        o_green     : out   std_logic_vector(7 downto 0);
        o_blue      : out   std_logic_vector(7 downto 0)
    );
end entity;

architecture arch of VGA_Video_Generator is
    constant h_lim1     : std_logic_vector(11 downto 0) := x"145";
    constant h_lim2     : std_logic_vector(11 downto 0) := x"245";
    constant h_lim3     : std_logic_vector(11 downto 0) := x"2";
    constant v_lim1     : std_logic_vector(11 downto 0) := x"";
    constant v_lim2     : std_logic_vector(11 downto 0) := x"";
    constant v_lim3     : std_logic_vector(11 downto 0) := x"";
    signal o_red_buf    : std_logic_vector(7 downto 0);
    signal o_green_buf  : std_logic_vector(7 downto 0);
    signal o_blue_buf   : std_logic_vector(7 downto 0);

begin
    o_red   <=  o_red_buf   ;
    o_green <=  o_green_buf ;
    o_blue  <=  o_blue_buf  ;
    process(rst_n,clk) is
    begin
        if rst_n = '0' then
            o_red_buf       <= (others <= '1');
            o_green_buf     <= (others <= '1');
            o_blue_buf      <= (others <= '1');
        elsif RISING_EDGE(clk) then
            
        end if;
    end process;
end architecture;