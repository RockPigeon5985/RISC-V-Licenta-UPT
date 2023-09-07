library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Registers is
    port ( 
		clk : in STD_LOGIC;
        read_reg1 : in STD_LOGIC_VECTOR(4 downto 0);
        read_reg2 : in STD_LOGIC_VECTOR(4 downto 0);
        write_reg : in STD_LOGIC_VECTOR(4 downto 0);
        write_data : in STD_LOGIC_VECTOR(31 downto 0);
        reg_write_enable : in STD_LOGIC;
        read_data1 : out STD_LOGIC_VECTOR(31 downto 0);
        read_data2 : out STD_LOGIC_VECTOR(31 downto 0)
	);
end Registers;

architecture Behavioral of Registers is
    type reg_data_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal registers : reg_data_array := (others => (others => '0'));
	
begin	
    process(clk)
    begin
        if rising_edge(clk) then
            if reg_write_enable = '1' then
				if not(write_reg(0) = '0' and write_reg(1) = '0' and write_reg(2) = '0') then
                	registers(to_integer(unsigned(write_reg))) <= write_data;
				end if;
            end if;
            
            read_data1 <= registers(to_integer(unsigned(read_reg1)));
            read_data2 <= registers(to_integer(unsigned(read_reg2)));
        end if;
    end process;
end Behavioral;

--Test bench
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Registers_TB is
end Registers_TB;

architecture Behavioral of Registers_TB is
    component Registers
        port ( 
            clk : in STD_LOGIC;
            read_reg1 : in STD_LOGIC_VECTOR(4 downto 0);
            read_reg2 : in STD_LOGIC_VECTOR(4 downto 0);
            write_reg : in STD_LOGIC_VECTOR(4 downto 0);
            write_data : in STD_LOGIC_VECTOR(31 downto 0);
            reg_write_enable : in STD_LOGIC;
            read_data1 : out STD_LOGIC_VECTOR(31 downto 0);
            read_data2 : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    signal tb_clk : STD_LOGIC := '0';
    signal tb_read_reg1, tb_read_reg2, tb_write_reg : STD_LOGIC_VECTOR(4 downto 0);
    signal tb_write_data : STD_LOGIC_VECTOR(31 downto 0); 
    signal tb_reg_write_enable : STD_LOGIC;
    signal tb_read_data1, tb_read_data2 : STD_LOGIC_VECTOR(31 downto 0);
    

begin
	tb_clk <= not(tb_clk) after 5ns;
	
	-- Write data to register 2
	tb_write_data <= X"12345678";
	tb_write_reg <= "00010";
    tb_reg_write_enable <= '0', '1' after 5ns, '0' after 10ns;
	
	-- Read data from registers 2 and 1
	tb_read_reg1 <= "00010";
    tb_read_reg2 <= "00001";
		
    uut: Registers port map (tb_clk, tb_read_reg1, tb_read_reg2, tb_write_reg, tb_write_data, tb_reg_write_enable, tb_read_data1, tb_read_data2);
end Behavioral;
