LIBRARY ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity nn is
    Port ( x_in : in  STD_LOGIC_VECTOR (7 downto 0);
           clk : in  STD_LOGIC;
			  state: out STD_LOGIC_VECTOR(2 downto 0);
           y : out  STD_LOGIC);
end nn;

architecture Behavioral of nn is
--- defining needed types
type array8 is array (0 to 7) of signed(7 downto 0);
type array4 is array (0 to 3) of signed(7 downto 0);
type array8_4 is array (0 to 7) of array4;
type array2 is array (0 to 1) of signed(7 downto 0);
type array4_2 is array (0 to 3) of array2;

--- defining layer charactristics (weights, biases and output arrays)
--- first layer (hidden layer)
signal w_mem1: array8_4;
signal bias1: array4;
--- second layer (hidden layer)
signal w_mem2: array4_2;
signal bias2: array2;
--- third layer (output layer)
signal w_mem3: array2;
signal bias3: signed(7 downto 0);

signal layer1_out: array4;
signal layer2_out: array2;
signal layer3_out: signed(7 downto 0);
--- layer flag
signal layer: integer range 0 to 4 := 1;

begin
--- initializing layers (weights and biases for each layer)
--- first layer weights(8 inputs and 4 neurons (8*4))
w_mem1(0) <= ("11111110", "00000001", "11111111", "11111111");
w_mem1(1) <= ("11111110", "00000001", "11111111", "11111111");
w_mem1(2) <= ("11111110", "00000000", "00000000", "00000010");
w_mem1(3) <= ("11111110", "00000001", "00000000", "00000001");
w_mem1(4) <= ("00000000", "11111111", "00000000", "00000000");
w_mem1(5) <= ("11111111", "00000000", "11111111", "00000001");
w_mem1(6) <= ("00000000", "00000000", "11111111", "00000000");
w_mem1(7) <= ("00000000", "00000000", "11111111", "00000000");
--- first layer biases
bias1 <= ("00000000", "11111110", "11111111", "11111111");
--- second layer (4 inputs and 2 neurons (4*2))
w_mem2(0) <= ("11111111", "00000010");
w_mem2(1) <= ("00000001", "11111110");
w_mem2(2) <= ("11111111", "11111111");
w_mem2(3) <= ("00000000", "00000000");
--- second layer biases
bias2 <= ("11111110", "00000000");
--- third layer (2 inputs and 1 neuron (2*1))
w_mem3 <= ("00000000", "11111011");
--- third layer bias
bias3 <= "11111111";

p_net: process(clk)
--- defining needed variables 
--- row and column counter
variable row: integer range 0 to 8 := 0;
variable col: integer range 0 to 4 := 0;
--- transaction variables
variable w1_row: array4;
variable w2_row: array2;
variable w: signed(7 downto 0);
variable x: signed(7 downto 0);
--- output keeper variables
variable mult_out: signed(15 downto 0);
variable adder_out: signed(7 downto 0) := X"00";
variable neuron_out: signed(7 downto 0) := X"00";
--- zero number for comparing
variable zero: signed(7 downto 0) := X"00";

begin

if rising_edge(clk) then

	--- firs layer logic
	if layer=1 then
		--- 1*8 to 8*4 matrix multiplication
		if (row < 8 and col < 4) then
			--- extracting a single weight from memory
			w1_row := w_mem1(row);
			w := w1_row(col);
			--- preparing right feature
			x := "0000000" & x_in(row);
			--- multiplying the weight and the feature
			mult_out := x * w;
			adder_out := adder_out + (mult_out(15) + mult_out(6 downto 0));
			
			row := row + 1;
			
			state <= "000";
		
		elsif (row = 8 and col < 4) then
			--- switching to next column
			neuron_out := adder_out + bias1(col);
			
			--- implementation of RELU activation function logic
			if neuron_out > zero then
				layer1_out(col) <= neuron_out;
			else
				layer1_out(col) <= zero;
			end if;
			
			row := 0;
			col := col + 1;
			
			state <= "001";
		else
			--- moving to next layer
			layer <= 2;
			--- initializing properties for next layer
			row := 0;
			col := 0;
			adder_out := X"00";
			
			state <= "010";
		
		end if;
		
	end if;
	
	--- second layer logic
	if layer=2 then
		--- 1*4 to 4*2 matrix multiplication
		if (row < 4 and col < 2) then
			--- extracting a single weight from memory
			w2_row := w_mem2(row);
			w := w2_row(col);
			--- preparing right feature ( down sizing to 8bit signed)
			x := layer1_out(row)(7 downto 0);
			--- multiplying the weight and the feature
			mult_out := x * w;
			adder_out := adder_out + (mult_out(15) + mult_out(6 downto 0));
			
			row := row + 1;
			
			state <= "011";
			
		elsif (row = 4 and col < 2) then
			--- switching to next column
			neuron_out := adder_out + bias2(col);
			
			--- implementation of RELU activation function logic
			if neuron_out > zero then
				layer2_out(col) <= neuron_out;
			else
				layer2_out(col) <= zero;
			end if;
			
			row := 0;
			col := col + 1;
			
			state <= "100";
		else
			--- moving to next layer
			layer <= 3;
			--- initializing variables for next layer calculations
			row := 0;
			col := 0;
			adder_out := X"00";
			
			state <= "101";
		
		end if;
		
	end if;
	--- third layer logic (output layer)
	if layer=3 then
		--- 1*2 to 2*1 matrix multiplication logic
		if row < 2 then
			--- extracting a single weight from memory
			w := w_mem3(row);
			--- preparing the feature 
			x := layer2_out(row)(7 downto 0);
			--- multiplying the weight and the feature matrix
			mult_out := x * w;
			adder_out := adder_out + (mult_out(15) + mult_out(6 downto 0));
			
			state <= "110";
			
			row := row + 1;
			
		else
			--- calculating final output of the layer
			layer3_out <= adder_out + bias3;
			
			--- implementation of SIGMOID activation function logic
			if layer3_out > zero then
				y <= '1';
			else
				y <= '0';
			end if;
			--- setting state and layer variables to Final state value
			state <= "111";
			layer <= 4;
		end if;
	
	end if;

end if;

end process;
end Behavioral;

