library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_RX is
	generic(
		clks_per_bit: integer := 434;-- 50_000_000/115_200
		DATA_DEPTH	: integer := 8
	);
	port(
		Clock	:	in		std_logic;
		Reset	:	in		std_logic;
		Rx_line	:	in		std_logic;
		FIFO	:	out		std_logic_vector((DATA_DEPTH-1) downto 0)
	);
end entity;


architecture Rx of UART_RX is 

type STATES is (ST_IDLE, ST_START, ST_DATA, ST_STOP);
signal state: STATES;
signal clk_Counter: integer;				-- it will count up to clks_per_bit
signal number_of_data_received: integer;	-- when it reaches to DATA_DEPTH we will enter to another state

begin
	process(Clock,Reset) is 
		begin
			if Reset = '0' then
				state						<= ST_IDLE;
				clk_Counter			 		<= 0;
				number_of_data_received		<= 0;
				FIFO						<= "00000000";
			elsif RISING_EDGE(Clock) then 
				case state is
					when ST_IDLE 	=>
						clk_Counter 			<= 0;
						number_of_data_received <= 0;
						if Rx_line = '0' then		-- if HIGH to LOW transmission occurs, go to start state
							state	<= ST_START;
						else 
							state	<= ST_IDLE;
						end if;
					when ST_START	=>
						if clk_Counter < (clks_per_bit/2) then
							clk_Counter <= clk_Counter+1;
							state		<= ST_START;
						elsif clk_Counter = (clks_per_bit/2) then 
							clk_Counter <= 0;
							if Rx_line = '0' then 	-- check if the line is still "0", if this is the case go to DATA state
								state <= ST_DATA;
							else 
								state <= ST_IDLE;
							end if;
						else 
							clk_Counter  <= 0;
							state		 <= ST_IDLE;
						end if;
					when ST_DATA	=>
						if number_of_data_received < DATA_DEPTH then	-- take samples
							if clk_Counter < clks_per_bit then 
								clk_Counter <= clk_Counter +1;
								state 		<= ST_DATA ;
							else -- clk_Counter = clks_per_bit
								FIFO(number_of_data_received) <= Rx_line;
								clk_Counter <= 0;
								number_of_data_received 	  <= number_of_data_received +1;
							end if;
						else	-- number_of_data_received = DATA_DEPTH 
								state					<= ST_STOP;
								clk_Counter 			<= 0;
								number_of_data_received	<= 0;
						end if;
					when ST_STOP	=>
						if  clk_Counter < clks_per_bit then 
							clk_Counter	<= clk_Counter +1;
							state		<= ST_STOP;
						else -- clk_Counter = clks_per_bit 
							if Rx_line = '1' then 
								clk_Counter	<= 0;
								state		<= ST_IDLE;						
							--else
								-- error
							end if;
						end if; 
					when others		=>
						state						<= ST_IDLE;
						clk_Counter					<= 0;
						number_of_data_received		<= 0;
						FIFO						<= "00000000";						
				end case;
			end if;
	end process;
end architecture;