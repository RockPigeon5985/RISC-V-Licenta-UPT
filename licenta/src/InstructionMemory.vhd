library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types_pkg.all;

entity InstructionMemory is
    port (
        clk : in STD_LOGIC;
        address : in STD_LOGIC_VECTOR(31 downto 0);
        instruction : out STD_LOGIC_VECTOR(31 downto 0);
        memory : in mem_array
    );
end entity InstructionMemory;

architecture Behavioral of InstructionMemory is
begin
 process(clk)
    begin
        if rising_edge(clk) then
            instruction <= memory(to_integer(unsigned(address)));
        end if;
    end process;
end architecture Behavioral;


-- Test bench
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types_pkg.all;

entity InstructionMemory_TB is
end InstructionMemory_TB;

architecture Behavioral of InstructionMemory_TB is
    component InstructionMemory
        port ( 
			clk : in STD_LOGIC;
            address : in STD_LOGIC_VECTOR(31 downto 0);
            instruction : out STD_LOGIC_VECTOR(31 downto 0);
			memory : in mem_array
		);
    end component;
	
    signal tb_clk : STD_LOGIC := '0';
    signal tb_address : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal tb_instruction : STD_LOGIC_VECTOR(31 downto 0);
	signal tb_memory : mem_array;

begin
	tb_memory(0) <= X"00C30333";  -- add x1, x2, x3
	tb_memory(1) <= X"40C30333";  -- sub x1, x2, x3	 
	
	tb_clk <= not tb_clk after 5ns;	
	tb_address <= (others => '0'), (0 => '1', others => '0') after 15ns, (others => '0') after 25ns;
		
	uut : InstructionMemory port map (tb_clk, tb_address, tb_instruction, tb_memory);
end Behavioral;
