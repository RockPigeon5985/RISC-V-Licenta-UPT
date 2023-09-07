library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types_pkg.all;

entity DataMemory is
    port ( 
		clk : in STD_LOGIC;
        address : in STD_LOGIC_VECTOR(31 downto 0);
        write_data : in STD_LOGIC_VECTOR(31 downto 0);
        mem_write_enable : in STD_LOGIC;
        read_data : out STD_LOGIC_VECTOR(31 downto 0);
		mem_read_enable : in STD_LOGIC
	);
end DataMemory;

architecture Behavioral of DataMemory is
    signal memory : mem_array := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if mem_write_enable = '1' then
                memory(to_integer(unsigned(address))) <= write_data;
            end if;
            
			if mem_read_enable = '1' then
            	read_data <= memory(to_integer(unsigned(address)));
			end if;
        end if;
    end process;
end Behavioral;

-- Test bench
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DataMemory_TB is
end DataMemory_TB;

architecture Behavioral of DataMemory_TB is
    signal tb_clk : STD_LOGIC := '0';
    signal tb_address : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal tb_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal tb_mem_write_enable : STD_LOGIC := '0';
    signal tb_read_data : STD_LOGIC_VECTOR(31 downto 0);
	signal tb_mem_read_enable : STD_LOGIC := '0';
    
    component DataMemory
        port ( 
			clk : in STD_LOGIC;
        	address : in STD_LOGIC_VECTOR(31 downto 0);
        	write_data : in STD_LOGIC_VECTOR(31 downto 0);
        	mem_write_enable : in STD_LOGIC;
        	read_data : out STD_LOGIC_VECTOR(31 downto 0);
			mem_read_enable : in STD_LOGIC
		);
    end component;
begin
	tb_clk <= not tb_clk after 5ns;
	tb_write_data <= X"ABCDEF01";
	tb_address <= (0 => '1', others => '0');
	tb_mem_write_enable <= '1' after 10 ns, '0' after 25 ns;
	tb_mem_read_enable <= '1' after 25ns;
	
    uut: DataMemory port map (tb_clk, tb_address, tb_write_data, tb_mem_write_enable, tb_read_data, tb_mem_read_enable);
end Behavioral;
