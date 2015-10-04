-- Quartus II VHDL Template
-- Signed Adder

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.routerpack.all;
use work.logpack.all;

entity mux_n is
	Port(
		sel	 : in std_logic_vector(f_log2(CHAN_NUMBER)-1 downto 0);
		Data_In : in data_array_type;
		Data_Out : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end entity;

architecture rtl of mux_n is

begin
	
		Data_Out <= Data_In(conv_integer(sel));

end rtl;