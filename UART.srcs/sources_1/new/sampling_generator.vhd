

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sampling_generator is
    generic(
       DIVISOR : natural := 651 -- 9600x16 @ 100 MHz  
    ); 
    port(
        clk : in std_logic ;
        rst : in std_logic ; -- if '1' then reset         
        signal_sampling : out std_logic 
        );
end sampling_generator;

architecture Behavioral of sampling_generator is
    
    signal internal_signal_sampling : std_logic := '0' ; 
    signal internal_cpt : std_logic_vector(15 downto 0) := (others=>'0') ;  
    signal is_equal : std_logic := '0' ;
    

begin

    process(clk)
    begin                             
            if rising_edge(clk) then
                if rst = '1' then
                    internal_cpt <= (others => '0') ; 
                else
                    if is_equal = '0' then
                        internal_cpt <= std_logic_vector(unsigned(internal_cpt)+1) ;
                    else
                        internal_cpt <= (others=>'0') ; 
                    end if ;
                end if ;                       
            end if ;
            
                    
    end process ;
    
    process(internal_cpt)
    begin
        if to_integer(unsigned(internal_cpt)) = DIVISOR then
            is_equal <= '1' ;
        else
            is_equal <= '0' ;                                       
        end if ; 
    end process ; 
    
    signal_sampling <= is_equal ; 
    
end Behavioral;
