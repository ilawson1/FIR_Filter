----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:52:33 10/15/2018 
-- Design Name: 
-- Module Name:    Controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Controller is
    Port ( clk : in  STD_LOGIC;
           Sample : in  STD_LOGIC;
           Equal16 : in  STD_LOGIC;
           Equal1 : in  STD_LOGIC;
           Equal4 : in  STD_LOGIC;
			  SPI_MOSI_out : in STD_LOGIC;
			  clr_counter : out STD_LOGIC;
           SPI_CS : out  STD_LOGIC;
           SPI_SCLK : out  STD_LOGIC;
			  SPI_MISO : in STD_LOGIC;
			  SPI_MISO_out : out STD_LOGIC;
			  SPI_MOSI : out STD_LOGIC;
           ld_counter : out  STD_LOGIC;
           control_reg : out  STD_LOGIC;
           ld_data_reg : out  STD_LOGIC;
			  ld_control_reg : out  STD_LOGIC;
			  ld_ADC_out  : out STD_LOGIC);
end Controller;

architecture Behavioral of Controller is

	type state_type is (Clear,
								Delay,
								Count,
								Load2,
								Shift2,
								Wait2,
								Load3,
								Wait3,
								Shift3);
								
	-- Initialize States / Declare next_state's						
	signal state1 : state_type := Clear;
	signal state2 : state_type := Load2;
	signal state3 : state_type := Load3;
	signal next_state1, next_state2, next_state3 : state_type;
			
	signal SPI_SCLK_sig : std_logic;
	

begin
-- Clk cycle processes
	process(clk,state1)
	begin
		if rising_edge(clk) then 
			state1 <= next_state1;
		else
			state1 <= state1;
		end if;
	end process;
		
	process(clk,state2)
	begin
		if rising_edge(clk) then 
			state2 <= next_state2;
		else
			state2 <= state2;
		end if;
	end process;
	
	process(clk,state3)
	begin
		if rising_edge(clk) then 
			state3 <= next_state3;
		else
			state3 <= state3;
		end if;
	end process;

-- State1 = Shift Counter
	process(state1,Sample,Equal16)
	begin	
		clr_counter <= '0';
		SPI_CS <= '0';
		SPI_SCLK_sig <= '0';
		ld_counter <= '0';
	
		case state1 is
			when Clear =>
				clr_counter <= '1';
				SPI_CS <= '1';
				SPI_SCLK_sig <= '1';
				if Sample = '1' then
					next_state1 <= Delay;
				else
					next_state1 <= Clear;
				end if;
			
			when Delay =>
				clr_counter <= '0';
				SPI_CS <= '0';
				SPI_SCLK_sig <= '1';
				if equal16 = '1' then
					next_state1 <= Clear;
				else
					next_state1 <= Count;
				end if;
			
			when Count =>
				ld_counter <= '1';
				SPI_CS <= '0';
				SPI_SCLK_sig <= '0';
				next_state1 <= Delay;			
			
			when others =>
				next_state1 <= state1;	
		end case;
	end process;
	
-- State2 = Control Register
	process(state2,Equal1,SPI_SCLK_sig,Equal4)
	begin
		control_reg <= '0';
		ld_control_reg <= '0';
		
		case state2 is
			when Load2 =>
				control_reg <= '0';
				ld_control_reg <= '1';
				if (Equal1 = '1') and (SPI_SCLK_sig = '0') then
					next_state2 <= Shift2;
				else
					next_state2 <= Load2;
				end if;
				
			when Shift2 =>
				control_reg <= '1';
				next_state2 <= Wait2;
			
			when Wait2 =>
				if Equal4 = '1' then
					next_state2 <= Load2;
				else
					next_state2 <= Shift2;
				end if;
			
			when others =>
				next_state2 <= state2;	
		end case;
	end process;
	
-- State3 = Data Registers
	process(state3,Equal4,Equal16)
	begin
		ld_ADC_out <= '0';
		ld_data_reg <= '0';
		
		case State3 is
			when Load3 =>
				ld_ADC_out <= '1';
				if Equal4 = '1' then
					next_state3 <= Wait3;
				else
					next_state3 <= Load3;
				end if;
			
			when Wait3 =>
				next_state3 <= Shift3;
			
			when Shift3 =>
				ld_data_reg <= '1';
				if Equal16 = '1' then
					next_state3 <= Load3;
				else
					next_state3 <= Wait3;
				end if;	

			when others =>
				next_state3 <= state3;
		
		end case;	
	end process;
	
	SPI_SCLK <= SPI_SCLK_sig;
	SPI_MOSI <= SPI_MOSI_out;
	SPI_MISO_out <= SPI_MISO;
end Behavioral;

