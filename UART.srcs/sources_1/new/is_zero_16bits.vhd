----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.05.2017 14:05:29
-- Design Name: 
-- Module Name: is_zero_16bits - Behavioral
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

entity is_zero_16bits is
  Port (  
    A : in std_logic_vector(15 downto 0) ; 
    is_zero : out std_logic     
   );
end is_zero_16bits;

architecture Structural of is_zero_16bits is


	signal drive : std_logic_vector(15 downto 0) ;  

begin

    drive(0) <= not(A(0)) ; 
	drive_gen : for I in 1 to 15 generate
		drive(I) <= drive(I-1) and not(A(I)) ;	
	end generate drive_gen ; 
	is_zero <= drive(15) ; 


end Structural;
