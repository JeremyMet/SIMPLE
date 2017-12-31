----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.05.2017 18:14:19
-- Design Name: 
-- Module Name: adder_16bits - Behavioral
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


entity adder_16bits is
  Port (
    sub : in std_logic ; -- A-B is sub = '1', A+B otherwise. 
    A : in std_logic_vector(15 downto 0) ; 
    B : in std_logic_vector(15 downto 0) ; 
    C : out std_logic_vector(15 downto 0) ; 
    carry_out : out std_logic  
    ) ; 
end adder_16bits;

architecture Structural of adder_16bits is

    component full_adder is
        port(
            a : in std_logic ; 
            b : in std_logic ; 
            carry_in : std_logic ; 
            c : out std_logic ; 
            carry_out : out std_logic 
        ) ;        
    end component full_adder;
    
    signal internal_carry : std_logic_vector(15 downto 0) ; 
    signal internal_c : std_logic_vector(15 downto 0) ;
    signal multiplexer_output_B : std_logic_vector(15 downto 0) ; 


begin

    
    multiplexer_output_B <= not(B) when sub = '1' else B ; 

    inst_first_full_adder : full_adder 
                       port map( a => A(0),
                                 b => multiplexer_output_B(0), 
                                 carry_in => sub, 
                                 c => internal_c(0), 
                                 carry_out => internal_carry(0)
                                ) ; 
                                              
    GEN : for I in 1 to 15 generate
            inst_full_adder : full_adder port map(
                               a => A(I),
                               b => multiplexer_output_B(I),
                               carry_in => internal_carry(I-1),
                               c => internal_c(I),
                               carry_out => internal_carry(I)
                             ) ;                             
    end generate GEN ; 
    
    C <= internal_c ; 
    carry_out <= internal_carry(15) ; 


end Structural;
