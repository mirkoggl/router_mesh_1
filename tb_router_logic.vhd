library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;
use work.routerpack.all;
 
ENTITY tb_router_logic IS
END tb_router_logic;
 
ARCHITECTURE behavior OF tb_router_logic IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT routing_logic_xy is
		Generic (
			DATA_WIDTH : natural := 16;
			LOCAL_X : natural := 1;
			LOCAL_Y : natural := 1
		);
		Port (
			Data_In    : in std_logic_vector(DATA_WIDTH-1 downto 0);
			In_Channel : in std_logic_vector (f_log2(CHAN_NUMBER)-1 downto 0);
			crossbar_sel : out crossbar_sel_type		
		);
    END COMPONENT;
    
	constant	DATA_WIDTH : natural := 16;
	constant LOCAL_X : natural := 1;
	constant LOCAL_Y : natural := 1; 
   --Inputs
   signal Data_In :  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
   signal In_Channel : std_logic_vector (f_log2(CHAN_NUMBER)-1 downto 0) := (others => '0');
   signal crossbar_sel : crossbar_sel_type := (others => (others => '0'));
	
	alias X_dest : std_logic_vector is Data_In(DATA_WIDTH-1 downto DATA_WIDTH-ADDRESS_LENGTH);
	alias Y_dest : std_logic_vector is Data_In(DATA_WIDTH-ADDRESS_LENGTH-1 downto DATA_WIDTH-2*ADDRESS_LENGTH);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: routing_logic_xy PORT MAP (
          Data_In => Data_In,
          In_Channel => In_Channel,
          crossbar_sel => crossbar_sel
        );
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		X_dest <= conv_std_logic_vector(2, ADDRESS_LENGTH);
		Y_dest <= conv_std_logic_vector(2, ADDRESS_LENGTH);
		In_Channel <= "001";
		
		wait for 10 ns;
		X_dest <= conv_std_logic_vector(3, ADDRESS_LENGTH);
		Y_dest <= conv_std_logic_vector(1, ADDRESS_LENGTH);
		In_Channel <= "010";
		
		wait for 10 ns;
		X_dest <= conv_std_logic_vector(1, ADDRESS_LENGTH);
		Y_dest <= conv_std_logic_vector(1, ADDRESS_LENGTH);
		In_Channel <= "011";
		
		wait for 10 ns;
		X_dest <= conv_std_logic_vector(1, ADDRESS_LENGTH);
		Y_dest <= conv_std_logic_vector(2, ADDRESS_LENGTH);
		In_Channel <= "101";

      -- insert stimulus here 

      wait;
   end process;

END;
