library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;
use work.routerpack.all;
 
ENTITY tb_control_unit IS
END tb_control_unit;
 
ARCHITECTURE behavior OF tb_control_unit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component router_control_unit
    	generic(LOCAL_X : natural := 1;
    		    LOCAL_Y : natural := 1);
    	port(clk       : in  std_logic;
    		 reset     : in  std_logic;
    		 Data_In   : in  data_array_type;
    		 Empty_Out : in  std_logic_vector(CHAN_NUMBER - 1 downto 0);
    		 Full_In   : in  std_logic_vector(CHAN_NUMBER - 1 downto 0);
    		 Sdone_In  : in  std_logic_vector(CHAN_NUMBER - 1 downto 0);
    		 Sdone_Out : in  std_logic_vector(CHAN_NUMBER - 1 downto 0);
    		 Shft_In   : out std_logic_vector(CHAN_NUMBER - 1 downto 0);
    		 Wr_En_Out : out std_logic_vector(CHAN_NUMBER - 1 downto 0);
    		 Cross_Sel : out crossbar_sel_type);
    end component router_control_unit;
    
    component net_input_interface
    	generic(FIFO_LENGTH : natural := 16;
    		    DATA_WIDTH  : natural := 16);
    	port(clk      : in  std_logic;
    		 reset    : in  std_logic;
    		 Data_In  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    		 valid    : in  std_logic;
    		 shft     : in  std_logic;
    		 sdone    : out std_logic;
    		 ack      : out std_logic;
    		 full     : out std_logic;
    		 empty    : out std_logic;
    		 Data_Out : out std_logic_vector(DATA_WIDTH - 1 downto 0));
    end component net_input_interface;
    
    component net_output_interface
    	generic(FIFO_LENGTH : natural := 16;
    		    DATA_WIDTH  : natural := 16);
    	port(clk      : in  std_logic;
    		 reset    : in  std_logic;
    		 Data_In  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    		 ack      : in  std_logic;
    		 wren     : in  std_logic;
    		 sdone    : out std_logic;
    		 full     : out std_logic;
    		 empty    : out std_logic;
    		 valid    : out std_logic;
    		 Data_Out : out std_logic_vector(DATA_WIDTH - 1 downto 0));
    end component net_output_interface;
    
	constant LOCAL_X : natural := 1;
	constant LOCAL_Y : natural := 1; 
   --Inputs
   signal clk, reset : std_logic := '0';
   
   signal Data_In :  data_array_type := (others => (others => '0'));
   signal Empty_Out, Full_In, Sdone_In, Sdone_Out, Shft_In, Wr_En_Out :  std_logic_vector(CHAN_NUMBER - 1 downto 0) := (others => '0');
   signal Cross_Sel : crossbar_sel_type := (others => (others => '0'));
	
   signal ii_data_out :  data_array_type := (others => (others => '0'));	
   signal ii_shft_vector : std_logic_vector(CHAN_NUMBER-1 downto 0) := (others => '0');
   signal ii_sdone_vector : std_logic_vector(CHAN_NUMBER-1 downto 0) := (others => '0');
   signal ii_full_vector :  std_logic_vector(CHAN_NUMBER-1 downto 0) := (others => '0');
   signal ii_empty_vector :  std_logic_vector(CHAN_NUMBER-1 downto 0) := (others => '0');
   signal ii_valid_in :  std_logic_vector(CHAN_NUMBER-1 downto 0) := (others => '0');
   signal ii_ack_out :  std_logic_vector(CHAN_NUMBER-1 downto 0) := (others => '0');
   
   -- Output Interface Signals
   signal oi_wren_vector : std_logic_vector(CHAN_NUMBER-1 downto 0) := (others => '0');
   signal oi_sdone_vector : std_logic_vector(CHAN_NUMBER-1 downto 0) := (others => '0');
   signal oi_full_vector :  std_logic_vector(CHAN_NUMBER-1 downto 0) := (others => '0');
   signal oi_empty_vector :  std_logic_vector(CHAN_NUMBER-1 downto 0) := (others => '0');
   signal oi_ack_vector :  std_logic_vector(CHAN_NUMBER-1 downto 0) := (others => '0');
   signal oi_valid_vector :  std_logic_vector(CHAN_NUMBER-1 downto 0) := (others => '0');
   signal Data_Out  :  data_array_type := (others => (others => '0'));
	
	-- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
 	Input_Interface_GEN : for i in 0 to CHAN_NUMBER-1 generate 
	 	InputInterfaceX : net_input_interface
			generic map(
				FIFO_LENGTH => FIFO_LENGTH,
				DATA_WIDTH  => DATA_WIDTH
			)
			port map(
				clk      => clk,
				reset    => reset,
				Data_In  => Data_In(i),
				valid    => ii_valid_in(i),
				shft     => ii_shft_vector(i),
				sdone    => ii_sdone_vector(i),
				ack      => ii_ack_out(i),
				full     => ii_full_vector(i),
				empty    => ii_empty_vector(i),
				Data_Out => ii_data_out(i)
			);
	end generate;
	
	Output_Interface_GEN : for i in 0 to CHAN_NUMBER-1 generate
  		OutputInterfaceX : net_output_interface
  			generic map(
  				FIFO_LENGTH => FIFO_LENGTH,
  				DATA_WIDTH  => DATA_WIDTH
  			)
  			port map(
  				clk      => clk,
  				reset    => reset,
  				Data_In  => Data_In(i),
  				ack      => oi_ack_vector(i),
  				wren     => oi_wren_vector(i),
  				sdone    => oi_sdone_vector(i),
  				full     => oi_full_vector(i),
  				empty    => oi_empty_vector(i),
  				valid    => oi_valid_vector(i),
  				Data_Out => Data_Out(i)
  			);	 
    end generate;
 
	-- Instantiate the Unit Under Test (UUT)
   uut: router_control_unit
   	generic map(
   		LOCAL_X => LOCAL_X,
   		LOCAL_Y => LOCAL_Y
   	)
   	port map(
   		clk       => clk,
   		reset     => reset,
   		Data_In   => ii_data_out,
   		Empty_Out => ii_empty_vector,
   		Full_In   => ii_full_vector,
   		Sdone_In  => ii_sdone_vector,
   		Sdone_Out => oi_sdone_vector,
   		Shft_In   => ii_shft_vector,
   		Wr_En_Out => oi_wren_vector,
   		Cross_Sel => Cross_Sel
   	);
 
   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
   	-- hold reset state for 100 ns.
   	  reset <= '1';
   	  Data_In(LOCAL_ID) <= x"D000"; -- Local ha un pacchetto per X=3 Y=1 
   	  Data_In(NORTH_ID) <= x"9000"; -- North X=2 Y=1
   	  Data_In(EAST_ID)  <= x"5000"; -- East X=1 Y=1 (questo nodo)
   	  Data_In(WEST_ID)  <= x"7000"; -- West X=1 Y=3
   	  Data_In(SOUTH_ID) <= x"F000"; -- South X=3 Y=3
    	  
      wait for 100 ns;	
	  reset <= '0';
	  ii_valid_in(LOCAL_ID) <= '1';
	  
	  wait until ii_ack_out (LOCAL_ID) = '1';
	  ii_valid_in(LOCAL_ID) <= '0';
	  
	  wait for clk_period;
	  ii_valid_in(NORTH_ID) <= '1';
	  
	  wait until ii_ack_out (NORTH_ID) = '1';
	  ii_valid_in(NORTH_ID) <= '0';
	  
	  wait for clk_period;
	  ii_valid_in(EAST_ID) <= '1';
	  
	  wait until ii_ack_out (EAST_ID) = '1';
	  ii_valid_in(EAST_ID) <= '0';
	  
	  wait for clk_period;
	  ii_valid_in(WEST_ID) <= '1';
	  
	  wait until ii_ack_out (WEST_ID) = '1';
	  ii_valid_in(WEST_ID) <= '0';
	  
	  wait for clk_period;
	  ii_valid_in(SOUTH_ID) <= '1';
	  
	  wait until ii_ack_out (SOUTH_ID) = '1';
	  ii_valid_in(SOUTH_ID) <= '0';

      wait;
   end process;

END;