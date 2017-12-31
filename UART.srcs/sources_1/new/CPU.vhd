--S.I.M.P.L.E : Simple Implementation of Micro Processor Light and Easy

-------------------------
--000000	NOP
--000001	HALT
-------------------------
--000010	UNASSIGNED 
--000011	UNASSIGNED
--000100	UNASSIGNED
--000101	UNASSIGNED
------------------------
--000110	LD ADDRESS 
--000111	LD LITERAL
--001000	ST ADDRESS 
--001001	ST LITERAL
------------------------
--001010	ADD ADDRESS
--001011	ADD LITERAL
--001100	SUB ADDRESS
--001101	SUB LITERAL
--001110	MUL ADDRESS
--001111	MUL LITERAL
--010000	DIV ADDRESS
--010001	DIV LITERAL
--010010	XOR ADDRESS
--010011	XOR LITERAL
--010100	OR ADDRESS
--010101	OR LITERAL
--010110	AND ADDRESS
--010111	AND LITERAL
--011000	SSL ADDRESS
--011001	SSL LITERAL
--011010	SRL ADDRESS
--011011	SRL LITERAL
-------------------------
--011100 SLT ADDRESS -- Set if less than
--011101 SLT LITERAL 
--011110 SEQ ADDRESS -- Set if equal
--011111 SEQ LITERAL 
--100000 JMP ADDRESS
--100001 JMP LITERAL
--100000 BRF -- Branch if flag
-------------------------



--Instruction Format
--Instruction Format

--OP: 6 bits
--RS: 5 bits
--RT: 5 bits
--RD: 5 bits ou 16 bits


--ADDL	R0     R0         3	
--001011 00000 00000 0000000000000011

--ADDL	R3     R3         15	
--001011 00011 00011 0000000000001111

--LOAD
--000110 00011 0000000011 00000000000

--SUB R0 R0 $1
--001101 00000 00000 0000000000000001



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CPU is
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
end CPU;

