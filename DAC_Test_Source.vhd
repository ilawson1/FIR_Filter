----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:34:31 10/22/2018 
-- Design Name: 
-- Module Name:    DAC_Test_Source - Behavioral 
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
use IEEE.NUMERIC_STD.All;

entity DAC_Test_Source is
Generic (MSB : integer := 11);
    Port ( clk : in  STD_LOGIC;
           Sample : in  STD_LOGIC;
           DAC_Test_Data : out  STD_LOGIC_VECTOR(MSB downto 0));
end DAC_Test_Source;

architecture Behavioral of DAC_Test_Source is

signal Data : std_logic_vector(MSB downto 0) := (others => '0');

begin
-- Increment
process (clk)
 begin
	if rising_edge(clk) then
		if Sample = '1' then
			Data <= std_logic_vector(unsigned(Data) +1);
		else
			Data <= Data;
		end if;
	end if;
 end process;

 DAC_test_data <= Data;


end Behavioral;

