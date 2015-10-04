library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;
use work.routerpack.all;
   
entity router_control_unit is
	Generic (
		LOCAL_X : natural := 1;
		LOCAL_Y : natural := 1
	);
	Port (
		clk   : in std_logic;
		reset : in std_logic;
		Data_In : in data_array_type;
		Empty_Out : in std_logic_vector(CHAN_NUMBER-1 downto 0);
		Full_In   : in std_logic_vector(CHAN_NUMBER-1 downto 0);
		Sdone_In  : in std_logic_vector(CHAN_NUMBER-1 downto 0);
		Sdone_Out : in std_logic_vector(CHAN_NUMBER-1 downto 0);
		
		Shft_In   : out std_logic_vector(CHAN_NUMBER-1 downto 0);
		Wr_En_Out : out std_logic_vector(CHAN_NUMBER-1 downto 0);
		Cross_Sel : out crossbar_sel_type	
	);
end entity router_control_unit;

architecture RTL of router_control_unit is
		
	COMPONENT routing_logic_xy
		Generic(
			LOCAL_X    : natural := 1;
			LOCAL_Y    : natural := 1
		);
		Port(
			Data_In      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			In_Channel   : in  std_logic_vector(f_log2(CHAN_NUMBER) - 1 downto 0);
			crossbar_sel : out crossbar_sel_type
		);
	END COMPONENT routing_logic_xy;
	
	constant zeros_vector : std_logic_vector(CHAN_NUMBER-1 downto 0) := (others => '0');
	type state_type is (idle, store_local, out_local, out_delay); 
	
	-- Control Unit Signals
	signal current_s : state_type := idle;
	signal xy_data_in : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal xy_chan_in : std_logic_vector(f_log2(CHAN_NUMBER) - 1 downto 0) := (others => '0');
	
begin
	
	XY_logic : routing_logic_xy
		Generic Map(
			LOCAL_X    => LOCAL_X,
			LOCAL_Y    => LOCAL_Y
		)
		Port Map(
			Data_In      => xy_data_in,
			In_Channel   => xy_chan_in,
			crossbar_sel => Cross_Sel
		);
	
	CU_process : process (clk, reset)
	begin
		if reset = '1' then
			current_s <= idle;
			Wr_En_Out <= (others => '0');
			Shft_In <= (others => '0');
		
		elsif rising_edge(clk) then		
			
			Shft_In <= (others => '0');
			Wr_En_Out <= (others => '0');
			
		    case current_s is
		     when idle =>       
			    if Empty_Out(LOCAL_ID) = '0' then
			    	current_s <= store_local;
			    	xy_data_in <= Data_In(LOCAL_ID);
			    	xy_chan_in <= CONV_STD_LOGIC_VECTOR(LOCAL_ID, f_log2(CHAN_NUMBER));
			    elsif Empty_Out(NORTH_ID) = '0' then
			    	current_s <= store_local;
			    	xy_data_in <= Data_In(NORTH_ID);
			    	xy_chan_in <= CONV_STD_LOGIC_VECTOR(NORTH_ID, f_log2(CHAN_NUMBER));
			    elsif Empty_Out(EAST_ID) = '0' then
			    	current_s <= store_local;
			    	xy_data_in <= Data_In(EAST_ID);
			    	xy_chan_in <= CONV_STD_LOGIC_VECTOR(EAST_ID, f_log2(CHAN_NUMBER));
			    elsif Empty_Out(WEST_ID) = '0' then
			    	current_s <= store_local;
			    	xy_data_in <= Data_In(WEST_ID);
			    	xy_chan_in <= CONV_STD_LOGIC_VECTOR(WEST_ID, f_log2(CHAN_NUMBER));
			    elsif Empty_Out(SOUTH_ID) = '0' then	
			    	current_s <= store_local;
			    	xy_data_in <= Data_In(SOUTH_ID);
			    	xy_chan_in <= CONV_STD_LOGIC_VECTOR(SOUTH_ID, f_log2(CHAN_NUMBER));
			    else 
			    	current_s <= idle;
			    end if;
			    
			when store_local =>
				if Sdone_In(CONV_INTEGER(xy_chan_in)) = '1' then
					current_s <= out_local;
				else
					Shft_In(CONV_INTEGER(xy_chan_in)) <= '1';
					current_s <= store_local;
				end if;
				
			when out_local =>	
				if Sdone_Out(CONV_INTEGER(xy_chan_in)) = '1' then
					current_s <= idle;
				else
					current_s <= out_delay;
					Wr_En_Out(CONV_INTEGER(xy_chan_in)) <= '1';	
				end if;
			
			when out_delay => 
				current_s <= out_local;
						    
			end case;
		
		end if;
	end process;
	
end architecture RTL;
