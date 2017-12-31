----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.06.2017 21:15:34
-- Design Name: 
-- Module Name: register_file - Behavioral
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

entity register_file is
    port(
        clk    : in std_logic ; 
        addr_a : in std_logic_vector(3 downto 0) ; 
        addr_b : in std_logic_vector(3 downto 0) ;
        addr_c : in std_logic_vector(3 downto 0) ;
        wr_en  : in std_logic ; 
        out_a  : out std_logic_vector(15 downto 0) ; 
        out_b  : out std_logic_vector(15 downto 0) 
    ) ; 
end register_file;

architecture Behavioral of register_file is

begin



end Behavioral;
