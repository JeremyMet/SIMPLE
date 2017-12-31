library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock is
    generic(
        period : time := 100 ns   
    ) ;         
    port(
        clk : out std_logic 
        ) ;
end clock;

architecture Behavioral of clock is

    signal internal_clk : std_logic := '0' ;     
    constant half_period : time := period/2 ; 

begin
    
    process
    begin 
        wait for half_period ;
        internal_clk <= not(internal_clk) ; 
    end process ; 

    clk <= internal_clk ;


end Behavioral;
