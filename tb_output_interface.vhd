library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;

 
ENTITY tbc_out_interface IS
END tbc_out_interface;
 
ARCHITECTURE behavior OF tbc_out_interface IS 
 
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
    
   constant FIFO_LENGTH : natural := 16;
   constant DATA_WIDTH : natural := 16;
	
   --Inputs
   signal clk, reset, valid, wren, ack, full, empty, sdone : std_logic := '0';
   signal Data_In, Data_Out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

 	--Outputs

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: net_output_interface PORT MAP (
          clk => clk,
          reset => reset,
          Data_In => Data_In,
          valid => valid,
          wren => wren,
			 sdone => sdone,
          ack => ack,
          full => full,
          empty => empty,
          Data_Out => Data_Out
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
		
		wait for 2*clk_period;
		Data_In <= x"0002";
		
		wait for 2*clk_period;
		Data_In <= x"0003";
		
		wait for 2*clk_period;
		Data_In <= x"0004";
		
		wait for 2*clk_period;
		Data_In <= x"0005";
		
		wait for 2*clk_period;
		Data_In <= x"0006";
		
		wait for clk_period;
		wren <= '0';
		
		wait for 3*clk_period;
		ack <= '1';
		
		wait for clk_period;
		ack <= '0';
		
		wait for 3*clk_period;
		ack <= '1';
		
		wait for clk_period;
		ack <= '0';
		
		wait for 3*clk_period;
		ack <= '1';
		
		wait for clk_period;
		ack <= '0';
		
	  
	  
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;