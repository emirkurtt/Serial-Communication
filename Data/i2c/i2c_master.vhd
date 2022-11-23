library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity i2c_master is
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
end entity;

architecture arch of i2c_master is
    constant EIGHT          : std_logic_vector(7 downto 0) := "00001000";
    
	type   FSM              is (ST_IDLE,ST_START,ST_SLAVE_ADDRESS,ST_ACK,
                                ST_POINTER_ADDRESS, ST_ACK_AGAIN
                                
                                );
    signal state            : FSM;
    signal r_w_en           : std_logic;
    signal i2c_write_buf    : std_logic_vector(7 downto 0);
    signal baudrate_counter : unsigned(11 downto 0);
    signal data_sent_count  : unsigned(7 downto 0);
    signal o_mem_addr_buf   : std_logic_vector(7 downto 0);
    signal SCL_buf          : std_logic;
    signal SCL_buf2         : std_logic;
    signal r_w_flag         : std_logic;
    signal ack_en           : std_logic;
    signal ack_done         : std_logic;
    signal ack_error        : std_logic;
begin
    o_mem_addr  <= o_mem_addr_buf;
    
    PROC_TRIAL : process(rst_n,clk) is
    begin
    if rst_n = '0' then
        SCL         <= 'Z';
        SCL_buf2    <= '1';
    elsif RISING_EDGE(clk) then
        SCL_buf2    <= SCL_buf;
        SCL         <= SCL_buf2;
    end if;
    end process;
    
    PROC_SCL_GEN : process(rst_n,clk) is
    begin
        if rst_n = '0' then
            r_w_en              <= '0';
            r_w_flag            <= '0';
            baudrate_counter    <= (others => '0');
            SCL_buf             <= '1';
        elsif RISING_EDGE(clk) then
            if i2c_en = '1' then
                if baudrate_counter < unsigned(i2c_baudrate) then
                    r_w_en           <= '0';
                    ack_en           <= '0';
                    baudrate_counter <= baudrate_counter + 1;
                else
                    SCL_buf          <= not SCL_buf;
                    ack_en           <= '1';
                    baudrate_counter <= (others => '0');
                    if r_w_flag = '1' then
                        r_w_en           <= '1';
                        r_w_flag         <= '0';
                    else
                        r_w_flag         <= '1';
                    end if;
                end if;
            else
                r_w_en              <= '0';
                ack_en           <= '0';
                baudrate_counter    <= (others => '0');
                SCL_buf             <= '1';
            end if;
        end if;
    end process;


    PROC_READ_WRITE : process(rst_n,clk) is
    begin
        if rst_n = '0' then
            SDA             <= 'Z';
            o_mem_addr_buf  <= (others => '0');
            o_mem_write     <= (others => '0');
            o_mem_write_en  <= '0';
            i2c_write_buf   <= (others => '0');
            data_sent_count <= (others => '0');
            ack_done        <= '0';
            ack_error       <= '0';
            state           <= ST_IDLE;
        elsif RISING_EDGE(clk) then
            case state  is 
                when ST_IDLE            =>
                    SDA             <= 'Z';
                    o_mem_addr_buf  <= (others => '0');
                    o_mem_write     <= (others => '0');
                    o_mem_write_en  <= '0';
                    i2c_write_buf   <= (others => '0');
                    data_sent_count <= (others => '0');
                    ack_done        <= '0';
                    ack_error       <= '0';
                    if i2c_en = '1' then
                        state       <= ST_START;
                    end if;
                when ST_START           =>
                    SDA             <= '0';
                    if r_w_en = '1' then
                      state         <= ST_SLAVE_ADDRESS;
                      i2c_write_buf <= i_mem_read;
                    end if;
                when ST_SLAVE_ADDRESS   => 
                    if data_sent_count < unsigned(EIGHT) then
                       if r_w_en = '1' then
                            SDA             <= i2c_write_buf(7);
                            i2c_write_buf   <= i2c_write_buf(6 downto 0) & '0';
                            data_sent_count <= data_sent_count + 1;
                       end if;
                    else
                        if r_w_en = '1' then 
                            SDA             <= 'Z';
                            data_sent_count <= (others => '0');
                            o_mem_addr_buf  <= std_logic_vector(unsigned(o_mem_addr_buf) + 1);
                            state           <= ST_ACK;
                        end if;
                    end if;
                when ST_ACK             =>
                    i2c_write_buf  <= i_mem_read;
                    if ack_en = '1' and r_w_en = '0' then
                        if SDA = '0' then
                            ack_done <= '1';
                        else
                            ack_error <= '1';
                        end if;
                    elsif r_w_en = '1' then
                        if ack_done = '1' then
                            SDA   <= i2c_write_buf(7);
                            state <= ST_POINTER_ADDRESS;
                        elsif ack_error = '1' then
                            state <= ST_IDLE;
                        end if;
                    end if;
                when ST_POINTER_ADDRESS => 
                    if data_sent_count < unsigned(EIGHT) then
                       if r_w_en = '1' then
                            SDA             <= i2c_write_buf(7);
                            i2c_write_buf   <= i2c_write_buf(6 downto 0) & '0';
                            data_sent_count <= data_sent_count + 1;
                       end if;
                    else
                        if r_w_en = '1' then 
                            SDA             <= 'Z';
                            data_sent_count <= (others => '0');
                            o_mem_addr_buf  <= std_logic_vector(unsigned(o_mem_addr_buf) + 1);
                            state           <= ST_ACK_AGAIN;
                        end if;
                    end if;
                when ST_ACK_AGAIN =>
                    SDA <= 'Z';
                when others             =>
                    state <= ST_IDLE;
            end case;
        end if;
    end process;

end architecture;
