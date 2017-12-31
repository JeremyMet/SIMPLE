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
use ieee.numeric_std.all;

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
        addr_a : in std_logic_vector(4 downto 0) ; 
        addr_b : in std_logic_vector(4 downto 0) ;        
        addr_c : in std_logic_vector(4 downto 0) ;
        wr_en  : in std_logic ; 
        data   : in std_logic_vector(15 downto 0) ; 
        out_a  : out std_logic_vector(15 downto 0) := (others=>'0') ; 
        out_b  : out std_logic_vector(15 downto 0) := (others=>'0')  
    ) ; 
end register_file;

architecture Behavioral of register_file is

    subtype word_t is std_logic_vector(15 downto 0) ; 
    type memory_t is array(31 downto 0) of word_t ; 
    
    signal reg : memory_t := (others=>(others=>'0')) ; 

begin
     

    process(clk)
    begin
        if rising_edge(clk) then
            out_a <= reg(to_integer(unsigned(addr_a))) ;
            out_b <= reg(to_integer(unsigned(addr_b))) ;
            if wr_en = '1' then
                reg(to_integer(unsigned(addr_c))) <= data ; 
            end if ;
            reg(0) <= (others=>'0') ; -- R0 is zero !!                 
        end if ; -- fin de condition sur l'horloge.
    end process ;                  


end Behavioral;
