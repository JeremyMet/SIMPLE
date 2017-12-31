----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.10.2017 18:59:28
-- Design Name: 
-- Module Name: input_output_ports - Behavioral
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


-- "LOAD"  : 0x00, 
-- "STORE DATA" : 0xFD,
-- "STORE CODE" : 0xFC,
-- "RST"   : 0xCA

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity input_output_ports is
    Port (
        clk : in std_logic ; 
        -- UART Ports
        -- Rx         
        Rx  : in std_logic ; 
        -- Tx
        Tx : out std_logic ; 
        -- RAM Ports
        data_a    : out std_logic_vector(31 downto 0);        
        addr_a    : out std_logic_vector(7 downto 0);         
        we_a      : out std_logic  ;
        we_b      : out std_logic  ;                                
        q_a       : in std_logic_vector(15 downto 0) ;
        -- is cpu running ?
        --cpu_switch : out std_logic ;
        -- rst cpu 
        cpu_rst  : out std_logic   
        -- led
        --led : out std_logic_vector(7 downto 0)                                   
    );
end input_output_ports;

architecture Behavioral of input_output_ports is

    type fsm_state is (t_read_instruction, t_decode, t_read_data, t_write, t_read_0, t_read_1, t_send_0, t_send_1, t_break_0, t_break_1, t_rst) ; 

    ----------------
    -- Components --
    ----------------
    
    component UART is
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
        end component UART;
        
        ----------------------
        
                
    
    -------------
    -- Signals --
    -------------
    
    -- for UART Component    
    signal rdy_tx : std_logic ; 
    signal rdy_rx : std_logic ;
    signal send   : std_logic := '0' ; 
    signal sent_byte : std_logic_vector(7 downto 0) := (others=>'0') ;
    signal received_byte : std_logic_vector(7 downto 0) ;
    
    signal new_instruction : std_logic := '0' ; 
    signal old_rdy_rx : std_logic := '1' ;  
    signal current_rdy_rx : std_logic := '1' ;
    
    signal fsm_state_reg : fsm_state := t_read_instruction ;
    
    signal rdy : std_logic ;     
                   
    -- for RAM
    signal instruction : std_logic_vector(7 downto 0) := (others=>'0') ; -- "LOAD : 0x00, STORE : 0xFF "
    signal address : std_logic_vector(7 downto 0) := (others=>'0') ; -- "LOAD : 0x00, STORE : 0xFF "
    signal data : std_logic_vector(7 downto 0) := (others=>'0') ; -- "LOAD : 0x00, STORE : 0xFF "
    signal internal_we_a : std_logic :='0' ;
    signal internal_we_b : std_logic :='0' ;
    
    signal wr_buffer : std_logic := '0' ; 
    
    signal data_0 : std_logic_vector(7 downto 0) := (others=>'0') ; -- "LOAD : 0x00, STORE : 0xFF "
    signal data_1 : std_logic_vector(7 downto 0) := (others=>'0') ; -- "LOAD : 0x00, STORE : 0xFF "
    signal data_2 : std_logic_vector(7 downto 0) := (others=>'0') ; -- "LOAD : 0x00, STORE : 0xFF "
    signal data_3 : std_logic_vector(7 downto 0) := (others=>'0') ; -- "LOAD : 0x00, STORE : 0xFF "
    
    signal data_buffer : std_logic_vector(15 downto 0) ; 
    
    signal ring_cpt : std_logic_vector(3 downto 0) := "0001" ; 
    signal is_equal : std_logic ;
    signal internal_cpu_switch : std_logic := '0' ;
    
    signal internal_cpu_rst : std_logic := '0' ;
    signal rst_latency : std_logic := '0' ;  
     
  
        


begin
                           
    inst_UART : UART
                port map(clk=>clk,
                         -- RX
                         rdy_rx=>rdy_rx,
                         rx => Rx,
                         received_byte => received_byte,
                         -- TX
                         rdy_tx => rdy_tx,
                         tx => Tx,
                         send => send, 
                         sent_byte => sent_byte) ;                          
                                                        
    
    -- Listening for new instruction (UART sent).     
    process(clk)
    begin
        if rising_edge(clk) then
            old_rdy_rx <= current_rdy_rx ; 
            current_rdy_rx <= rdy_rx ;              
        end if ; 
    end process ;        
    new_instruction <= '1' when (current_rdy_rx = '1' and old_rdy_rx='0') else '0'  ;           
    we_a <= internal_we_a ;  
    we_b <= internal_we_b ;    
    
