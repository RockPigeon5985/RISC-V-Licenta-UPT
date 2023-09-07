library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types_pkg.all;

entity RISC_V_Processor is
	    port (
			-- clock for all components	
			clk : in STD_LOGIC;

			--signals for instruction memory component
			instructions_memory : in mem_array;
            pc : out STD_LOGIC_VECTOR(31 downto 0);
            instruction : out STD_LOGIC_VECTOR(31 downto 0);
			
			--signals for registers component
			rs1 : out STD_LOGIC_VECTOR(4 downto 0);
           	rs2 : out STD_LOGIC_VECTOR(4 downto 0);
           	rd : out STD_LOGIC_VECTOR(4 downto 0);
           	rd_write_data : out STD_LOGIC_VECTOR(31 downto 0);
           	rd_write_enable : out STD_LOGIC;
           	rs1_data : out STD_LOGIC_VECTOR(31 downto 0);
           	rs2_data : out STD_LOGIC_VECTOR(31 downto 0);
			  
			--signals for ALU component
			alu_op : out STD_LOGIC_VECTOR(2 downto 0);
        	alu_a : out STD_LOGIC_VECTOR(31 downto 0);
        	alu_b : out STD_LOGIC_VECTOR(31 downto 0);
        	alu_result : out STD_LOGIC_VECTOR(31 downto 0);
			alu_zero : out STD_LOGIC;
			
			--signals for data memory component
           	mem_address : out STD_LOGIC_VECTOR(31 downto 0);
           	mem_write_data : out STD_LOGIC_VECTOR(31 downto 0);
           	mem_write_enable : out STD_LOGIC;
           	mem_read_data : out STD_LOGIC_VECTOR(31 downto 0); 
			mem_read_enable : out STD_LOGIC;
			 
			--aditionals signals for decoding instructions
			funct7 : out STD_LOGIC_VECTOR(6 downto 0);
	 		funct3 : out STD_LOGIC_VECTOR(2 downto 0);
	 		opcode : out STD_LOGIC_VECTOR(6 downto 0);
	 		funct : out STD_LOGIC_VECTOR(9 downto 0)	
        );
end RISC_V_Processor;