architecture Behavioral of CPU is

    type cpu_state is (fetch, decode, execute, write_back) ;  
    
    constant zero : std_logic_vector(15 downto 0) := (others=>'0') ; 


    component register_file is
        port(
            clk    : in std_logic ; 
            addr_a : in std_logic_vector(4 downto 0) ; 
            addr_b : in std_logic_vector(4 downto 0) ;        
            addr_c : in std_logic_vector(4 downto 0) ;
            wr_en  : in std_logic ; 
            data   : in std_logic_vector(15 downto 0) ; 
            out_a  : out std_logic_vector(15 downto 0) ; 
            out_b  : out std_logic_vector(15 downto 0) 
        ) ; 
    end component register_file;
    
    
    component ROM is
        port(
            clk : in std_logic ;             
            addr : in std_logic_vector(7 downto 0) ;
            data : out std_logic_vector(31 downto 0) 
        ) ;         
    end component ROM;
    
    
    component single_port_ram is
        port 
        (    
            data_a    : in std_logic_vector(15 downto 0);        
            addr_a    : in std_logic_vector(9 downto 0);        
            we_a      : in std_logic := '1';        
            clk       : in std_logic;
            q_a       : out std_logic_vector(15 downto 0)        
        );    
    end component single_port_ram;    
    
    
     component ALU is
        port(
            clk : in std_logic ;
            rst : in std_logic ;  
            op : in std_logic_vector(2 downto 0) ;
            A : in std_logic_vector(15 downto 0) ;  
            B : in std_logic_vector(15 downto 0) ;
            C : out std_logic_vector(15 downto 0) ;
            rdy : out std_logic       
        ) ;     
    end component ALU;         

    --------------------------
    -- PC and Fetch SIGNALS --
    --------------------------
    
    signal internal_state : cpu_state := fetch ; 
    
    signal IR : std_logic_vector(31 downto 0) := (others => '0') ;      
    signal PC : std_logic_vector(7 downto 0)  := (others => '0') ;      
    signal old_PC : std_logic_vector(7 downto 0)  := (others => '0') ; -- for bubbler management.
    
    signal instruction : std_logic_vector(5 downto 0) ;
    signal instruction_label : std_logic_vector(4 downto 0) ; -- instruction_label <= instruction(5 downto 1) ; 
    signal op_code : std_logic_vector(2 downto 0) ;  
    signal reg_op_code : std_logic_vector(2 downto 0) := (others=>'0') ;
    
    signal ALU_rdy : std_logic ; 
    signal fetch_ALU_rst : std_logic := '0' ;
    signal decode_ALU_rst : std_logic := '0' ;
    
    -------------
    -- BUFFERS --
    -------------
    
    signal buffer_ram_addr_c : std_logic_vector(9 downto 0)  := (others =>'0') ;
    
    ----------------------
    -- PIPELINE SIGNALS --
    ----------------------
    
    signal fetch_reg_addr_c : std_logic_vector(4 downto 0)  := (others =>'0') ;    
    signal decode_reg_addr_c : std_logic_vector(4 downto 0)  := (others =>'0') ;
    signal execute_reg_addr_c : std_logic_vector(4 downto 0)  := (others =>'0') ;    
    signal memory_reg_addr_c : std_logic_vector(4 downto 0)  := (others =>'0') ;
       
    signal fetch_ram_addr_c : std_logic_vector(9 downto 0)  := (others =>'0') ;    
    signal decode_ram_addr_c : std_logic_vector(9 downto 0)  := (others =>'0') ;
    signal execute_ram_addr_c : std_logic_vector(9 downto 0)  := (others =>'0') ;    
    signal memory_ram_addr_c : std_logic_vector(9 downto 0)  := (others =>'0') ;
    
    signal fetch_ram_load   : std_logic := '0' ;     
    signal decode_ram_load  : std_logic := '0' ;  
    signal execute_ram_load : std_logic := '0' ;
    signal memory_ram_load  : std_logic := '0' ;    
    
    signal fetch_branch_flag    : std_logic_vector(1 downto 0) := "00" ;                                                  
    signal decode_branch_flag   : std_logic_vector(1 downto 0) := "00" ;                                                 
    signal execute_branch_flag  : std_logic_vector(1 downto 0) := "00" ;
    
    
         
    
    signal decode_buffer_b  : std_logic_vector(15 downto 0) ;    
    signal execute_buffer_b : std_logic_vector(15 downto 0) ;
    signal decode_lit : std_logic := '0' ; 
    signal execute_lit : std_logic := '0' ; 
    
    signal decode_reg_wr_en  : std_logic := '0' ;
    signal execute_reg_wr_en : std_logic := '0' ;    
    signal memory_reg_wr_en  : std_logic := '0' ;
       
    signal decode_ram_wr_en  : std_logic := '0' ;
    signal execute_ram_wr_en : std_logic := '0' ;

     
        
    -------------------
    -- LOGIC SIGNALS --
    -------------------
    
    signal reg_addr_a : std_logic_vector(4 downto 0)  := (others =>'0') ; 
    signal reg_addr_b : std_logic_vector(4 downto 0)  := (others =>'0') ;
    signal reg_data   : std_logic_vector(15 downto 0) := (others =>'0') ;
    signal reg_out_a : std_logic_vector(15 downto 0)  := (others =>'0') ;
    signal reg_out_b : std_logic_vector(15 downto 0)  := (others =>'0') ;
    signal mux_reg_out_b : std_logic_vector(15 downto 0)  := (others =>'0') ; -- FOR LITTERALS
    signal input_b : std_logic_vector(15 downto 0)  := (others =>'0') ; -- FOR LITTERALS
    signal mux_ram_addr : std_logic_vector(9 downto 0) ; -- FOR LITTERALS
    signal mux_reg_out_b_input : std_logic := '0' ;  -- FOR LITTERALS
    signal reg_wr_en : std_logic := '0' ;
    
    signal ram_addr_a : std_logic_vector(9 downto 0)  := (others =>'0') ;
    signal ram_data   : std_logic_vector(15 downto 0) := (others =>'0') ;
    signal ram_out_a : std_logic_vector(15 downto 0)  := (others =>'0') ;    
    signal ram_wr_en : std_logic := '0' ;
             
    
    signal data_in_RF : std_logic_vector(15 downto 0) ; 
    signal mult_IR : std_logic := '0' ; 
        
    
    ----------------------
    -- BUBBLING SIGNALS --
    ----------------------
    
    signal bubble : std_logic := '0' ;   
    signal old_bubble : std_logic := '0' ;
    signal old_old_bubble : std_logic := '0' ;
    signal master_bubble : std_logic := '0' ;     
    signal logic_a : std_logic ;  
    signal logic_b : std_logic ;   
    signal logic_c : std_logic ;
                   
    
    --signal output_rom : std_logic_vector(31 downto 0) ; 
        
    signal ALU_output : std_logic_vector(15 downto 0) ;
    signal execute_ALU_output : std_logic_vector(15 downto 0) ; 
    signal memory_ALU_output : std_logic_vector(15 downto 0) ;
    
    signal fetch_store_label : std_logic  ; 
    signal fetch_store_select : std_logic  ;
    signal decode_store_label : std_logic := '0'  ;
    signal load_label : std_logic  ;
    
    signal diff : std_logic ; 
    
    -------------------
    -- BRANCH SIGNAL --
    -------------------
    
    signal branch_flag : std_logic := '0' ; 
    signal fetch_jump : std_logic := '0' ;      -- JUMP if Set
    signal decode_jump : std_logic := '0' ;      -- JUMP if Set
    signal jump_address : std_logic_vector(7 downto 0) := (others=>'0') ; 
    signal jump_ring_cpt : std_logic := '0' ;    
    signal logic_jump : std_logic ;  
    signal logic_jump_inst : std_logic ;
    signal label_set : std_logic ; 
    signal tmp_jump_BRFT : std_logic ; 
    signal tmp_jump_BRFF : std_logic ;
    signal buffer_jump_address : std_logic_vector(7 downto 0) := (others=>'0') ;
    signal jump_instuction : std_logic := '0' ;
    
    --signal has_jumped : std_logic := '0' ; 
    
    signal latency_cycle : std_logic_vector(1 downto 0) := (others => '0') ;   
    
    signal jump_signal_ctrl : std_logic ; 
    
    -----------------
    -- HALT SIGNAL --
    -----------------
    
    signal halt : std_logic := '1' ;
    signal fetch_halt : std_logic ; 
    signal sig_halt : std_logic ;  
    
         
                               
