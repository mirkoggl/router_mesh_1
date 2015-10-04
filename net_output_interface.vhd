library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;

entity net_output_interface is
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
end entity net_output_interface;

architecture RTL of net_output_interface is
	
	constant max_vect : std_logic_vector(f_log2(FIFO_LENGTH) downto 0) := conv_std_logic_vector(FIFO_LENGTH, f_log2(FIFO_LENGTH)+1);
	constant min_vect : std_logic_vector(f_log2(FIFO_LENGTH) downto 0) := (others => '0');
	
	type fifo_type is array (0 to FIFO_LENGTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
	type state_type is (idle, send, wait_ack); 
	
	signal current_s : state_type; 
	
	signal fifo_memory : fifo_type := (others => (others => '0'));
	signal head_pt, tail_pt : std_logic_vector(f_log2(FIFO_LENGTH)-1 downto 0) := (others => '0');
	signal elem_count : std_logic_vector(f_log2(FIFO_LENGTH) downto 0) := (others => '0');
	
	signal ack_counter : std_logic_vector(1 downto 0) := (others => '0');
	
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
		  valid <= '0';
		  sdone <= '0';
		  head_pt <= (others => '0');
		  tail_pt <= (others => '0');
		  elem_count <= (others => '0');
		  fifo_memory <= (others => (others => '0'));
		
		elsif rising_edge(clk) then		
		  
		  valid <= '0';
		  sdone <= '0';
		  
		  case current_s is
		     when idle =>       
			     if wren ='1' and fifo_full = '0' then
			      	fifo_memory(conv_integer(tail_pt)) <= Data_In;
			      	sdone <= '1';
			      	tail_pt <= tail_pt + '1';
			      	elem_count <= elem_count + '1';
			      	current_s <= idle;
			    elsif fifo_empty = '0' then
			      	current_s <= send;
			     end if;   
		
			  when send =>      
			    if fifo_empty = '0' then
			    	valid <= '1';
					current_s <= wait_ack;
					ack_counter <= "00";
				 else
					valid <= '0';
					current_s <= idle;
				end if;
				
			  when wait_ack =>      
			    if ack = '1' then
			    	valid <= '0';
					elem_count <= elem_count - '1';
					head_pt <= head_pt + '1';
					if fifo_empty = '0' then 
						current_s <= send;
					else
						current_s <= idle;
				   end if;
				elsif ack_counter = "11" then
					current_s <= idle;
					valid <= '0';
				else
					ack_counter <= ack_counter + '1';
					valid <= '1';
				end if;
			    
			end case;
		
		end if;
	end process;

end architecture RTL;