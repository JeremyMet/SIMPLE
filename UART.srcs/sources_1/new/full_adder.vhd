----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.05.2017 18:19:24
-- Design Name: 
-- Module Name: full_adder - Behavioral
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

entity full_adder is
    port(
        a : in std_logic ; 
        b : in std_logic ; 
        carry_in : in std_logic ; 
        c : out std_logic ; 
        carry_out : out std_logic 
    ) ;        
end full_adder;

architecture Structural of full_adder is
begin

    c <= a xor b xor carry_in ; 
    carry_out <= (a and (b or carry_in)) or (b and carry_in) ; 

end Structural;