begin

    --------------------
    -- INSTANTIATIONS --
    --------------------

                        
    inst_register_file : register_file
                         port map(
                            clk => clk, 
                            addr_a => reg_addr_a,
                            addr_b => reg_addr_b, 
                            addr_c => memory_reg_addr_c,
                            wr_en  => memory_reg_wr_en,
                            data   => data_in_RF, 
                            out_a  => reg_out_a, 
                            out_b  => reg_out_b                                                       
                         ) ;
                                               
                         
    inst_ALU : ALU
               port map(
                    clk => clk,
                    rst => decode_ALU_rst,
                    op  => reg_op_code,   
                    A   => reg_out_a,
                    B   => mux_reg_out_b,
                    C   => ALU_output,
                    rdy => ALU_rdy
                ) ;                     
                                                          
                         

    --------------------
    -- DECODING LOGIC --
    --------------------
    
    
    -- op
    --  000 : A+B
    --  001 : A-B 
    --  010 : A*B
    --  011 : A/B 
    --  100 : A XOR B
    --  101 : A OR B
    --  110 : A AND B 
    --- 111 : A (USED FOR LOAD/STORE). 
    
                        
    instruction <= IR(31 downto 26) when master_bubble='0' and latency_cycle="00" and halt = '0' else "000000" ;
    instruction_label <= instruction(5 downto 1) ;        
    fetch_store_select <= '1' when IR(31 downto 27) = "00100" else '0' ; -- ?? 
    fetch_store_label <= '1' when instruction_label = "00100" else '0' ; -- ??
    load_label  <= '1' when IR(31 downto 27) = "00011" else '0' ;
    fetch_reg_addr_c <= IR(25 downto 21) ;     
    fetch_ram_load <= '1' when instruction_label="00011"  else '0' ;   
    reg_addr_a <= IR(25 downto 21) when fetch_store_select = '1' or label_set='1' or fetch_jump = '1' else IR(20 downto 16) ; -- FOR STORE / JUMP / SEQ / SLT ; 
    reg_addr_b <= IR(20 downto 16) when fetch_store_select = '1' or label_set='1' or fetch_jump = '1' else IR(15 downto 11) ; -- FOR STORE / JUMP / SEQ / SLT ;


    op_code <= "000" when instruction_label = "00101" else   
               "001" when instruction_label = "00110" or instruction_label = "01110" or instruction_label="01111" else -- SUB or SLT or SEQ 
               "010" when instruction_label = "00111" else                     
               "011" when instruction_label = "01000" else               
               "100" when instruction_label = "01001" else
               "101" when instruction_label = "01010" else
               "110" when instruction_label = "01011" else               
               "111" ;
               
    reg_wr_en <= '1' when (instruction_label = "00101"  or instruction_label = "00110"  or instruction_label = "00111"  or instruction_label = "01000" or instruction_label = "00011" or instruction = "000101" or instruction_label = "01001" or instruction_label = "01010" or instruction_label = "01011"  ) and master_bubble = '0' else '0' ;                        
    ram_wr_en <= '1' when fetch_store_label = '1' and master_bubble = '0' else '0' ; -- '1' when STORE.                                                
    fetch_ALU_rst <= '1' when (instruction_label = "00111"  or instruction_label = "01000") else  '0' ;
    
    data_in_RF <= memory_ALU_output when memory_ram_load='0' else ram_out_a ;
                   
    -- multiplexer for STORE & LOAD                   
    decode_ram_addr_c <= buffer_ram_addr_c when mult_IR='1' else
                         reg_out_b(9 downto 0) when decode_store_label='1' else
                         reg_out_a(9 downto 0) ;  
                         
    fetch_branch_flag <= "01" when instruction_label="01110" else 
                         "10" when instruction_label="01111" else
                         "00" ; 
                                         
                                         
    tmp_jump_BRFT <= '1' when ( IR(31 downto 27)="10001" and branch_flag='1') else '0' ;                                            
    tmp_jump_BRFF <= '1' when ( IR(31 downto 27)="10010" and branch_flag='0') else '0' ;
    fetch_jump <= '1' when (IR(31 downto 27)="10000" or tmp_jump_BRFT='1' or tmp_jump_BRFF='1') and diff = '0'  else '0' ; 
    label_set <= '1'  when IR(31 downto 27)="01110" or IR(31 downto 27)="01111" else '0' ;
    
    fetch_halt <= '1' when instruction = "000001" else '0' ;                                                                                    
                                                             
    --------------------                    
    -- LITTERAL LOGIC --
    -------------------- 
    
    mux_reg_out_b <= reg_out_b when mux_reg_out_b_input = '0' else input_b ;
                    
    -------------------------                    
    -- BUBBLING LOGIC      --
    -------------------------
    
    logic_a <= '1' when ((reg_addr_a = decode_reg_addr_c) and  (decode_reg_wr_en='1' or (decode_ram_wr_en='1' and load_label='1')))                        
                      or ((reg_addr_a = execute_reg_addr_c)and (execute_reg_wr_en='1' or (execute_ram_wr_en='1' and load_label='1')))                        
                      or ((reg_addr_a = memory_reg_addr_c) and (memory_reg_wr_en='1'))  else '0' ;
                      
    logic_b <= '1' when ((reg_addr_b = decode_reg_addr_c) and (decode_reg_wr_en='1' or (decode_ram_wr_en='1' and load_label='1')))
                or ((reg_addr_b = execute_reg_addr_c)and (execute_reg_wr_en='1' or (execute_ram_wr_en='1' and load_label='1')))                        
                or ((reg_addr_b = memory_reg_addr_c) and (memory_reg_wr_en='1' ))  else '0' ; -- TO DO RAJOUTER FLAG LITTERAL !!!
                
                
    logic_jump_inst <= '1' when IR(31 downto 27) = "10001" or IR(31 downto 27) = "10010" else '0' ;
                          
                
    logic_jump <= '1' when diff = '1' 
                      or (logic_jump_inst = '1' and decode_branch_flag /= "00")
                      or (logic_jump_inst = '1' and execute_branch_flag /= "00")  
                      else '0' ;                                        
                                                                                         
    bubble <= '1' when (logic_a='1' or logic_b='1' or logic_jump='1' or decode_ALU_rst='1' or ALU_rdy='0' or halt='1') else '0' ;    
    master_bubble <= bubble or old_bubble ;
    
    jump_signal_ctrl <= '1' when (diff = '1' and (branch_flag='1' or jump_instuction='1')) else '0' ;
     
     
    sig_halt <= '1' when halt='1' 
            and decode_reg_wr_en='0' 
            and execute_reg_wr_en = '0' 
            and memory_reg_wr_en='0' 
            and decode_ram_wr_en = '0' 
            and execute_ram_wr_en = '0'
            else '0' ;          
    
    process(clk)
    begin
        if rising_edge(clk) then
            old_bubble <= bubble ; 
            old_old_bubble <= old_bubble ; 
        end if ; 
    end process ; 
    
    ------------------
    -- BRANCH LOGIC --
    ------------------
    
    process(clk)
    begin
        if rising_edge(clk) then
            if decode_branch_flag="01" then -- SLT
                branch_flag <= ALU_output(15) ; -- take sign   
            else 
                if decode_branch_flag="10" then -- SEQ
                    if ALU_output=zero then
                        branch_flag <= '1' ; 
                    else                    
                        branch_flag <= '0' ;     
                    end if ; 
                end if ; 
            end if ; 
        end if ; 
    end process ; 
    
    -----------------
 
                  
    -------------------------------------
    -- PIPELINE LOGIC                  --
    -------------------------------------
    
    process(clk)
    begin               
        if rising_edge(clk) then   
            -----------------------
            -- BRANCH MANAGEMENT --
            -----------------------                 
            if fetch_jump = '1' and diff='0' and latency_cycle="00" then
                    diff <= '1' ;
                if instruction_label = "10000" then
                    jump_instuction <= '1' ;
                else
                    jump_instuction <= '0' ; 
                end if ;
                    
                --if (instruction_label = "10000" or branch_flag='1') and has_jumped = '0' then                                                       
                    if mult_IR = '0' then                
                        jump_address <= reg_out_a(7 downto 0) ;
                    else                         
                        jump_address <= IR(25 downto 18) ;
                    end if ;                   
                     --   has_jumped <= '1' ; 
                --end if ;                                        
            else -- fetch jump
                diff <= '0' ;  
            end if ; 
            ------------
            -- Others --
            ------------                                            
            if rst='1' then
                halt <= '0' ;
                PC <= (others=>'0') ; 
                IR <= (others=>'0') ; 
