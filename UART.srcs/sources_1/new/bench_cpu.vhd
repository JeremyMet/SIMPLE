----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.07.2017 18:41:54
-- Design Name: 
-- Module Name: bench_cpu - Behavioral
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

entity bench_cpu is
--  Port ( );
end bench_cpu;

architecture Behavioral of bench_cpu is


    component SIMPLE is
        port(
            clk : in std_logic 
        ) ;         
    end component SIMPLE;
    
    
    component clock is
        generic(
            period : time := 100 ns   
        ) ;         
        port(
            clk : out std_logic 
            ) ;
    end component clock;    
    
    signal clk : std_logic ;    

begin

 

    inst_clock : clock
                 port map(clk => clk) ;
                 
    inst_SIMPLE : SIMPLE
               port map(clk=>clk) ;                          


end Behavioral;
