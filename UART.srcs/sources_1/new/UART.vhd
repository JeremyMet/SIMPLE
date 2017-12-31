----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.05.2017 21:00:25
-- Design Name: 
-- Module Name: UART - Behavioral
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

entity UART is   
    generic(
       FREQUENCY : natural := 100000000 ; -- (Hz)
       BAUD_RATE : natural := 9600 -- 9600x16 @ 100 MHz  
    ); 
    port(
        clk : in std_logic ;
        -- Rx
        rdy_rx : out std_logic ; 
        rx : in std_logic ;
        received_byte : out std_logic_vector(7 downto 0) ;
        -- Tx
        rdy_tx : out std_logic ;
        sent_byte : in std_logic_vector(7 downto 0) ; 
        send : in std_logic ;      
        tx : out std_logic              
    ) ;    
end UART;

----------------------------------------------------------------------------------

architecture Behavioral of UART is

    constant DIVISOR_RX : natural := FREQUENCY/(BAUD_RATE*16) ; 
    constant DIVISOR_TX : natural := FREQUENCY/(BAUD_RATE) ; 

    component sampling_generator is
        generic(
           DIVISOR : natural := 651 -- 9600x16 @ 100 MHz  
        ); 
        port(
            clk : in std_logic ;
            rst : in std_logic ; 
            signal_sampling : out std_logic 
            );
    end component sampling_generator ;

----------------------------------------------------------------------------------    
    
    component UART_RX is
        port(
            clk : in std_logic ; 
            rdy : out std_logic ; 
            sampling : in std_logic ; 
            rx  : in std_logic ;
            byte_reg : out std_logic_vector(7 downto 0) 
        ) ; 
    end component UART_RX; 
    
----------------------------------------------------------------------------------       

    component UART_TX is
        port(
            clk : in std_logic ;
            sampling_rst : out std_logic ;
            sampling : in std_logic ; 
            send : in std_logic ; 
            sent_byte : in std_logic_vector(7 downto 0) ;
            tx : out std_logic ;     
            rdy : out std_logic       
        ) ;         
    end component UART_TX;

----------------------------------------------------------------------------------

    signal internal_signal_sampling_rx : std_logic := '0' ; 
    signal internal_signal_sampling_tx : std_logic := '0' ;
    
    signal rst_rx : std_logic := '0' ;
    signal rst_tx : std_logic := '0' ;
    
----------------------------------------------------------------------------------

begin


    inst_sampling_generator_rx : sampling_generator 
                               generic map(DIVISOR=>DIVISOR_RX)
                               port map(clk => clk,
                               rst => rst_rx, 
                               signal_sampling => internal_signal_sampling_rx) ;
                               
                               
    inst_sampling_generator_tx : sampling_generator 
                              generic map(DIVISOR=>DIVISOR_TX)
                              port map(clk => clk,
                              rst => rst_tx, 
                              signal_sampling => internal_signal_sampling_tx) ;                                
                               
    inst_UART_RX : UART_RX
                   port map(
                    clk => clk,
                    rdy => rdy_rx, 
                    sampling => internal_signal_sampling_rx,   
                    rx => rx,
                    byte_reg => received_byte) ;


    inst_UART_TX : UART_TX
                port map(
                    clk => clk,
                    rdy => rdy_tx,  
                    sampling_rst => rst_tx,
                    sampling => internal_signal_sampling_tx,
                    send => send,
                    sent_byte => sent_byte,
                    tx=>tx) ; 
                               
                          
                    
                    
                                          

end Behavioral;
