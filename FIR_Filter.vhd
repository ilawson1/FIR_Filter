library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- package declaration for FIR_Coeff_type
package DSDtypes_pkg is
	type FIR_Coeff_type is array (natural range <>) of unsigned(11 downto 0);
end package DSDtypes_pkg;

-- FIR_Filter behavioral description
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DSDtypes_pkg.all; -- use package defined abpve

entity FIR_Filter is
	Generic (Coeff : FIR_Coeff_type; N : positive := 12);
	Port ( clk : in STD_LOGIC;
		Sample : in STD_LOGIC;
		X : in STD_LOGIC_VECTOR (N-1 downto 0);
		Y : out STD_LOGIC_VECTOR (N-1 downto 0));
end FIR_Filter;

architecture Behavioral of FIR_Filter is

signal xt0,xt1,xt2,Y_out : unsigned(N-1 downto 0) := (others => '0');
signal ResultFin,ResultPre,Add2,Add1,Add0 : unsigned(((2*N)-1) downto 0) := (others => '0');


begin
	process(clk)
	begin
		if rising_edge(clk) then
			if Sample = '1' then
				xt0 <= unsigned(X); 
				xt1 <= xt0;
				xt2 <= xt1;
			else 
				xt0 <= xt0;
				xt1 <= xt1;
				xt2 <= xt2;
			end if;
		end if;
	end process;
Add0 <= xt0*Coeff(0);
Add1 <= xt1*Coeff(1);
Add2 <= xt2*Coeff(2);

ResultPre <= Add0 + Add1;
ResultFin <= ResultPre + Add2;

	process(clk)
	begin
		if rising_edge(clk) then
			if Sample = '1' then
				Y_out <= ResultFin(ResultFin'length-1 downto ResultFin'length-Y_out'length); 
			else 
				Y_out <= Y_out;
			end if;
		end if;
	end process;

Y <= STD_LOGIC_VECTOR(Y_out);
		
end Behavioral;