-- uart.vhd: UART controller - receiving part
-- Author(s): Vladyslav Kovalets, xkoval21
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is
port(	
    CLK      : in std_logic;
	RST      : in std_logic;
	DIN      : in std_logic;
	DOUT     : out std_logic_vector(7 downto 0);
	DOUT_VLD : out std_logic
);
end UART_RX;  
-------------------------------------------------
architecture behavioral of UART_RX is
signal clock_counter        : std_logic_vector(4 downto 0);
signal bit_counter          : std_logic_vector(3 downto 0) := "0000";
signal receive_data_enable  : std_logic;
signal clock_counter_enable : std_logic;
signal dout_valid           : std_logic;
signal shift_register       : std_logic_vector(7 downto 0) := X"00";


begin

	FSM: entity work.UART_FSM(behavioral)
    port map (
        CLK 	    	     => CLK,
        RST 	    		 => RST,
        DIN 	    	     => DIN,
        CLOCK_COUNTER 	     => clock_counter,   
        BIT_COUNTER  		 => bit_counter,	  
		RECEIVE_DATA_ENABLE  => receive_data_enable ,
		CLOCK_COUNTER_ENABLE => clock_counter_enable,
		DOUT_VLD			 => dout_valid
    );

	DOUT_VLD <= dout_valid; 
	
	process(CLK) begin
		if (CLK'event and CLK = '1') then 

			if clock_counter_enable = '1' then
				clock_counter <= clock_counter+"1";
			else
				clock_counter <= "00000";
			end if;

			if receive_data_enable  = '1' then
				if clock_counter >= "01111" then
					clock_counter <= "00000";
					shift_register(6 downto 0) <= shift_register(7 downto 1);
					shift_register(7) <= DIN;
					bit_counter <= bit_counter+"1";
				end if;
			else 
				bit_counter <= "0000";
			end if;

		end if;
	end process;

	DOUT <= shift_register;

end behavioral;
