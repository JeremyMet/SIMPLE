----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.06.2017 18:06:34
-- Design Name: 
-- Module Name: divisor_16bits - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divisor_16bits is
    port(
        clk : in std_logic ; 
        rst : in std_logic ; 
        A : in std_logic_vector(15 downto 0) ; 
        B : in std_logic_vector(15 downto 0) ; 
        C : out std_logic_vector(15 downto 0) ; 
        rdy : out std_logic
    ) ;         
end divisor_16bits;

architecture Behavioral of divisor_16bits is


    type internal_state_type is (idle, msb_search, division) ; 

    component adder_16bits is
      Port (
        sub : in std_logic ; -- A-B is sub = '1', A+B otherwise. 
        A : in std_logic_vector(15 downto 0) ; 
        B : in std_logic_vector(15 downto 0) ; 
        C : out std_logic_vector(15 downto 0) ; 
        carry_out : out std_logic  
        ) ; 
    end component adder_16bits;
    
    component is_zero_16bits is
      Port (  
        A : in std_logic_vector(15 downto 0) ; 
        is_zero : out std_logic     
       );
    end component is_zero_16bits;

    
    
    signal internal_state : internal_state_type := idle ;
     
    signal internal_A : std_logic_vector(15 downto 0) := (others => '0') ; 
    signal next_internal_A : std_logic_vector(15 downto 0) := (others => '0') ;    
    signal internal_B : std_logic_vector(15 downto 0) := (others => '0') ;        
    signal internal_C : std_logic_vector(15 downto 0) := (others => '0') ;
    signal ring_counter : std_logic_vector(15 downto 0) := (others => '0') ; 
    
        
    signal quotient : std_logic_vector(15 downto 0) := (others => '0') ; 
    signal next_quotient : std_logic_vector(15 downto 0) := (others => '0') ;
    
    
    signal carry_out : std_logic ;
    signal is_ring_zero : std_logic := '0' ;  
    signal internal_rdy : std_logic := '1' ; 
    
    

begin

    inst_adder_16bits_0 : adder_16bits port map(  
                                        sub => '1', 
                                        A => internal_A,
                                        B => internal_B,
                                        C => internal_C) ;
                                        
                                        
    inst_adder_16bits_1 : adder_16bits port map(  
                                        sub => '0', 
                                        A => quotient,
                                        B => ring_counter,
                                        C => next_quotient) ;                                        
                                        
    inst_adder_16bits_2 : adder_16bits port map(  
                                        sub => '1', 
                                        A => internal_A,
                                        B => internal_B,
                                        C => next_internal_A) ;                                        
                                        
    inst_is_zero_16bits : is_zero_16bits port map(A=>ring_counter, is_zero => is_ring_zero) ; 
                                                                                                                                            
    process(clk)
    begin
        if rising_edge(clk) then
            case(internal_state) is
                when idle =>
                    if rst = '1' then
                        internal_A <= A ; 
                        internal_B <= B ;                         
                        internal_state <= msb_search ;
                        internal_rdy <= '0' ;
                        ring_counter <= "0000000000000001" ;  
                    else
                        internal_rdy <= '1' ;                          
                    end if ; 
                when msb_search =>
                    quotient <= (others => '0') ; 
                    if internal_C(15) = '0' then
                        internal_B <= internal_B(14 downto 0) & '0' ;
                        ring_counter <= ring_counter(14 downto 0) & '0' ;  
                    else
                        internal_state <= division ; 
                    end if ; 
                when division =>                     
                    internal_B <= '0' & internal_B(15 downto 1) ;
                    ring_counter <= '0' & ring_counter(15 downto 1) ; 
                    if is_ring_zero='0' then
                        if internal_C(15) = '0' then
                            quotient <= next_quotient ;
                            internal_A <= next_internal_A ; 
                        end if ;
                    else
                            internal_state <= idle ;                                                  
                    end if ;                                          
            end case ;          
        end if ; -- fin de condition sur l'horloge.     
    end process ; 
    
    rdy <= internal_rdy ; 
    C <= quotient ; 

end Behavioral;