--                old_PC <= (others=>'0') ; -- à supprimer probablement ?? (pour gagner en surface)
            else       
                if sig_halt='0' then                                            
                    -- HALT SYSTEM
                    if fetch_halt='1' then 
                        halt <= '1' ; 
                    end if ;         
                    -- IR MANAGEMENT                               
                    if master_bubble = '0' or jump_signal_ctrl='1' then                    
                            IR <= output_rom ;                                                                                       
                        end if ;                                
                    -- PC MANAFEMENT                                                               
                    if jump_signal_ctrl='1' then                        
                        -- Litteral
                            PC <= jump_address ;
                            old_PC <= jump_address ; 
                            --has_jumped <= '0' ;                                                                                  
                        else                                                                                      
                            if bubble = '0'  then                                                                                  
                                PC <= std_logic_vector(unsigned(PC)+1) ;
                                old_PC <= PC ;                                                                                                                                                                                                                                  
                            else                                                                                         
                                PC <= old_PC ;                                               
                            end if ;   
                        end if ;                                                                       
                        if jump_signal_ctrl='1' and latency_cycle = "00" then 
                            latency_cycle <= "10" ;
                        else 
                            latency_cycle <= '0' & latency_cycle(1 downto 1) ;                                 
                        end if ;                              
                    --------------                                                          
                    -- PIPELINE --
                    --------------                                                                                      
                    if ALU_rdy = '1' and decode_ALU_rst='0' then -- PIPELINE IS BLOCKED WHILE ALU IS BUSY.                                                                                                                                                                                 
                        ----------------------------------------                                                                                                   
                        buffer_ram_addr_c <= IR(20 downto 11) ; 
                        mult_IR <= IR(26) ;                                          
                    -- DECODE                        
                        if instruction_label = "01110" or instruction_label="01111" then -- for SLT and SEQ
                            input_b <= IR(20 downto 5) ;
                        else
                            input_b <= IR(15 downto 0) ;
                        end if ;                                         
                        mux_reg_out_b_input <= IR(26) ;             
                        decode_reg_addr_c <= fetch_reg_addr_c ;                                                     
                        decode_reg_wr_en  <= reg_wr_en ;  
                        decode_ram_wr_en  <= ram_wr_en ;
                        decode_ram_load <= fetch_ram_load ;
                        reg_op_code <= op_code ;
                        decode_store_label <= fetch_store_label ; 
                        decode_branch_flag <= fetch_branch_flag ;
                        decode_jump <= fetch_jump ;                                                                                  
                    -- EXECUTE                 
                        execute_reg_addr_c <= decode_reg_addr_c ;
                        execute_ram_addr_c <= decode_ram_addr_c ; 
                        execute_reg_wr_en <= decode_reg_wr_en ;
                        execute_ram_wr_en <= decode_ram_wr_en ;  
                        execute_ALU_output <= ALU_output ;    
                        execute_ram_load <= decode_ram_load ;     
                        --execute_branch_flag <= decode_branch_flag ;                                               
                    -- MEMORY                 
                        memory_reg_addr_c <= execute_reg_addr_c ;
                        memory_reg_wr_en <= execute_reg_wr_en ;
                        memory_ALU_output <= execute_ALU_output ;
                        memory_ram_load <= execute_ram_load ;                              
                    -- WRITE_BACK                                                                                                                                                                    
                    end if ; -- ALU RDY.
                end if ; -- Rst  
            end if ; -- halt_sig ;                           
        end if ; -- rising_edge clk    
    end process ; 
    
    --------------------------
    -- ALU RESET MANAGEMENT --
    --------------------------
    
    process(clk)
    begin
        if rising_edge(clk) then
            if decode_ALU_rst = '0' then
                decode_ALU_rst <= fetch_ALU_rst ;
            else
                decode_ALU_rst <= '0' ; 
            end if ;                 
        end if ;     
    end process ; 
    
    -- SIGNAL ASSIGNEMENT
    
    output_PC <= PC ;
    data_a    <= execute_ALU_output ;
    addr_a    <= execute_ram_addr_c ; 
    wr_a      <= execute_ram_wr_en  ; 
    ram_out_a <= q_a ; 
    
    --led <= '1' & halt ; 
    
         


end Behavioral;

