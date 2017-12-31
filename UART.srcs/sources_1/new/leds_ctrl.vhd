----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.07.2017 13:14:22
-- Design Name: 
-- Module Name: leds_ctrl - Behavioral
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

entity leds_ctrl is
    port(
            clk : in std_logic ;                      
            sw : in std_logic_vector(15 downto 0) ;             
            led : out std_logic_vector(15 downto 0) ;
            JA : out std_logic_vector(7 downto 0)  
        );
end leds_ctrl;

architecture Behavioral of leds_ctrl is

begin

    JA(0) <= sw(0) ;
    JA(1) <= sw(1) ;
    JA(7 downto 2) <= (others => '0') ;  
    led <= sw ; 

end Behavioral;
