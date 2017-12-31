----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.05.2017 17:42:18
-- Design Name: 
-- Module Name: UART_TX - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_TX is
    port(
        clk : in std_logic ;
        sampling_rst : out std_logic ;
        sampling : in std_logic ; 
        send : in std_logic ; 
        sent_byte : in std_logic_vector(7 downto 0) ;
        tx : out std_logic  ;
        rdy : out std_logic         
    ) ;         
end UART_TX;


architecture Behavioral of UART_TX is

    type fsm_state is (idle, active) ; 
    
    signal internal_state : fsm_state := idle ; 
    signal next_internal_state : fsm_state := idle ;
    signal internal_shift_reg : std_logic_vector(9 downto 0) := (others=>'0') ; 
    signal internal_cpt : std_logic_vector(3 downto 0) := "0000" ;
    signal internal_tx : std_logic := '1' ; 
    signal internal_rdy : std_logic := '1' ;  

begin

    process(clk)
    begin
        if rising_edge(clk) then
            internal_state <= next_internal_state ; 
            case(internal_state) is
                when idle =>
                    if send = '1' then
                        next_internal_state <= active ;
                        internal_shift_reg <= '1' & sent_byte & '0' ;                          
                        sampling_rst <= '1' ;  
                        internal_rdy <= '0' ;                                                                                            
                    end if ;
                    internal_cpt <= "0000" ; 
                    internal_tx <= '1' ; 
                when active =>
                    sampling_rst <= '0' ;
                    internal_tx <=  internal_shift_reg(0) ;
                    if internal_cpt = "1001" then
                        if sampling='1' then
                            next_internal_state <= idle ; 
                            internal_rdy <= '1' ;
                        end if ;                              
                    else                          
                        if sampling = '1' then
                            internal_cpt <= std_logic_vector(unsigned(internal_cpt)+1) ;  
                            internal_shift_reg <=   internal_shift_reg(0) & internal_shift_reg(9 downto 1)  ; -- shift. 
                        end if ;
                    end if ;                                                                                                                                              
            end case ;                 
        end if ; -- fin de condition sur l'horloge.     
    end process ;     
    
    tx <= internal_tx ;
    rdy <= internal_rdy ;      


end Behavioral;
