library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;
 
entity net_input_interface is
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
end entity net_input_interface;

architecture RTL of net_input_interface is
	
	constant max_vect : std_logic_vector(f_log2(FIFO_LENGTH) downto 0) := conv_std_logic_vector(FIFO_LENGTH, f_log2(FIFO_LENGTH)+1);
	constant min_vect : std_logic_vector(f_log2(FIFO_LENGTH) downto 0) := (others => '0');
	
	type fifo_type is array (0 to FIFO_LENGTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
	type state_type is (idle, receive, consume); 
	
	signal current_s : state_type; 
	
	signal fifo_memory : fifo_type := (others => (others => '0'));
	signal head_pt, tail_pt : std_logic_vector(f_log2(FIFO_LENGTH)-1 downto 0) := (others => '0');
	signal elem_count : std_logic_vector(f_log2(FIFO_LENGTH) downto 0) := (others => '0');
	
	signal fifo_full, fifo_empty : std_logic := '0';
	
begin
	
	fifo_full <= '1' when elem_count = max_vect
						else '0';
	
	fifo_empty <= '1' when elem_count = min_vect		
						else '0'; 
	
	full <= fifo_full;
	empty <= fifo_empty;
	Data_Out <= fifo_memory(conv_integer(head_pt));
	

	process (clk, reset)
	begin
		if reset = '1' then
		  current_s <= idle;
		  ack <= '0';
		  sdone <= '0';
		  head_pt <= (others => '0');
		  tail_pt <= (others => '0');
		  elem_count <= (others => '0');
		  fifo_memory <= (others => (others => '0'));
		
		elsif rising_edge(clk) then		
		  
		  ack <= '0';
		  sdone <= '0';
		  
		  case current_s is
		     when idle =>       
			     if valid ='1' then
			      current_s <= receive;
			    elsif shft = '1' then
			      current_s <= consume;
			     end if;   
		
		     when receive =>       
			    if fifo_full = '1' then
			    	ack <= '0';
			    else
			    	fifo_memory(conv_integer(tail_pt)) <= Data_In;
			    	ack <= '1';
			    	tail_pt <= tail_pt + '1';
			    	elem_count <= elem_count + '1';
			    end if;
				 
				 if shft = '1' then 
					current_s <= consume;
				 else
					current_s <= idle;
				 end if;
		
			  when consume =>      
			    if fifo_empty = '0' then
			    	elem_count <= elem_count - '1';
			    	head_pt <= head_pt + '1';
					sdone <= '1';
				end if;
				
				if valid = '1' then 
					current_s <= receive;
				else
					current_s <= idle;
				end if;
			    
			end case;
		
		end if;
	end process;

end architecture RTL;