----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.06.2017 21:42:55
-- Design Name: 
-- Module Name: ALU - Behavioral
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


-- op
--  000 : A+B
--  001 : A-B 
--  010 : A*B
--  011 : A/B 

entity ALU is
    port(
        clk : in std_logic ;
        rst : in std_logic ;  
        op : in std_logic_vector(2 downto 0) ;
        A : in std_logic_vector(15 downto 0) ;  
        B : in std_logic_vector(15 downto 0) ;
        C : out std_logic_vector(15 downto 0) ;
        rdy : out std_logic       
    ) ;     
end ALU;

architecture Behavioral of ALU is

    -------------------------------------------    
    
    
    component adder_16bits is
      Port (
        sub : in std_logic ; 
        A : in std_logic_vector(15 downto 0) ; 
        B : in std_logic_vector(15 downto 0) ; 
        C : out std_logic_vector(15 downto 0) ; 
        carry_out : out std_logic  
        ) ; 
    end component adder_16bits;
    
    -------------------------------------------
    
    component multiplier_16bits is
        port(
            clk : in std_logic ; 
            rst : in std_logic ; 
            A : in std_logic_vector(15 downto 0) ; 
            B : in std_logic_vector(15 downto 0) ; 
            C : out std_logic_vector(15 downto 0) ; 
            carry_out : out std_logic ; 
            rdy : out std_logic 
        ) ;         
    end component multiplier_16bits;    
    
    -------------------------------------------
    
    
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
    
    -------------------------------------------
    
    signal sub : std_logic ; 
    
    signal output_add : std_logic_vector(15 downto 0) ;     
    signal output_mul : std_logic_vector(15 downto 0) ;
    signal output_div : std_logic_vector(15 downto 0) ;
    signal output_xor : std_logic_vector(15 downto 0) ;
    signal output_or : std_logic_vector(15 downto 0) ;
    signal output_and : std_logic_vector(15 downto 0) ;
    
    signal carry_out_add : std_logic ; 
    signal carry_out_mul : std_logic ;
    
    signal rdy_mul : std_logic ; 
    signal rdy_div : std_logic ;
    
    signal rst_mul : std_logic ; 
    signal rst_div : std_logic ; 
    
    signal internal_rdy : std_logic ; 
    
     
    
    -------------------------------------------


begin


    sub <= '1' when op = "001" else '0' ;     
    rst_mul <= rst when op = "010" else '0' ; 
    rst_div <= rst when op = "011" else '0' ;    
    
    internal_rdy <= rdy_mul and rdy_div ; 
                                   
    rdy <= internal_rdy ;   
    
    -- op
    --  000 : A+B
    --  001 : A-B 
    --  010 : A*B
    --  011 : A/B    
    --  100 : A XOR B
    --  101 : A OR B
    --  110 : A AND B       
           
    C <= output_mul when op = "010" else
         output_div when op = "011" else
         output_add when (op = "000" or op = "001") else
         output_xor when op = "100" else
         output_or  when op = "101" else
         output_and when op = "110" else         
         A ;  
                                         
    output_xor <= A XOR B ; 
    output_or  <= A OR B ; 
    output_and <= A AND B ;             
    
    inst_adder_16bits : adder_16bits port map(
                                        sub => sub,
                                        A => A,
                                        B => B, 
                                        C => output_add,
                                        carry_out => carry_out_add) ; 
                                        
    inst_multiplier_16bits : multiplier_16bits port map(
                                        clk => clk,
                                        rst => rst_mul,
                                        A => A,
                                        B => B,
                                        C => output_mul,
                                        carry_out => carry_out_mul,
                                        rdy => rdy_mul) ;                                        
                                        
    inst_divisor_16bits : divisor_16bits port map(
                                        clk => clk,
                                        rst => rst_div,
                                        A => A,
                                        B => B,
                                        C => output_div,
                                        rdy => rdy_div) ;  
                                        
                                        
                                  

end Behavioral;
