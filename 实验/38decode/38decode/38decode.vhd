--EN - SW0
--A - SW3
--B - SW2
--C - SW1

-- new (only one EN)
library IEEE;
use IEEE.STD_LOGIC_1164.all;

ENTITY decode38 IS
	PORT( A,B,C	  : in STD_LOGIC;
		  EN 	  : in STD_LOGIC;	-- low effect
		  Y		  : out STD_LOGIC_VECTOR (7 downto 0)
	);
END decode38;

ARCHITECTURE behavious OF decode38 IS
	signal e_all:STD_LOGIC;
	signal z:STD_LOGIC_VECTOR(2 downto 0);
BEGIN
	z <= (A,B,C);
	process (z,EN)
	begin
		if (EN = '0') then
			case z is
				when "000" => Y <= "00000001";
				when "001" => Y <= "00000010";
				when "010" => Y <= "00000100";
				when "011" => Y <= "00001000";
				when "100" => Y <= "00010000";
				when "101" => Y <= "00100000";
				when "110" => Y <= "01000000";
				when "111" => Y <= "10000000";
				when others => Y <= "11111111";
		  end case;
		else
			Y <= (others => '0');	--  from 'Z' to '0'
		end if;
	end process;
END behavious;