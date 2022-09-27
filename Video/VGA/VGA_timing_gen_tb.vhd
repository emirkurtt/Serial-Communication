library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity VGA_timing_gen_tb is
    
end entity;

architecture bench of VGA_timing_gen_tb is
    component VGA_timing_gen is
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
    end component;
    
    signal clk         :  std_logic;
    signal rst_n       :  std_logic;
    signal frame_en    :  std_logic;
    signal v_total     :  std_logic_vector(11 downto 0);
    signal v_back      :  std_logic_vector(11 downto 0);
    signal v_sync      :  std_logic_vector(11 downto 0);
    signal v_front     :  std_logic_vector(11 downto 0);
    signal v_active    :  std_logic_vector(11 downto 0);
    signal h_total     :  std_logic_vector(11 downto 0);
    signal h_back      :  std_logic_vector(11 downto 0);
    signal h_sync      :  std_logic_vector(11 downto 0);
    signal h_front     :  std_logic_vector(11 downto 0);
    signal h_active    :  std_logic_vector(11 downto 0); 
    signal h_counter   :  std_logic_vector(11 downto 0);
    signal v_counter   :  std_logic_vector(11 downto 0);
    signal HSYNC       :  std_logic;
    signal VSYNC       :  std_logic;
    signal DE          :  std_logic;
    
begin
    VGA_timing_gen_INST: VGA_timing_gen 
        port map(
            clk         => clk       ,
            rst_n       => rst_n     ,
            frame_en    => frame_en  ,
            v_total     => v_total   ,
            v_back      => v_back    ,
            v_sync      => v_sync    ,
            v_front     => v_front   ,
            v_active    => v_active  ,
            h_total     => h_total   ,
            h_back      => h_back    ,
            h_sync      => h_sync    ,
            h_front     => h_front   ,
            h_active    => h_active  ,  
            h_counter   => h_counter ,
            v_counter   => v_counter ,
            HSYNC       => HSYNC     ,
            VSYNC       => VSYNC     ,
            DE          => DE         
        );
    
    clk_gen : process is
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;
    
    stimulus : process is
    begin
        rst_n       <= '0';
        frame_en    <= '1';
        h_total     <= x"320";
        h_back      <= x"030";
        h_sync      <= x"060";
        h_front     <= x"010";
        h_active    <= x"280";
        v_total     <= x"20D";
        v_back      <= x"021";
        v_sync      <= x"002";
        v_front     <= x"00A";
        v_active    <= x"1E0";
        wait for 100 ns;
        rst_n <= '1';
        wait;
    end process;
    
end architecture;