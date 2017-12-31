


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bench is
--  Port ( );
end bench;

architecture Behavioral of bench is


    component clock is
        generic(
            period : time := 100 ns
        ) ;                     
        port(
            clk : out std_logic 
            ) ;
    end component clock;    
    
    -------------------------------------------
    
    component sampling_generator is
        generic(
           DIVISOR : natural := 651 -- 9600x16 @ 100 MHz  
        ); 
        port(
            clk : in std_logic ;
            signal_sampling : out std_logic 
            );
    end component sampling_generator;
    
    
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
    
    signal bench_clk_0 : std_logic ; 
    signal bench_clk_1 : std_logic ;
    signal bench_signal_sampling : std_logic ;
    signal bench_rx : std_logic := '1' ;
    signal rdy : std_logic ; 
    
    signal to_be_sent : std_logic_vector(10 downto 0) := "10011110101" ;
    
    signal bench_received_byte : std_logic_vector(7 downto 0) ;  
    
    constant DIV : integer := 10000000/9600 ;
    
    signal sent_byte : std_logic_vector(7 downto 0) := (others=>'0') ; 
    signal send : std_logic := '0'; 
    signal tx : std_logic := '1' ; 

begin

    clock_0 : clock
              generic map(period => 100 ns)
              port map(clk => bench_clk_0) ;
              
    clock_1 : clock
              generic map(period => 10 ns)
              port map(clk => bench_clk_1) ;              
              
    inst_UART : UART
                generic map(FREQUENCY => 100000000,
                            BAUD_RATE => 9600) 
                port map(clk=> bench_clk_1, -- @ 100 MHz
                         rdy => rdy, 
                         rx => bench_rx,
                         received_byte => bench_received_byte,   
                         sent_byte => sent_byte,
                         send => send, 
                         tx => tx    
                         );
                         
                             
                                                
             
    -------------------------------------------                 
             
    process(bench_clk_0)
        variable internal_cpt : integer := 0 ;
        variable ptr : integer := 0 ;          
    begin
        if rising_edge(bench_clk_0) then -- @ 1 Mhz 
            bench_rx <= to_be_sent(ptr) ;                 
            if internal_cpt = DIV and ptr < 10 then
                ptr := ptr+1 ;
                internal_cpt := 0 ;             
            end if ;             
            if ptr = 10 then
                ptr := 0 ;  
            end if ;                   
            internal_cpt := internal_cpt+1 ;                         
        end if ; -- end of rising_edge 
    end process ;              
                                                   
    


end Behavioral;
