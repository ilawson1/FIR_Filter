----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer: Isaac Lawson-Hughes & Tyler McHugh		 
-- 
-- Module Name:    HEXon7segDisp - Behavioral 
-- Project Name:   Lab3 - 7-Segment Display Controller
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HEXon7segDisp is
    Port ( hex_data_in0 : in  STD_LOGIC_VECTOR (3 downto 0);
           hex_data_in1 : in  STD_LOGIC_VECTOR (3 downto 0);
           hex_data_in2 : in  STD_LOGIC_VECTOR (3 downto 0);
           hex_data_in3 : in  STD_LOGIC_VECTOR (3 downto 0);
           dp_in : in  STD_LOGIC_VECTOR (2 downto 0);
           seg_out : out  STD_LOGIC_VECTOR (6 downto 0);
           an_out : out  STD_LOGIC_VECTOR (3 downto 0);
           dp_out : out  STD_LOGIC;
           clk : in  STD_LOGIC);
end HEXon7segDisp;

architecture Behavioral of HEXon7segDisp is

	signal Counter : unsigned (10 downto 0) := (others => '0') ;
		alias MuxSel1 : unsigned (1 downto 0) is Counter(10 downto 9);
		alias MuxSel2 : unsigned (3 downto 0) is Counter(10 downto 7);
	signal HexSel : std_logic_vector (3 downto 0):= (others => '0') ;

begin

	-- Create an upcounter "cntr"
	process(clk)
	begin
		if rising_edge(clk) then
			Counter <= Counter + 1;
		end if;
	end process;


	-- Create a mux which selects one of the hex data inputs according 
	-- to the value of MuxSel1
	-- Code using process with case statement:
	process(MuxSel1,hex_data_in0,hex_data_in1,hex_data_in2,hex_data_in3)
	begin
		case MuxSel1 is 
			when "00" => HexSel <= hex_data_in0;
			when "01" => HexSel <= hex_data_in1;
			when "10" => HexSel <= hex_data_in2;
			when "11" => HexSel <= hex_data_in3;
			when others => HexSel <= "0000";
		end case;
	end process;
	 
	-- Create a mux that will enable one of the anodes. 
	-- Enable the anode of the digit to be displayed as selected by MuxSel2.
	-- A zero enables the respective anode.
	process(MuxSel2)
	begin
		case MuxSel2 is
			when "0000" | "0011" | "0100" | "0111" | "1000" | "1011" 
					| "1100" | "1111" => an_out <= "1111";
			when "0001" | "0010" => an_out <= "1110";
			when "0101" | "0110" => an_out <= "1101";
			when "1001" | "1010" => an_out <= "1011";
			when "1101" | "1110" => an_out <= "0111";
			when others => an_out <= "1111";
		end case;
	end process;
	

	-- Create combinational logic to convert a four-bit hex character 
	-- value to a 7-segment vector, seg_out.  
	-- Map HEX character of selected data (in the HexSel register) 
	-- to value of seg_out using the following segment encoding:
	--      A
	--     ---  
	--  F |   | B
	--     ---  <- G
	--  E |   | C
	--     ---
	--      D
	-- seg_out has the order "GFEDCBA"	
	-- a zero lights the segment
	-- e.g. "1111001" lights segments B and C which is a "1"
	with HexSel select
		seg_out	<= "1000000" when "0000", -- 0
						"1111001" when "0001", -- 1
						"0100100" when "0010", -- 2
						"0110000" when "0011", -- 3
						"0011001" when "0100", -- 4
						"0010010" when "0101", -- 5
						"0000010" when "0110", -- 6
						"1111000" when "0111", -- 7
						"0000000" when "1000", -- 8
						"0010000" when "1001", -- 9
						"0001000" when "1010", -- A
						"0000011" when "1011", -- b
						"0100111" when "1100", -- C
						"0100001" when "1101", -- d
						"0000110" when "1110", -- E
						"0001110" when "1111"; -- F

						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
			
	-- Create combinational logic to enable the selected decimal point. 
	-- Enable the dp_out (enabled is '0') if selected by dp_in
	-- and only when its respective anode is enabled according to the
	-- value of MuxSel2
	-- dp_in    display
	-- "000"    8 8 8 8
	-- "001"    8.8 8 8	
	-- "010"    8 8.8 8	
	-- "011"    8 8 8.8	
	-- "100"    8 8 8 8.	
	process(MuxSel2,dp_in)
	begin
		case MuxSel2 is
			when "0001" | "0010" =>
				if dp_in = "001" then
					dp_out <= '0';
				else
					dp_out <= '1';
				end if;
			when "0100" | "0101" =>
				if dp_in = "010" then
					dp_out <= '0';
				else
					dp_out <= '1';
				end if;
			when "1001" | "1010" =>
				if dp_in = "011" then
					dp_out <= '0';
				else
					dp_out <= '1';
				end if;
			when "1101" | "1110" =>
				if dp_in = "100" then
					dp_out <= '0';
				else
					dp_out <= '1';
				end if;
			when others =>
				dp_out <= '1';
		end case;
	end process;
end Behavioral ;