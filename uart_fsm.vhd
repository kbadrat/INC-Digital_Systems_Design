-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): Vladyslav Kovalets, xkoval21
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------

entity UART_FSM is
port(
   CLK                  : in std_logic;
   RST                  : in std_logic;
   DIN                  : in std_logic;
   CLOCK_COUNTER        : in std_logic_vector(4 downto 0); 
   BIT_COUNTER          : in std_logic_vector(3 downto 0); 
   RECEIVE_DATA_ENABLE  : out std_logic;
   CLOCK_COUNTER_ENABLE : out std_logic;
   DOUT_VLD             : out std_logic
   );                          
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type status_type is (check_start_bit, check_first_bit, get_data, check_final_bit, reliable_data);
signal status : status_type := check_start_bit;

begin

   CLOCK_COUNTER_ENABLE <= '1' when status = check_first_bit or status = get_data or status = check_final_bit else '0';
   RECEIVE_DATA_ENABLE  <= '1' when status = get_data else '0';
   DOUT_VLD             <= '1' when status = reliable_data else '0';

   process (CLK) begin
      if (CLK'event and CLK = '1') then 
         if RST = '1' then
            status <= check_start_bit;                                
         else                                                        
            case status is                                           

            when check_start_bit => if DIN = '0' then                
                                       status <= check_first_bit;     
                                    end if;                          

            when check_first_bit => if CLOCK_COUNTER = "00111" then       
                                       if DIN /= '0' then                  
                                          status <= check_start_bit;      
                                       else                                 
                                          status <= get_data;  
                                       end if;         
                                    end if;

            when get_data        => if BIT_COUNTER = "0111" and CLOCK_COUNTER = "01111" then
                                       status <= check_final_bit;                              
                                    end if;                                                     

            when check_final_bit => if CLOCK_COUNTER = "11000" then  
                                                                        
                                       if DIN /= '1' then                                      
                                          report "Stop bit error.";                                
                                          status <= check_start_bit;
                                       else
                                          status <= reliable_data;
                                       end if;
                                    end if;                                                     
                                                                                                
            when reliable_data => status <= check_start_bit;

            when others        => status <= check_start_bit;

            end case;
         end if;
      end if;
   end process;
end behavioral;
