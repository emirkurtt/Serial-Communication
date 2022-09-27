library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity VGA_timing_gen is
    port(
        clk         : in    std_logic;
        rst_n       : in    std_logic;
        frame_en    : in    std_logic;
        v_total     : in    std_logic_vector(11 downto 0);
        v_back      : in    std_logic_vector(11 downto 0);
        v_sync      : in    std_logic_vector(11 downto 0);
        v_front     : in    std_logic_vector(11 downto 0);
        v_active    : in    std_logic_vector(11 downto 0);
        h_total     : in    std_logic_vector(11 downto 0);
        h_back      : in    std_logic_vector(11 downto 0);
        h_sync      : in    std_logic_vector(11 downto 0);
        h_front     : in    std_logic_vector(11 downto 0);
        h_active    : in    std_logic_vector(11 downto 0);   
        h_counter   : out   std_logic_vector(11 downto 0);
        v_counter   : out   std_logic_vector(11 downto 0);
        HSYNC       : out   std_logic;
        VSYNC       : out   std_logic;
        DE          : out   std_logic
    );
end entity;

architecture arch of VGA_timing_gen is
    signal h_counter_buf : std_logic_vector(11 downto 0);   -- horizontal counter for pixel
    signal v_counter_buf : std_logic_vector(11 downto 0);   -- vertical counter for lines
begin
    h_counter <= h_counter_buf;
    v_counter <= v_counter_buf;
    process(rst_n,clk) is
    begin
        if rst_n = '0' then
            HSYNC           <= '0';
            VSYNC           <= '0';
            DE              <= '0';
            h_counter_buf   <= "000000000001";
            v_counter_buf   <= "000000000001";
        elsif RISING_EDGE(clk) then
            if frame_en = '1' then
                -- h_counter_buf and v_counter_buf generation
                if h_counter_buf = h_total then
                    h_counter_buf <= "000000000001";
                    v_counter_buf <= v_counter_buf + '1';
                    if v_counter_buf = v_total then
                        v_counter_buf <= "000000000001";
                    end if;
                else
                    h_counter_buf <= h_counter_buf + '1';
                end if;
                -- HSYNC generation
                if h_counter_buf >= h_back and h_counter_buf <= (h_back + h_sync) then
                    HSYNC <= '1';
                else
                    HSYNC <= '0';
                end if;
                -- VSYNC generation
                if v_counter_buf >= v_back and v_counter_buf <= (v_back + v_sync) then
                    VSYNC <= '1';
                else
                    VSYNC <= '0';
                end if;
                -- DE generation
                if v_counter_buf > (v_back + v_sync + v_front) and h_counter_buf > (h_back + h_sync + h_front) then
                    DE <= '1';
                else
                    DE <= '0';
                end if;
            else
                HSYNC       <= '0';
                VSYNC       <= '0';
                DE          <= '0';
                h_counter_buf   <= "000000000001";
                v_counter_buf   <= "000000000001";
            end if;
        end if;
    end process;
end architecture;