architecture Behavioral of RISC_V_Processor is   
	component InstructionMemory
        port (
            clk : in STD_LOGIC;
            address : in STD_LOGIC_VECTOR(31 downto 0);
            instruction : out STD_LOGIC_VECTOR(31 downto 0);
			memory : in mem_array
        );
    end component;	

	component Registers is
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
	
	component ALU is
    port (
		op : in STD_LOGIC_VECTOR(2 downto 0);
        a : in STD_LOGIC_VECTOR(31 downto 0);
        b : in STD_LOGIC_VECTOR(31 downto 0);
        result : out STD_LOGIC_VECTOR(31 downto 0);
		zero : out STD_LOGIC 
	);
	end component;

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
	
	-- signals for InstructionMemory component 
    signal temp_pc : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal temp_instruction : STD_LOGIC_VECTOR(31 downto 0);
	
	-- signals for Registers component
	signal temp_rs1 : STD_LOGIC_VECTOR(4 downto 0);
	signal temp_rs2 : STD_LOGIC_VECTOR(4 downto 0);
	signal temp_rd : STD_LOGIC_VECTOR(4 downto 0);
	signal temp_rd_write_data : STD_LOGIC_VECTOR(31 downto 0);
	signal temp_rd_write_enable : STD_LOGIC;
	signal temp_rs1_data : STD_LOGIC_VECTOR(31 downto 0);
    signal temp_rs2_data : STD_LOGIC_VECTOR(31 downto 0);
	
	-- signals for ALU
	signal temp_alu_result : STD_LOGIC_VECTOR(31 downto 0);
	signal temp_alu_zero : STD_LOGIC;
	signal temp_alu_a : STD_LOGIC_VECTOR(31 downto 0);
	signal temp_alu_b : STD_LOGIC_VECTOR(31 downto 0);
	signal temp_alu_op : STD_LOGIC_VECTOR(2 downto 0);
	
	-- signals for Data Memory component
	signal temp_mem_address : STD_LOGIC_VECTOR(31 downto 0);
	signal temp_mem_write_data :	STD_LOGIC_VECTOR(31 downto 0);
	signal temp_mem_write_enable	: STD_LOGIC;
	signal temp_mem_read_data : STD_LOGIC_VECTOR(31 downto 0);	
	signal temp_mem_read_enable : STD_LOGIC;
	
	-- additional signals for decoding instruction
	signal temp_funct7 : STD_LOGIC_VECTOR(6 downto 0);
	signal temp_funct3 : STD_LOGIC_VECTOR(2 downto 0);
	signal temp_opcode : STD_LOGIC_VECTOR(6 downto 0);
	signal temp_funct : STD_LOGIC_VECTOR(9 downto 0);	
	
	begin
	-- Instantiate Instruction Memory
    instruction_memory : InstructionMemory port map (clk, temp_pc, temp_instruction, instructions_memory);
	
	-- Instantiate Registers
    registers_unit : Registers port map (clk, temp_rs1, temp_rs2, temp_rd, temp_rd_write_data, temp_rd_write_enable, temp_rs1_data, temp_rs2_data);
	
	-- Instantiate ALU
	alu_unit : ALU port map (temp_alu_op, temp_alu_a, temp_alu_b, temp_alu_result, temp_alu_zero);
	
	-- Instantiate Data Memory
    data_memory : DataMemory port map (clk, temp_mem_address, temp_mem_write_data, temp_mem_write_enable, temp_mem_read_data, temp_mem_read_enable);

	
	process
	begin			
		wait on clk until rising_edge(clk);
		pc <= temp_pc;
		
		rd_write_enable <= '0';
		temp_rd_write_enable <= '0';
		
		wait on temp_instruction;
		instruction <= temp_instruction;
		opcode <= temp_instruction(6 downto 0);
		temp_opcode <= temp_instruction(6 downto 0);
		
		rs1 <= temp_instruction(19 downto 15);
		temp_rs1 <= temp_instruction(19 downto 15);
				
		funct3 <= temp_instruction(14 downto 12);
		temp_funct3 <= temp_instruction(14 downto 12);
		
		rd <= temp_instruction(11 downto 7); 
		temp_rd <= temp_instruction(11 downto 7);
		
		wait until rising_edge(clk);
		
		if temp_opcode = "0110011" then -- R-type instruction
			
				-- decode the remaining fields of instruction
				funct7 <= temp_instruction(31 downto 25);
				temp_funct7 <= temp_instruction(31 downto 25);
				
				rs2 <= temp_instruction(24 downto 20);
				temp_rs2 <= temp_instruction(24 downto 20);
				
				wait on temp_rs2_data;
				alu_a <= temp_rs1_data;
				temp_alu_a <= temp_rs1_data;
				rs1_data <= temp_rs1_data;
		
				-- second input for ALU is data from rs2
				rs2_data <= temp_rs2_data;
				alu_b <= temp_rs2_data;
				temp_alu_b <= temp_rs2_data;	
				
				-- concatenate funct3 with funct7 for case structure
				funct <= temp_funct3 & temp_funct7;
				temp_funct <= temp_funct3 & temp_funct7;
				
				wait on temp_funct, temp_alu_b;
				case temp_funct is
					when "0000000000" => alu_op <= "000"; temp_alu_op <= "000";   -- add
					when "0000100000" => alu_op <= "001"; temp_alu_op <= "001";  -- sub
					when others => alu_op <= "UUU";
				end case;
				
				wait on temp_alu_result;
				alu_result <= temp_alu_result;
				alu_zero <= temp_alu_zero;
				
				rd_write_enable <= '1';
				temp_rd_write_enable <= '1'; 
				
				rd_write_data <= temp_alu_result;
				temp_rd_write_data <= temp_alu_result;
				
				wait on temp_rd_write_data; 
				--set next pc
				temp_pc <= std_logic_vector(unsigned(temp_pc) + 1);
				
		elsif temp_opcode = "0010011" then -- I-type instruction for algorithmic opperations
				-- decode the remaining fields of instruction
				temp_alu_b <= X"00000" & temp_instruction(31 downto 20); -- second input for ALU is a constant
				alu_b <= X"00000" & temp_instruction(31 downto 20);
				
				alu_a <= temp_rs1_data;
				temp_alu_a <= temp_rs1_data;
				rs1_data <= temp_rs1_data;
				
				case temp_funct3 is
					when "000" => alu_op <= "000"; temp_alu_op <= "000";
					when others => alu_op <= "UUU"; temp_alu_op <= "UUU";
				end case;
				
				wait on temp_alu_result;
				alu_result <= temp_alu_result;
				alu_zero <= temp_alu_zero;
				
				rd_write_enable <= '1';
				temp_rd_write_enable <= '1'; 
				
				rd_write_data <= temp_alu_result;
				temp_rd_write_data <= temp_alu_result;
				
				wait on temp_rd_write_data; 
				--set next pc
				temp_pc <= std_logic_vector(unsigned(temp_pc) + 1);
		end if;
		
		wait on temp_pc;
	end process;
end Behavioral;	

-- Test Bench
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types_pkg.all;

entity RISC_V_Processor_Testbench is
end RISC_V_Processor_Testbench;

