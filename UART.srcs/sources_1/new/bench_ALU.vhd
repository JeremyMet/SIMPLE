----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.05.2017 22:15:46
-- Design Name: 
-- Module Name: bench_ALU - Behavioral
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

entity bench_ALU is
--  Port ( );
end bench_ALU;

architecture Behavioral of bench_ALU is


    component clock is
        generic(
            period : time := 100 ns   
        ) ;         
        port(
            clk : out std_logic 
            ) ;
    end component clock;


    component adder_16bits is
      Port (
        sub : in std_logic ; 
        A : in std_logic_vector(15 downto 0) ; 
        B : in std_logic_vector(15 downto 0) ; 
        C : out std_logic_vector(15 downto 0) ; 
        carry_out : out std_logic  
        ) ; 
    end component adder_16bits;
    
    component divisor_16bits is
        port(
            clk : in std_logic ; 
            rst : in std_logic ; 
            A : in std_logic_vector(15 downto 0) ; 
            B : in std_logic_vector(15 downto 0) ; 
            C : out std_logic_vector(15 downto 0) ; 
            rdy : out std_logic
        ) ;         
    end component divisor_16bits;
    

    signal A : std_logic_vector(15 downto 0) := "0000000000000111" ;
    signal B : std_logic_vector(15 downto 0) := "0000000000000000" ; 
    signal C : std_logic_vector(15 downto 0) := (others => '0' ) ; 
    signal carry_out : std_logic := '0' ; 
    signal clk : std_logic ; 
    signal rdy : std_logic ; 
    signal rst : std_logic ; 

begin

    inst_clock : clock port map(clk=>clk) ; 

--    inst_adder_16bits : adder_16bits
--                        port map(
--                            sub => '1', 
--                            A => A,
--                            B => B,
--                            C => C,
--                            carry_out => carry_out
--                        ) ;
                        
    inst_div_16bits : divisor_16bits
                      port map(
                        clk => clk,
                        rst => '1',
                        A => A,
                        B => B,
                        C => C,
                        rdy => rdy                       
                      ) ; 
                                                                          


end Behavioral;
