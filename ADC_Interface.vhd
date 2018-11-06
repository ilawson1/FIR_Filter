----------------------------------------------------------------------------------

-- Company Name:   Binghamton University

-- Engineer(s):    

-- Create Date:    10/18/2016 

-- Module Name:    ADC_Interface - Behavioral 

-- Project Name:   Lab6

----------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;



entity ADC_Interface is

    Port ( clk : in  STD_LOGIC;

			  ADC_number : in std_logic_vector(2 downto 0);

           Sample : in  STD_LOGIC;

           SPI_CS : out  STD_LOGIC;

           SPI_SCLK : out  STD_LOGIC;

           SPI_MOSI : out  STD_LOGIC;

           SPI_MISO : in  STD_LOGIC;

           ADC_data_out : out  STD_LOGIC_VECTOR (11 downto 0));

end ADC_Interface;



architecture Behavioral of ADC_Interface is


	component Controller 		
		port(clk : in  STD_LOGIC;
           Sample : in  STD_LOGIC;
           Equal16 : in  STD_LOGIC;
           Equal1 : in  STD_LOGIC;
           Equal4 : in  STD_LOGIC;
			  SPI_MOSI_out : in  STD_LOGIC;
			  clr_counter : out STD_LOGIC;
           SPI_CS : out  STD_LOGIC;
           SPI_SCLK : out  STD_LOGIC;
			  SPI_MISO : in STD_LOGIC;
			  SPI_MISO_out : out STD_LOGIC;
			  SPI_MOSI : out STD_LOGIC;
           ld_counter : out  STD_LOGIC;
           control_reg : out  STD_LOGIC;
           ld_data_reg : out  STD_LOGIC;
			  ld_control_reg : out STD_LOGIC;
			  ld_ADC_out  : out STD_LOGIC);
	end component;
	
	component Datapath 		
		port(clk : in  STD_LOGIC;
			  ld_data_reg : in  STD_LOGIC;
			  SPI_MISO_IN : in STD_LOGIC;
			  ld_counter : in  STD_LOGIC;
           clr_counter : in  STD_LOGIC;
           ld_ADC_out : in  STD_LOGIC;
           Control_reg : in  STD_LOGIC;
           Equal_1 : out  STD_LOGIC;
			  Equal_4 : out  STD_LOGIC;
			  ld_control_reg : in STD_LOGIC;
			  Equal_16 : out  STD_LOGIC;
           SPI_MOSI_out : out  STD_LOGIC;
			  ADC_number	: in 	STD_LOGIC_VECTOR(2 downto 0);
           ADC_Data_out : out  STD_LOGIC_VECTOR(11 downto 0)
			  );
	end component;

	signal clr_counter, SPI_MOSI_sig, SPI_MISO_sig, ld_counter, control_reg, 
			ld_data_reg, ld_ADC_out, Equal1, Equal4, Equal16, ld_control_reg : STD_LOGIC;


begin

	Controller1 : Controller 
		port map(clk => clk,
					Sample => Sample,
					Equal1 => Equal1,
					Equal4 => Equal4,
					Equal16 => Equal16,
					clr_counter => clr_counter,
					SPI_CS => SPI_CS,
					SPI_SCLK => SPI_SCLK,
					SPI_MISO => SPI_MISO,
					SPI_MISO_out => SPI_MISO_sig,
					SPI_MOSI_out => SPI_MOSI_sig,
					SPI_MOSI => SPI_MOSI,
					ld_counter => ld_counter,
					control_reg => control_reg,
					ld_data_reg => ld_data_reg,
					ld_control_reg => ld_control_reg,
					ld_ADC_out => ld_ADC_out);
					
	Datapath1 : Datapath
		port map(clk => clk,
					ld_data_reg => ld_data_reg,
					SPI_MISO_IN => SPI_MISO,
               ld_counter => ld_counter,
               clr_counter => clr_counter,
               ld_ADC_out => ld_ADC_out,
               Control_reg => control_reg,
               Equal_1 => Equal1,
               Equal_4 => Equal4,
               Equal_16 => Equal16,
					ld_control_reg => ld_control_reg,
               SPI_MOSI_out => SPI_MOSI_sig,
               ADC_number => ADC_number,
               ADC_Data_out => ADC_Data_out);



end Behavioral;