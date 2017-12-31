----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.05.2017 13:48:31
-- Design Name: 
-- Module Name: multiplier_16bits - Behavioral
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

entity multiplier_16bits is
    port(
        clk : in std_logic ; 
        rst : in std_logic ; 
        A : in std_logic_vector(15 downto 0) ; 
        B : in std_logic_vector(15 downto 0) ; 
        C : out std_logic_vector(15 downto 0) ; 
        carry_out : out std_logic ; 
        rdy : out std_logic 
    ) ;         
end multiplier_16bits;

architecture Behavioral of multiplier_16bits is


    type fsm_state is (idle, active) ; 


------------------------------------------------------
    component adder_16bits is
      Port (
        sub : in std_logic ; 
        A : in std_logic_vector(15 downto 0) ; 
        B : in std_logic_vector(15 downto 0) ; 
        C : out std_logic_vector(15 downto 0) ; 
        carry_out : out std_logic  
        ) ; 
    end component adder_16bits;   
------------------------------------------------------    
    
    component is_zero_16bits is
      Port (  
        A : in std_logic_vector(15 downto 0) ; 
        is_zero : out std_logic     
       );
    end component is_zero_16bits;
    
------------------------------------------------------    
    
    signal internal_state : fsm_state := idle ;     
    signal internal_a : std_logic_vector(15 downto 0) := (others=>'0') ;    
    signal internal_b : std_logic_vector(15 downto 0) := (others=>'0') ;
    
    signal mux_output : std_logic_vector(15 downto 0) := (others=>'0') ; 
    signal mux_select : std_logic := '0' ;
    signal mux_input : std_logic_vector(15 downto 0) := (others=>'0') ; 
    
    signal accumulator : std_logic_vector(15 downto 0) := (others=>'0') ;
    signal accumulator_out : std_logic_vector(15 downto 0) := (others=>'0') ;
    
    signal internal_carry : std_logic := '0' ;
    signal mult_carry : std_logic := '0' ; 
    
    signal internal_is_zero : std_logic := '0' ;
    signal internal_rdy : std_logic := '1' ;   



begin

    inst_adder_16bits : adder_16bits
                        port map(
                            sub => '0',
                            A => accumulator,
                            B => mux_output,
                            C => accumulator_out,
                            carry_out => internal_carry
                        ) ;                         

    inst_is_zero_16bits : is_zero_16bits
                          port map(
                            A => internal_b,
                            is_zero => internal_is_zero
                            ) ; 
                          

    process(clk)
    begin
        if rising_edge(clk) then
            case(internal_state) is
                when idle =>
                    if rst='1' then 
                        internal_state <= active ;
                        internal_a <= a ; 
                        internal_b <= b ; 
                        accumulator <= (others=>'0') ;
                        mult_carry <= '0' ;
                        internal_rdy <= '0' ;    
                    else
                        internal_rdy <= '1' ;                         
                    end if ; 
                when active =>  
                    mux_select <= internal_b(0) ;
                    mux_input <= internal_a ;  
                    internal_a <= internal_a(14 downto 0) & '0' ;                                          
                    internal_b <= '0' & internal_b(15 downto 1) ;
                    if internal_carry = '1' then
                        mult_carry <= '1' ; 
                    end if ;                           
                    accumulator <= accumulator_out ; 
                    if internal_is_zero = '1' then
                        internal_state <= idle ; 
                    end if ;                                                 
                end case ;                                              
        end if ; -- fin de condition sur l'horloge.
    end process ;          
         
    mux_output <= (others=>'0') when mux_select = '0' else mux_input ;           
         
    carry_out <= mult_carry ;  
    C <= accumulator_out ;   
    rdy <= internal_rdy ;        


end Behavioral;