--    led <= "00000001" when fsm_state_reg = t_read_0 else
--           "00000010" when fsm_state_reg = t_send_0 else
--           "00000100" when fsm_state_reg = t_read_1 else                          
--           "00000100" when fsm_state_reg = t_send_1 else
--           "00001111" when fsm_state_reg = t_break_0 else 
--           "00001010" when fsm_state_reg = t_break_1 else
--           "11111111" ; 
    
    --led <= "0000" & ring_cpt ; 
    
    -- FSM and Decoding.              
    is_equal <= '1' when ring_cpt = "1000" else '0' ; 

    process(clk)
    begin
        if rising_edge(clk) then            
            case(fsm_state_reg) is
                when t_read_instruction =>                        
                    instruction <= received_byte ;                                                     
                    internal_we_a <= '0' ;   
                    internal_we_b <= '0' ;
                    rst_latency <= '0' ;                     
                    send <= '0' ; 
                    internal_cpu_rst <= '0' ; 
                    if new_instruction='1' and rdy_tx = '1' then                        
                        fsm_state_reg <= t_decode ;                                                 
                    end if ;
                when t_decode =>
                    address <= received_byte ;
                    -- buffer management. 
                    if instruction = X"FC" then
                        wr_buffer <= '0' ; 
                    elsif instruction = X"FD" then
                        wr_buffer <= '1' ;
                    end if ;            
                    -- decoding instruction.          
                    if instruction = X"CA" then                    
                        fsm_state_reg <= t_rst ;
                    elsif instruction = X"00" then
                        if new_instruction='1' then fsm_state_reg <= t_read_0 ; end if ; -- LOAD
                    else
                        if new_instruction='1' then fsm_state_reg <= t_read_data ; end if ; -- STORE                        
                    end if ; 
                when t_read_data =>                                         
                    case ring_cpt is
                        when "0001" => data_0 <= received_byte ;
                        when "0010" => data_1 <= received_byte ;
                        when "0100" => data_2 <= received_byte ;
                        when "1000" => data_3 <= received_byte ;
                        when others => null ;
                    end case ring_cpt ;                      
                    if new_instruction='1' then ring_cpt <= ring_cpt(2 downto 0) & ring_cpt(3) ; end if ;
                    if new_instruction='1' and is_equal='1' then
                        fsm_state_reg <= t_write ;                         
                    end if ;                                     
                when t_write =>
                    if wr_buffer = '0' then
                        internal_we_b <= '1' ; -- b => Code RAM
                    else
                        internal_we_a <= '1' ; -- a => Data RAM.
                    end if ;                         
                    fsm_state_reg <= t_read_instruction ;
                ---- READ                                        
                when t_read_0 =>
                    sent_byte <= q_a(7 downto 0) ; 
                    fsm_state_reg <= t_send_0 ; 
                when t_read_1 =>
                    sent_byte <= q_a(15 downto 8) ; 
                    fsm_state_reg <= t_send_1 ;                    
                when t_send_0 =>
                    send <= '1' ;                                 
                    fsm_state_reg <= t_break_0 ;
                when t_send_1 =>
                        send <= '1' ;                                 
                        fsm_state_reg <= t_read_instruction ;
                when t_break_0 =>
                    send <= '0' ;
                    fsm_state_reg <= t_break_1 ;                                             
                when t_break_1 =>                                     
                    if rdy_tx = '1' then fsm_state_reg <= t_read_1 ; end if ;
                when t_rst =>
                    internal_cpu_rst <= '1' ;
                    rst_latency <= '1' ; 
                    if rst_latency = '1' then fsm_state_reg <= t_read_instruction ; end if ;                                                                                                                                                                                                         
                when others => null ;                    
            end case ;       
            
        end if ; -- rising_edge                                    
    end process ;     
    
    data_a  <= data_3 & data_2 & data_1 & data_0 ; 
    addr_a  <= address ;  
    cpu_rst <= internal_cpu_rst ;                    


end Behavioral;
