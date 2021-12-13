
library STD;
 use STD.textio.all;


  library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_misc.all;
    use IEEE.std_logic_arith.all;
    

library work;


package tecu_package is



constant b_w : integer := 8;
constant mac_row_size : integer := 32;
constant mem_size : integer := 16;



--types
  type pattern_memory_type is array (0 to mem_size-1) of Std_logic_vector(b_w+b_w-1 downto 0);     
  type memory_type_16xmem_size is array (0 to mem_size-1) of Std_logic_vector(b_w+b_w-1 downto 0); 
  type memory_type_16xb_w_size is array (0 to mem_size-1) of Std_logic_vector(b_w-1 downto 0);     
  type memory_type_16x5_size is array (0 to mem_size-1) of Std_logic_vector(4 downto 0);     
  function finding_first_one(
   signal a : std_logic_vector(mac_row_size-1 downto 0))
    return integer;

end package tecu_package;

package body tecu_package is
 
              --------------------------------------------------------------
function finding_first_one (signal a : std_logic_vector(mac_row_size-1 downto 0)) return integer is
begin    
for i in a'low to a'high loop
if a(i) = '1' then
return i;
end if;
end loop;    
-- all zero
return -1;
end function;
--------------------------------------------------------------
end package body tecu_package;


