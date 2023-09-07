library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package types_pkg is
    type mem_array is array (0 to 1023) of STD_LOGIC_VECTOR(31 downto 0);
end package types_pkg;