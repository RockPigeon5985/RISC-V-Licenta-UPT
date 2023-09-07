library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    port (
		op : in STD_LOGIC_VECTOR(2 downto 0);
        a : in STD_LOGIC_VECTOR(31 downto 0);
        b : in STD_LOGIC_VECTOR(31 downto 0);
        result : out STD_LOGIC_VECTOR(31 downto 0);
		zero : out STD_LOGIC 
	);
end ALU;

architecture Behavioral of ALU is 
signal temp_result : STD_LOGIC_VECTOR(31 downto 0);

begin	
    process
    begin 
		wait on op, a, b;
        case op is
            when "000" => -- Addition
                temp_result <= std_logic_vector(unsigned(a) + unsigned(b));
                
            when "001" => -- Subtraction
                temp_result <= std_logic_vector(unsigned(a) - unsigned(b));
                
            when "010" => -- Bitwise AND
                temp_result <= a and b;
                
            when "011" => -- Bitwise OR
                temp_result <= a or b;
                
            when others =>
				temp_result <= (others => 'U'); -- Default: Set result to zero
        end case;

        -- Check if result is zero
        if temp_result = X"00000000" then
            zero <= '1';
		else
			zero <= '0';
        end if;
				
		wait on temp_result;
		result <= temp_result;

    end process;
end Behavioral;

-- Test bench
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_Testbench is
end ALU_Testbench;

architecture tb_arch of ALU_Testbench is
    component ALU
        port (
			op : in STD_LOGIC_VECTOR(2 downto 0);
            a : in STD_LOGIC_VECTOR(31 downto 0);
            b : in STD_LOGIC_VECTOR(31 downto 0);
            result : out STD_LOGIC_VECTOR(31 downto 0);
            zero : out STD_LOGIC 
		);
    end component;
    
	signal tb_op : STD_LOGIC_VECTOR(2 downto 0);
    signal tb_a : STD_LOGIC_VECTOR(31 downto 0);
    signal tb_b : STD_LOGIC_VECTOR(31 downto 0);
    signal tb_result : STD_LOGIC_VECTOR(31 downto 0);
    signal tb_zero : STD_LOGIC;
    
begin
    uut : ALU port map (tb_op, tb_a, tb_b, tb_result, tb_zero);
   
    process
    begin
        -- Test case 1: Addition
        tb_a <= X"00000004"; -- 4
        tb_b <= X"00000006"; -- 6 
		tb_op <= "000";
        wait for 10 ns;
  		
        -- Test case 2: Subtraction
        
        tb_a <= X"00000008"; -- 8
        tb_b <= X"00000005"; -- 5 
		tb_op <= "001";
        wait for 20 ns;
       
        -- Test case 3: Bitwise AND
        
        tb_a <= X"0000000C"; -- 12
        tb_b <= X"00000007"; -- 7 
		tb_op <= "010";
        wait for 20 ns;
        
        -- Test case 4: Bitwise OR
        
        tb_a <= X"0000000A"; -- 10
        tb_b <= X"00000006"; -- 6
		tb_op <= "011";
        wait for 20 ns;
   
		tb_op <= "UUU";
		wait;
    end process;
end tb_arch;