architecture tb_arch of RISC_V_Processor_Testbench is
component RISC_V_Processor is
	port (
			clk : in STD_LOGIC;
			instructions_memory : in mem_array;
            pc : out STD_LOGIC_VECTOR(31 downto 0);
            instruction : out STD_LOGIC_VECTOR(31 downto 0);
			
			rs1 : out STD_LOGIC_VECTOR(4 downto 0);
           	rs2 : out STD_LOGIC_VECTOR(4 downto 0);
           	rd : out STD_LOGIC_VECTOR(4 downto 0);
           	rd_write_data : out STD_LOGIC_VECTOR(31 downto 0);
           	rd_write_enable : out STD_LOGIC;
           	rs1_data : out STD_LOGIC_VECTOR(31 downto 0);
           	rs2_data : out STD_LOGIC_VECTOR(31 downto 0);
			   
			alu_op : out STD_LOGIC_VECTOR(2 downto 0);
        	alu_a : out STD_LOGIC_VECTOR(31 downto 0);
        	alu_b : out STD_LOGIC_VECTOR(31 downto 0);
        	alu_result : out STD_LOGIC_VECTOR(31 downto 0);
			alu_zero : out STD_LOGIC;
			
           	mem_address : out STD_LOGIC_VECTOR(31 downto 0);
           	mem_write_data : out STD_LOGIC_VECTOR(31 downto 0);
           	mem_write_enable : out STD_LOGIC;
           	mem_read_data : out STD_LOGIC_VECTOR(31 downto 0);
			mem_read_enable : out STD_LOGIC;
			   
			funct7 : out STD_LOGIC_VECTOR(6 downto 0);
	 		funct3 : out STD_LOGIC_VECTOR(2 downto 0);
	 		opcode : out STD_LOGIC_VECTOR(6 downto 0);
	 		funct : out STD_LOGIC_VECTOR(9 downto 0)	
        );
	end component;
	
	signal tb_clk : STD_LOGIC := '0';
	
	-- signals for InstructionMemory component 
    signal tb_pc : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal tb_instruction : STD_LOGIC_VECTOR(31 downto 0);
	signal tb_instructions_memory : mem_array;
	
	-- signals for Registers component
	signal tb_rs1 : STD_LOGIC_VECTOR(4 downto 0);
	signal tb_rs2 : STD_LOGIC_VECTOR(4 downto 0);
	signal tb_rd : STD_LOGIC_VECTOR(4 downto 0);
	signal tb_rd_write_data : STD_LOGIC_VECTOR(31 downto 0);
	signal tb_rd_write_enable : STD_LOGIC;
	signal tb_rs1_data : STD_LOGIC_VECTOR(31 downto 0);
    signal tb_rs2_data : STD_LOGIC_VECTOR(31 downto 0);
	
	-- signals for ALU
	signal tb_alu_result : STD_LOGIC_VECTOR(31 downto 0);
	signal tb_alu_zero : STD_LOGIC;
	signal tb_alu_a : STD_LOGIC_VECTOR(31 downto 0);
	signal tb_alu_b : STD_LOGIC_VECTOR(31 downto 0);
	signal tb_alu_op : STD_LOGIC_VECTOR(2 downto 0);
	
	-- signals for Data Memory component
	signal tb_mem_address : STD_LOGIC_VECTOR(31 downto 0);
	signal tb_mem_write_data :	STD_LOGIC_VECTOR(31 downto 0);
	signal tb_mem_write_enable	: STD_LOGIC;
	signal tb_mem_read_data : STD_LOGIC_VECTOR(31 downto 0); 
	signal tb_mem_read_enable : STD_LOGIC;
	
	-- additional signals for decoding instruction
	signal tb_funct7 : STD_LOGIC_VECTOR(6 downto 0);
	signal tb_funct3 : STD_LOGIC_VECTOR(2 downto 0);
	signal tb_opcode : STD_LOGIC_VECTOR(6 downto 0);
	signal tb_funct : STD_LOGIC_VECTOR(9 downto 0);	
	
	begin	
	tb_clk <= not(tb_clk) after 10ns;
	
	tb_instructions_memory(0) <= X"00600113"; --addi x2, x0, 6
	tb_instructions_memory(1) <= X"00400193"; --addi x3, x0, 4
	tb_instructions_memory(2) <= X"00218233"; --add x4, x2, x3
	
	uut : RISC_V_Processor port map(
	tb_clk,
	-- instruction
	tb_instructions_memory, tb_pc, tb_instruction,
	-- registers
	tb_rs1, tb_rs2, tb_rd, tb_rd_write_data, tb_rd_write_enable, tb_rs1_data, tb_rs2_data,	
	-- ALU
	tb_alu_op, tb_alu_a, tb_alu_b, tb_alu_result, tb_alu_zero, 
	-- mem
	tb_mem_address, tb_mem_write_data, tb_mem_write_enable, tb_mem_read_data, tb_mem_read_enable,
	-- extra decode
	tb_funct7, tb_funct3, tb_opcode, tb_funct
	);

end tb_arch;   
