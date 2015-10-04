library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


library work;
use work.logpack.all;
use work.routerpack.all;

entity IndexSelector is
	Port(
		 Empty_In  : in std_logic_vector(1 downto 0);
		 Index_In  : in ind_sel_in_type;
		 counter   : in integer;
		 NopOut	   : out std_logic;
		 Index_Out : out std_logic_vector(f_log2(CHAN_NUMBER)-1 downto 0)
		);
end entity;

architecture rtl of IndexSelector is
	
begin
	
	Round_Robin_2Input : process (Empty_In, Index_In, counter)
	begin 
		if Empty_In = "00" then
			if counter = 0 then
				Index_Out <= Index_In(0);
			else
				Index_Out <= Index_In(1);
			end if;
			NopOut <= '0';
		elsif Empty_In = "10" then
			Index_Out <= Index_In(1);
			NopOut <= '0';
		elsif Empty_In = "01" then
			Index_Out <= Index_In(0);
			NopOut <= '0';
		else
			Index_Out <= (others => '0');
			NopOut <= '1';
		end if;
	end process;
end rtl;