library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;

 
ENTITY tbc_in_out IS
END tbc_in_out;
 
ARCHITECTURE behavior OF tbc_in_out IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT net_output_interface is
		Generic (
			FIFO_LENGTH : natural := 16;
			DATA_WIDTH : natural := 16
		);
		Port (
			clk : in std_logic;
			reset : in std_logic;
			
			Data_In : in std_logic_vector(DATA_WIDTH-1 downto 0);
			ack   : in std_logic;
			wren  : in std_logic;
			
			sdone : out std_logic;
			full  : out std_logic;
			empty : out std_logic;
			valid : out std_logic;
			Data_Out : out std_logic_vector(DATA_WIDTH-1 downto 0)
		);
    END COMPONENT;
	 
	 COMPONENT net_input_interface is
		Generic (
			FIFO_LENGTH : natural := 16;
			DATA_WIDTH : natural := 16
		);
		Port (
			clk : in std_logic;
			reset : in std_logic;
			
			Data_In : in std_logic_vector(DATA_WIDTH-1 downto 0);
			valid   : in std_logic;
			shft	  : in std_logic;
			
			sdone : out std_logic;
			ack   : out std_logic;
			full  : out std_logic;
			empty : out std_logic;
			Data_Out : out std_logic_vector(DATA_WIDTH-1 downto 0)
		);
    END COMPONENT;
    
   constant FIFO_LENGTH : natural := 16;
   constant DATA_WIDTH : natural := 16;
	
   --Inputs
   signal clk, reset, valid, wren, ack, shft, full_in, full_out, empty_in, empty_out, sdone_in, sdone_out : std_logic := '0';
   signal Data_In, data_bus, Data_Out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

 	--Outputs

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN

	 uut_in: net_input_interface PORT MAP (
          clk => clk,
          reset => reset,
          Data_In => data_bus,
          valid => valid,
          shft => shft,
			 sdone => sdone_in,
          ack => ack,
          full => full_in,
          empty => empty_in,
          Data_Out => Data_Out
        );
 
	-- Instantiate the Unit Under Test (UUT)
   uut_out: net_output_interface PORT MAP (
          clk => clk,
          reset => reset,
          Data_In => Data_In,
          valid => valid,
          wren => wren,
			 sdone => sdone_out,
          ack => ack,
          full => full_out,
          empty => empty_out,
          Data_Out => data_bus
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
   	  
      wait for 100 ns;	
	   reset <= '0';
		wren <= '1';
		Data_In <= x"0001";
		
		wait until ack = '1';
		Data_In <= x"0002";
		
		wait until ack = '1';
		Data_In <= x"0003";
		
		wait until ack = '1';
		Data_In <= x"0004";
		
		wait until ack = '1';
		Data_In <= x"0005";
		
		wait until ack = '1';
		Data_In <= x"0006";
		
		wait for clk_period;
		wren <= '0';	
	  
	  
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;