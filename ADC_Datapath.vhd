----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Tyler McHugh & Isaac Lawson-Hughes
-- 
-- Create Date:    22:27:21 10/07/2018 
-- Design Name: 
-- Module Name:    Datapath - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

entity Datapath is
    Port ( clk : in STD_LOGIC;
			  ld_data_reg : in  STD_LOGIC;
			  SPI_MISO_IN : in STD_LOGIC;
			  ld_counter : in  STD_LOGIC;
           clr_counter : in  STD_LOGIC;
           ld_ADC_out : in  STD_LOGIC;
           Control_reg : in  STD_LOGIC;
           Equal_1 : out  STD_LOGIC;
			  Equal_4 : out  STD_LOGIC;
			  Equal_16 : out  STD_LOGIC;
			  ld_control_reg : in 	STD_LOGIC;
           SPI_MOSI_out : out  STD_LOGIC;
			  ADC_number	: in 	STD_LOGIC_VECTOR(2 downto 0);
           ADC_Data_out : out  STD_LOGIC_VECTOR(11 downto 0));
end Datapath;

architecture Behavioral of Datapath is

signal Q_data, ADC_data_reg : STD_LOGIC_VECTOR(11 downto 0) := x"000";
signal D_control, Q_control : STD_LOGIC_VECTOR(3 downto 0) := x"0";
signal Q_counter : STD_LOGIC_VECTOR(4 downto 0) := "00000";

begin

process(clk)
	begin
		if rising_edge(clk) then
			if ld_data_reg = '1' then
				Q_data <= Q_data(10 downto 0) & SPI_MISO_IN;
			end if;
		end if;
end process;

process(clk)
	begin
		if rising_edge(clk) then
			if clr_counter = '1' then
				Q_counter <= "00000";
			elsif ld_counter = '1' then
				Q_counter <= std_logic_vector(unsigned(Q_counter) + 1);
			else
				Q_counter <= Q_counter;
			end if;
		end if;	
end process;

process(clk,Control_reg)
	begin
		if rising_edge(clk) then
			if ld_control_reg = '1' then
				Q_control <= '0' & ADC_number;
			elsif Control_reg = '1' then
					Q_control <= Q_control(2 downto 0) & '0';
			else
			Q_control <= Q_control;
				end if;
		end if;
end process;

process(clk,Q_counter)
	begin
		if Q_counter = "10000" then
			Equal_16 <= '1';
			Equal_1 <= '0';
			Equal_4 <= '0';
		elsif Q_counter = "00001" then
			Equal_1 <= '1';
			Equal_16 <= '0';
			Equal_4 <= '0';
		elsif Q_counter = "00100" then
			Equal_4 <= '1';
			Equal_16 <= '0';
			Equal_1 <= '0';
		else
			Equal_16 <= '0';
			Equal_1 <= '0';
			Equal_4 <= '0';
		end if;
end process;

process(clk,ld_ADC_out)
	begin
		if rising_edge(clk) then
			if ld_ADC_out = '1' then
				ADC_data_reg <= Q_data;
			else 
				ADC_data_reg <= ADC_data_reg;
			end if;
		end if;
end process;

ADC_data_out <= ADC_data_reg;
SPI_MOSI_out <= Q_control(3);

end Behavioral;
