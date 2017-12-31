----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.05.2017 19:18:06
-- Design Name: 
-- Module Name: UART_Basys - Behavioral
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

entity UART_Basys is
    port(
        clk : in std_logic ;         
        RsRx : in std_logic ; 
        sw : in std_logic_vector(15 downto 0) ; 
        RsTx : out std_logic ; 
        btnC : in std_logic ; 
        btnL : in std_logic ; 
        btnU : in std_logic ;
        btnR : in std_logic ;
        btnD : in std_logic ;
        led : out std_logic_vector(15 downto 0) 
    );
end UART_Basys;


architecture Behavioral of UART_Basys is


    type fsm_state is (idle, active) ; 
    -------------------------------------------
    
    component UART is
        generic(
           FREQUENCY : natural := 100000000 ; -- (Hz)
           BAUD_RATE : natural := 9600 -- 9600x16 @ 100 MHz  
        ); 
        port(
            clk : in std_logic ;
            -- Rx
            rdy : out std_logic ; 
            rx : in std_logic ;
            received_byte : out std_logic_vector(7 downto 0) ;
            -- Tx
            sent_byte : in std_logic_vector(7 downto 0) ; 
            send : in std_logic ;
            tx : out std_logic        
        ) ;    
    end component UART;
    
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
    
    
    component ALU is
        port(
            clk : in std_logic ;
            rst : in std_logic ;  
            op : in std_logic_vector(1 downto 0) ;
            A : in std_logic_vector(15 downto 0) ;  
            B : in std_logic_vector(15 downto 0) ;
            C : out std_logic_vector(15 downto 0) ;
            rdy : out std_logic       
           ) ;     
    end component ALU;
    
    -------------------------------------------
    
    
    signal accumulator : std_logic_vector(15 downto 0) := (others=>'0') ;
    signal accumulator_out : std_logic_vector(15 downto 0) := (others=>'0') ;
    signal received_byte : std_logic_vector(7 downto 0) := (others => '0' ) ;
    signal padded_received_byte : std_logic_vector(15 downto 0) := (others => '0' ) ;
    signal carry_out : std_logic ;  
    
    signal rdy : std_logic := '0' ; 
    signal mult_rdy : std_logic := '0' ; 
    
    
    signal internal_state : fsm_state := idle ; 
    signal next_internal_state : fsm_state := idle ;
        
    signal sw_1 : std_logic_vector(15 downto 0) ;
    signal sw_2 : std_logic_vector(15 downto 0) ;
    
    signal op : std_logic_vector(1 downto 0) := "00" ; 
    
    signal internal_rst : std_logic ; 
    
    
                  

begin


--    inst_adder_16bits : adder_16bits
--                        port map(
--                            sub => '1',
--                            A => sw_1,
--                            B => sw_2, 
--                            C => accumulator, 
--                            carry_out => carry_out 
--                        ) ;

    inst_ALU : ALU port map(
                clk => clk, 
                rst => internal_rst,
                op => op, 
                A => sw_1,
                B => sw_2,
                C => accumulator) ;                          
              
    inst_UART : UART
                generic map(BAUD_RATE => 9600) 
                port map(clk=> clk,
                         rdy => rdy,
                         rx => RsRx,
                         received_byte => received_byte,
                         sent_byte => accumulator(7 downto 0),
                         send => btnC,
                         tx => RsTx          
                         );
                         
                         
                          
                                                                                          
    sw_1 <= "00000000" & sw(15 downto 8) ;                         
    sw_2 <= "00000000" & sw(7 downto 0) ;
    
    
    process(clk)
    begin 
        if rising_edge(clk) then
            if btnL = '1' then
                op <= "00" ;  
            elsif btnU = '1' then
                op <= "01" ; 
            elsif btnR = '1' then
                op <= "10" ; 
            elsif btnD = '1' then
                op <= "11" ; 
            end if ;          
            if btnL = '1' or btnU = '1' or btnR = '1' or btnD = '1' then
                internal_rst <= '1' ; 
            else
                internal_rst <= '0' ;  
            end if ; 
        end if ;                              
    end process ; 
                         
--    process(clk)
--    begin      
--        if rising_edge(clk) then
--        end if ; -- fin condition horloge.              
--    end process ;           

    --led(7 downto 0) <= accumulator(7 downto 0) ;
    --led(8) <= led_8 ;       
    --led(9) <= led_9 ;
    process(clk)
    begin
        if rising_edge(clk) then
            led <= sw ;
        end if ;             
    end process ;          
    
end Behavioral;
