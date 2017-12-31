----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.10.2017 12:02:10
-- Design Name: 
-- Module Name: SIMPLE - Behavioral
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

entity bench_simple is
          
end bench_simple;

architecture Behavioral of bench_simple is


    ----------------
    -- COMPONENTS --
    ----------------

    component ROM is
        port(
            clk : in std_logic ;             
            addr : in std_logic_vector(7 downto 0) ;
            data : out std_logic_vector(31 downto 0) 
        ) ;         
    end component ROM;
    
    component CPU is
            port(
                clk : in std_logic ; 
                rst : in std_logic ; 
                -- ROM
                output_rom : in std_logic_vector(31 downto 0) ;         
                output_PC : out std_logic_vector(7 downto 0) ; 
                -- RAM
                data_a : out std_logic_vector(15 downto 0) ; 
                addr_a : out std_logic_vector(9 downto 0) ; 
                wr_a   : out std_logic ; 
                q_a    : in std_logic_vector(15 downto 0)                      
            ) ;         
    end component CPU;
    
    
    component single_port_ram is
            port 
            (    
                data_a    : in std_logic_vector(31 downto 0);        
                addr_a    : in std_logic_vector(7 downto 0);        
                we_a      : in std_logic := '1';        
                clk       : in std_logic;
                q_a       : out std_logic_vector(31 downto 0)        
            );    
    end component single_port_ram;
    
        component clock is
        generic(
            period : time := 100 ns   
        ) ;         
        port(
            clk : out std_logic 
            ) ;
    end component clock;   
    
    component true_dpram_sclk is
        port 
        (    
            data_a    : in std_logic_vector(15 downto 0);
            data_b    : in std_logic_vector(15 downto 0);
            addr_a    : in std_logic_vector(9 downto 0);
            addr_b    : in std_logic_vector(9 downto 0);
            we_a    : in std_logic := '0';
            we_b    : in std_logic := '0';
            clk        : in std_logic;
            q_a        : out std_logic_vector(15 downto 0);
            q_b        : out std_logic_vector(15 downto 0)
        );
    end component true_dpram_sclk ;    
    
    
    component input_output_ports is
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
            --led      : out std_logic_vector(7 downto 0)                                    
        );
    end component input_output_ports;    
                                                          
    signal output_PC : std_logic_vector(7 downto 0) ;
    signal output_rom : std_logic_vector(31 downto 0) ;
    
    -- CPU Reset
    signal cpu_rst_sig : std_logic := '1' ; 
    -- Signal for Port A (RAM)
    signal data_a :  std_logic_vector(15 downto 0) ; 
    signal addr_a :  std_logic_vector(9 downto 0) ; 
    signal wr_a   :  std_logic ; 
    signal q_a    :  std_logic_vector(15 downto 0) ; 
    -- Signal for Port B (RAM)
    signal data_b :  std_logic_vector(15 downto 0) ; 
    signal addr_b :  std_logic_vector(9 downto 0) ; 
    signal wr_b   :  std_logic ; 
    signal q_b    :  std_logic_vector(15 downto 0) ;        
    -- Signal for input_output_ports
    signal data_output : std_logic_vector(31 downto 0) ;   
    signal addr_output : std_logic_vector(7 downto 0) ;  
    signal data_input  : std_logic_vector(15 downto 0) ;
    -- Signal for micro-code RAM
    signal wr_code : std_logic ;
    signal mx_microcode : std_logic_vector(7 downto 0) ;  
    
    -- debug
    
    signal debug_addr : std_logic_vector(7 downto 0) := (others=>'0') ;
    signal clk : std_logic ;  
    
    --signal led : std_logic_vector(1 downto 0) ;   

begin

    inst_clock : clock
                 port map(clk => clk) ;


    inst_ROM : ROM
        port map(clk => clk,
                addr => output_PC,
                data => output_rom) ;

--    process(clk)
--    begin
--        if rising_edge(clk) then
--            debug_addr <= sw ;  
--        end if ; 
--    end process ; 
                
--    inst_microcode_RAM : single_port_ram
--        port map(clk=>clk,
--                 addr_a => mx_microcode, 
--                 q_a    => output_rom,
--                 we_a   => wr_code,
--                 data_a => data_output) ;                                   

    mx_microcode <= addr_output when wr_code='1' else output_PC ;                  
    --mx_microcode <= addr_output when wr_code='1' else debug_addr ;
    
    
                
    inst_RAM : true_dpram_sclk
        port map(clk    => clk,
                -- Port A
                 data_a => data_a,
                 addr_a => addr_a,
                 we_a   => wr_a,
                 q_a    => q_a,
                 -- Port B
                data_b => data_b,
                addr_b => addr_b,
                we_b   => wr_b,
                q_b    => q_b) ;                                                              
                
    inst_CPU : CPU
        port map(clk=>clk,
                 rst=>cpu_rst_sig, 
                -- ROM
                 output_rom => output_rom,
                 output_PC => output_pc,
                -- RAM                  
                 data_a => data_a,
                 addr_a => addr_a,
                 wr_a   => wr_a,
                 q_a    => q_a) ;  
                 
                 
--    inst_input_output_ports : input_output_ports
--        port map(clk => clk,
--                -- Uart
--                 Rx => RsRx,
--                 Tx => RsTx,
--                -- Ram,
--                data_a => data_output,
--                addr_a => addr_output,
--                we_a   => wr_b,
--                we_b   => wr_code, 
--                q_a    => data_input,
--                -- is cpu running ?
--                --cpu_switch : out std_logic ;
--                -- rst cpu 
--                cpu_rst => cpu_rst_sig                   
--            ) ;
            
        addr_b <= "00" & addr_output ; 
        data_b <= data_output(15 downto 0) ;  
        data_input <= q_b ; 
        
        --led <= output_PC(7 downto 0) ;
        
        --led(15 downto 8) <= output_rom(31 downto 24) ;
        --led(7 downto 0) <= debug_addr ; 
        --led(15) <= wr_code ;   
--        led(15 downto 8) <= output_rom(31 downto 24) ;
--        led(7 downto 0)  <= addr_output ;  
                                    
                 
        process(clk)
        begin
            if rising_edge(clk) then
                cpu_rst_sig <= '0' ; 
            end if ; 
        end process ;                              


end Behavioral;
