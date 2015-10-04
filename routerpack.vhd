library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;

package routerpack is

	-- Mesh dimensions
	constant ROW_LENGTH : natural := 4;
	constant COL_LENGTH : natural := 4;

	-- Router constants		 
	constant CHAN_NUMBER : natural := 5;
	constant LOCAL_ID : natural := 0;
	constant NORTH_ID : natural := 1;
	constant EAST_ID  : natural := 2;
	constant WEST_ID  : natural := 3;
	constant SOUTH_ID : natural := 4;
	constant ADDRESS_LENGTH : natural := f_log2(ROW_LENGTH);
	
	constant FIFO_LENGTH : natural := 16;
	constant DATA_WIDTH : natural := 16;
	
	-- Router Type
	type data_array_type is array (0 to CHAN_NUMBER-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
	
	-- Crossbar Type
	type crossbar_sel_type is array (0 to CHAN_NUMBER-1) of std_logic_vector(f_log2(CHAN_NUMBER)-1 downto 0);
	
	-- Control Unit Type
	type ind_sel_in_type is array (0 to 1) of std_logic_vector(f_log2(CHAN_NUMBER)-1 downto 0);

end routerpack;

package body routerpack is



end routerpack;