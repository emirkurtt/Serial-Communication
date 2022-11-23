library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity i2c_memory is
    port(
        clk             : in    std_logic;
        rst_n           : in    std_logic;
        addr            : in    std_logic_vector(7 downto 0);
        wr_data         : in    std_logic_vector(7 downto 0);
        wr_req          : in    std_logic;
        rd              : out   std_logic_vector(7 downto 0)
    );
end entity;

architecture arch of i2c_memory is
    type RAM_ARRAY is array (0 to 127) of std_logic_vector(7 downto 0);
    signal RAM : RAM_ARRAY;
begin
    PROC_READ : process(rst_n,clk) is
    begin
        if rst_n = '0' then
            rd  <= (others => '0');
        elsif RISING_EDGE(clk) then
            rd  <= RAM(to_integer(unsigned(addr)));
        end if;
    end process;
    
    PROC_WRITE : process(rst_n,clk) is
    begin
        if rst_n = '0' then
            RAM(0)  <= x"90";       -- slave address
            RAM(1)  <= x"BB";       -- pointer address
            RAM(2)  <= x"23";       -- read command
            RAM(3)  <= x"02";       -- number of bytes to be read
            RAM(4)  <= x"00";       -- first byte
            RAM(5)  <= x"00";       -- second byte
            RAM(6)  <= x"99";       -- turn back to start of memory
        elsif RISING_EDGE(clk) then
            if wr_req = '1' then
                RAM(to_integer(unsigned(addr))) <= wr_data;            
            end if;
        end if;
    end process;

end architecture;