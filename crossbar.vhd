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

entity crossbar is
	Port(
		sel	   : in crossbar_sel_type;
		Data_In  : in data_array_type;
		Data_Out : out data_array_type
	);
end entity;

architecture rtl of crossbar is

	component mux_n
		Port(
			sel	 : in std_logic_vector(f_log2(CHAN_NUMBER)-1 downto 0);
			Data_In : in data_array_type;
			Data_Out : out std_logic_vector(DATA_WIDTH-1 downto 0)
		);
	end component;

begin
	
	GEN_MUX : for i in 0 to CHAN_NUMBER-1 generate
      MuxX : mux_n Port Map(
			sel => sel(i), 
			Data_In => Data_In, 
			Data_out => Data_Out(i)
		);
   end generate GEN_MUX;

end rtl;