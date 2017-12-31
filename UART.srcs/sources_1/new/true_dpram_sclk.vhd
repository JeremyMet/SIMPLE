library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity true_dpram_sclk is
  
	port 
	(	
		data_a	: in std_logic_vector(15 downto 0);
		data_b	: in std_logic_vector(15 downto 0);
		addr_a	: in std_logic_vector(9 downto 0);
		addr_b	: in std_logic_vector(9 downto 0);
		we_a	: in std_logic := '1';
		we_b	: in std_logic := '1';
		clk		: in std_logic;
		q_a		: out std_logic_vector(15 downto 0);
		q_b		: out std_logic_vector(15 downto 0)
	);
	
end true_dpram_sclk;

architecture rtl of true_dpram_sclk is
	
	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(15 downto 0);
	type memory_t is array(1023 downto 0) of word_t;
	
	-- Declare the RAM
	shared variable ram : memory_t;

begin

	-- Port A
	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we_a = '1') then
				ram(to_integer(unsigned(addr_a))) := data_a;
			end if;
			q_a <= ram(to_integer(unsigned(addr_a)));
		end if;
	end process;
	
	-- Port B
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(we_b = '1') then
				ram(to_integer(unsigned(addr_b))) := data_b;
			end if;
			q_b <= ram(to_integer(unsigned(addr_b)));
		end if;
	end process;
end rtl;
