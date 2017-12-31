library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_io is
	port 
	(	
		data_a	: in std_logic_vector(7 downto 0);		
		addr_a	: in std_logic_vector(7 downto 0) ; 		
		we_a	: in std_logic := '1';		
		clk		: in std_logic;
		q_a		: out std_logic_vector(7 downto 0)		
	);	
end ram_io;

architecture rtl of ram_io is
	
	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(7 downto 0);
	type memory_t is array(255 downto 0) of word_t;
	
	-- Declare the RAM
	signal ram : memory_t;

begin	
	process(clk)
	begin
		if(rising_edge(clk)) then 		     
			if(we_a = '1') then
				ram(to_integer(unsigned(addr_a))) <= data_a;
			end if;
			q_a <= ram(to_integer(unsigned(addr_a))) ;
			-- q_a <= "01000001" ; 
		end if;
	end process;
end rtl;
