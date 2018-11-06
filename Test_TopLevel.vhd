----------------------------------------------------------------------------------
-- Company Name:  Binghamton University
-- Engineer(s):   Carl Betcher
-- Create Date:   11/3/2016 
-- Module Name:   Test_TopLevel.vhd
-- Project Name:  Lab8
-- Revisions:		10/24/2018  Added second channel of audio
-- VHDL Test Bench Created by ISE for module: TopLevel
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
use work.DSDtypes_pkg.all;

ENTITY Test_TopLevel IS
END Test_TopLevel;
 
ARCHITECTURE behavior OF Test_TopLevel IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
	 COMPONENT TopLevel
	 generic (DAC_MSB : positive := 11; -- Sets MSB of DAC input
	          N       : positive := 1600); -- Divide By value for sample rate
				-- N = 64	 -- 500k samples/sec using 32 MHz osc, For simulation
				--	N = 16000 --   2k samples/sec using 32 MHz osc, Papilio w/1kHz RC LPF
				-- N = 1600  --  20k samples/sec using 32 MHz osc, Papilio w/10kHz RC LPF
	 PORT(
			  Osc_Clk : in STD_LOGIC;
			  Switch : in  STD_LOGIC_VECTOR (7 downto 4);
			  LED : out  STD_LOGIC_VECTOR (7 downto 0);
			  Seg7_SEG : out STD_LOGIC_VECTOR (6 downto 0); 
			  Seg7_DP  : out STD_LOGIC; 
			  Seg7_AN  : out STD_LOGIC_VECTOR (4 downto 0);
			  SPI_SCLK : out STD_LOGIC;
			  SPI_MISO : in STD_LOGIC; 
			  SPI_MOSI : out STD_LOGIC; 
			  SPI_CS : out STD_LOGIC;
			  Audio_L : out STD_LOGIC;
			  Audio_R : out STD_LOGIC
			);
 	END COMPONENT;

   --Inputs
   signal Osc_Clk : std_logic := '0';
   signal Switch : std_logic_vector(7 downto 4) := (others => '0');
 	--Outputs
   signal LED : std_logic_vector(7 downto 0);
   signal Seg7_SEG : std_logic_vector(6 downto 0);
   signal Seg7_DP : std_logic;
   signal Seg7_AN : std_logic_vector(4 downto 0);
	signal Audio_L : std_logic;
	signal Audio_R : std_logic;
   --ADC I/O
	signal SPI_SCLK : std_logic;
	signal SPI_MISO : std_logic := '0';
	signal SPI_MOSI : std_logic := '0';
	signal SPI_CS : std_logic;
	-- Clock period definitions
   constant Osc_Clk_period : time := 31.25 ns;
	
	-- constants defining the sample values for one cycle of sinusoids of 
	-- 	different frequencies
	signal N : natural;
	constant num_cycles : positive := 5;
	type sample_type is array (natural range <>) of std_logic_vector(11 downto 0);
	constant f_is_Fs_over_20 : sample_type := 
		  ((x"000"),(x"064"),(x"187"),(x"34C"),(x"586"),
		   (x"7FF"),(x"A78"),(x"CB2"),(x"E77"),(x"F9A"),
		   (x"FFF"),(x"F9A"),(x"E77"),(x"CB2"),(x"A78"),
			(x"7FF"),(x"586"),(x"34C"),(x"187"),(x"064"));
	constant f_is_Fs_over_11 : sample_type := 
		  ((x"052"),(x"2C2"),(x"6DC"),(x"B52"),(x"EB9"),
		   (x"FFF"),(x"EB9"),(x"B52"),(x"6DC"),(x"2C2"),
			(x"052"));
	constant f_is_Fs_over_10 : sample_type := 
		  ((x"000"),(x"187"),(x"586"),(x"A78"),(x"E77"),
		   (x"FFF"),(x"E77"),(x"A78"),(x"586"),(x"187"));
	constant f_is_Fs_over_9  : sample_type := 
		  ((x"07B"),(x"3FF"),(x"963"),(x"E1F"),(x"FFF"),
		   (x"E1F"),(x"963"),(x"3FF"),(x"07B"));
	constant f_is_Fs_over_8  : sample_type := 
		  ((x"000"),(x"257"),(x"7FF"),(x"DA7"),(x"FFF"),
		   (x"DA7"),(x"7FF"),(x"257"));
	constant f_is_Fs_over_5  : sample_type := 
		  ((x"187"),(x"A78"),(x"FFF"),(x"A78"),(x"187"));

BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: TopLevel 
	GENERIC MAP ( N => 64 )
	PORT MAP (
          Osc_Clk => Osc_Clk,
          Switch => Switch,
          LED => LED,
          Seg7_SEG => Seg7_SEG,
          Seg7_DP => Seg7_DP,
          Seg7_AN => Seg7_AN,
			 SPI_SCLK => SPI_SCLK,
			 SPI_MISO => SPI_MISO,
			 SPI_MOSI => SPI_MOSI,
			 SPI_CS => SPI_CS,
			 Audio_L => Audio_L,
			 Audio_R => Audio_R
        );

   -- Clock process definitions
   Osc_Clk_process :process
   begin
		Osc_Clk <= '0';
		wait for Osc_Clk_period/2;
		Osc_Clk <= '1';
		wait for Osc_Clk_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
	
	-- Procedure to generate serial data stream from ADC for one sample
	procedure Gen_ADC_data (data : in std_logic_vector(11 downto 0)) is
	begin
		-- Wait for ADC_CS falling edge
		wait until falling_edge(SPI_CS);
		-- Set ADC data to zero
		SPI_MISO <= '0';
		-- Output 4 consecutive zeros on SPI_MISO
		-- Sync'd to falling edge of SPI_SCLK
		for i in 1 to 4 loop
			wait until falling_edge(SPI_SCLK);
		end loop;
		-- Output 12 consecutive bits of an ADC sample on SPI_MISO
		-- Sync'd to falling edge of SPI_SCLK
		for i in 11 downto 0 loop
			wait until falling_edge(SPI_SCLK);
			wait for 17 ns;  -- tDACC = 17 ns typical, 27 ns max.
			SPI_MISO <= data(i);           
		end loop;
		-- set ADC data to zero
		wait until rising_edge(SPI_CS);
		SPI_MISO <= '0';
	end procedure;
	
   begin		
      -- insert stimulus here
		Switch(7 downto 4) <= "0110";  -- DAC uses FIR filter output
		
		-- input is impulse
		for i in 2 downto 0 loop
			Gen_ADC_data(x"000");  -- zero samples before impulse
		end loop;
		Gen_ADC_data(x"FFF");     -- one full scale sample generates the impulse
		for i in 10 downto 0 loop
			Gen_ADC_data(x"000");  -- zero samples after impulse
		end loop;

--		-- input is step
--		for i in 2 downto 0 loop
--			Gen_ADC_data(x"000");  -- zero samples before step
--		end loop;
--		for i in 10 downto 0 loop
--			Gen_ADC_data(x"FFF");  -- step (really a pulse)
--		end loop;

		-- generate sinewave ADC samples
		report "Begin sine(Fs/20)";
		N <= 20;						  -- ADC Samples are sine(Fs/20) 
		wait for osc_clk_period;	
		for i in 0 to (num_cycles*N) loop
			Gen_ADC_data(f_is_Fs_over_20(i mod N)); 
		end loop;
		
		report "Begin sine(Fs/10)";
		N <= 10;						  -- ADC Samples are sine(Fs/10) 
		wait for osc_clk_period;  
		for i in 0 to (num_cycles*N) loop
			Gen_ADC_data(f_is_Fs_over_10(i mod N)); 
		end loop;
		
		report "Begin sine(Fs/5)";
		N <= 5;						  -- ADC Samples are sine(Fs/5)
		wait for osc_clk_period;	
		for i in 0 to (num_cycles*N) loop
			Gen_ADC_data(f_is_Fs_over_5(i mod N)); 
		end loop;
		
      wait;
   end process;

END;