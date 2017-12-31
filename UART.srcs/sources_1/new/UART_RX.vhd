library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_RX is
    port(
        clk : in std_logic ; 
        rdy : out std_logic ; -- '1' when ready.
        sampling : in std_logic ; 
        rx  : in std_logic ;
        byte_reg : out std_logic_vector(7 downto 0) 
    ) ; 
end UART_RX;

architecture Behavioral of UART_RX is


    type fsm_state_t is (idle, active); 
    
----------------------    
-- internal signals --
----------------------     
    
    signal internal_state : fsm_state_t := idle ; 
    signal next_internal_state : fsm_state_t := idle ;
     
    signal internal_cpt : std_logic_vector(3 downto 0) := "0000" ; 
    signal nb_bits : std_logic_vector(3 downto 0) := "0000" ;
    
    signal internal_rdy : std_logic := '1' ;  
    
    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0') ;
    
     

begin
 
    process(clk)    
    begin      
        if rising_edge(clk) then  
            internal_state <= next_internal_state ; -- gestion de l'état.         
            case(internal_state) is
                when idle =>
                    internal_cpt <= "0000" ;
                    nb_bits <= "0000" ;    
                    internal_rdy <= rx ;
                    byte_reg <= shift_reg ;             
                    if rx = '0' then
                        next_internal_state <= active ;                                                              
                    else 
                        next_internal_state <= idle ;                                             
                    end if ;     
                when active =>                 
                    if sampling = '1' then   
                        if internal_cpt = "1000" then                        
                            if nb_bits = "1001" then                                
                                next_internal_state <= idle ;                                                                                          
                            else
                                shift_reg <= rx & shift_reg(7 downto 1) ; 
                                nb_bits <= std_logic_vector(unsigned(nb_bits)+1) ;
                            end if ; -- fin nb_bits                                                                                                                      
                        end if ;  -- fin internal_cpt
                        internal_cpt <= std_logic_vector(unsigned(internal_cpt)+1) ;
                    end if ; -- fin sampling.                                                       
            end case ;                                                   
        end if ;                                                      
    end process ;    

    rdy <= internal_rdy ;  

        

end Behavioral;
