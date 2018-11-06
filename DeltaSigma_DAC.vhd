----------------------------------------------------------------------------------
-- Company Name:   Binghamton University
-- Engineer(s):    
-- Create Date:    08:51:48 08/04/2014 
-- Design Name: 	 
-- Module Name:    DeltaSigma_DAC - Behavioral 
-- Project Name:   Lab 7
-- Revisions: 		 
--      10/21/2017 Changed the type of internal signals from std_logic_vector to
--						 unsigned to reduce the number of type conversions required.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DeltaSigma_DAC is
	Generic (MSB : integer := 11);
   Port (clk : in  STD_LOGIC;
         DAC_reset : in  STD_LOGIC;
         DAC_input : in  STD_LOGIC_VECTOR (MSB downto 0);
         DAC_output : out  STD_LOGIC);
end DeltaSigma_DAC;

architecture Behavioral of DeltaSigma_DAC is
	signal DeltaB      : unsigned(MSB+2 downto 0);
	signal Delta_Adder : unsigned(MSB+2 downto 0);
	signal Sigma_Adder : unsigned(MSB+2 downto 0);
	signal Sigma_Reg   : unsigned(MSB+2 downto 0);

begin
DeltaB <= (Sigma_Reg(MSB+2), Sigma_Reg(MSB+2), others => '0');
Delta_Adder <= unsigned(DAC_input) + unsigned(DeltaB);
Sigma_Adder <= unsigned(Delta_Adder) + unsigned(Sigma_Reg);

process(clk) 
begin 
	if rising_edge(clk) then
		if DAC_reset = '1' then
			Sigma_Reg <= ('0', '1', others => '0');
		else 
			Sigma_Reg <= Sigma_Adder;
		end if;
	end if;
end process;

process(clk)
begin
	if rising_edge(clk) then
		if DAC_reset = '1' then
			DAC_output <= '0';
		else 
			DAC_Output <= Sigma_Reg(MSB+2);
		end if;
	end if;
end process;
end Behavioral;

