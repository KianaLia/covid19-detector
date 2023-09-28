--------------------------------------------------------------------------------
-- This is the test file for nn.vhd
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY nn_t IS
END nn_t;
 
ARCHITECTURE behavior OF nn_t IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT nn
    PORT(
         x_in : IN  std_logic_vector(7 downto 0);
         clk : IN  std_logic;
         state : OUT  std_logic_vector(2 downto 0);
         y : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal x_in : std_logic_vector(7 downto 0) := (others => '0');
   signal clk : std_logic := '0';

 	--Outputs
   signal state : std_logic_vector(2 downto 0);
   signal y : std_logic;

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: nn PORT MAP (
          x_in => x_in,
          clk => clk,
          state => state,
          y => y
        );

	clk <= not clk after 2ns;
	x_in <= "11111000" after 1ns;

END;
