
library STD;
 use STD.textio.all;


  library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_misc.all;
    use IEEE.std_logic_arith.all;
    

library work;


package tpu_globals is



constant b_w : integer := 8;
constant mac_n : integer :=32;


--types
 type activ_stream is array (0 to mac_n-1) of Std_logic_vector(b_w-1 downto 0);     
  type output_stream is array (0 to mac_n-1) of Std_logic_vector(23 downto 0);
type weight_mem is array (0 to mac_n-1, 0 to mac_n-1) of Std_logic_vector(b_w-1 downto 0); 
type prev_mac_array is array (0 to mac_n, 0 to mac_n-1) of Std_logic_vector(23 downto 0);
type err_mem is array (0 to mac_n-1, 0 to mac_n-1) of Std_logic; 

-- signal weight_array: weight_mem:=( (x"01", x"02", x"03"),
--                                    (x"04", x"03", x"02"),
--                                    (x"01", x"00", x"02")
-- );


--signal weight_array: weight_mem:=( 
--(x"01", x"02", x"03", x"04", x"03", x"02", x"01", x"02", x"03", x"04", x"03", x"02"),
--(x"01", x"02", x"03", x"04", x"03", x"02", x"01", x"02", x"03", x"04", x"03", x"02"),
--(x"01", x"02", x"03", x"04", x"03", x"02", x"01", x"02", x"03", x"04", x"03", x"02"),
--(x"01", x"02", x"03", x"04", x"03", x"02", x"01", x"02", x"03", x"04", x"03", x"02"),
--(x"01", x"02", x"03", x"04", x"03", x"02", x"01", x"02", x"03", x"04", x"03", x"02"),
--(x"01", x"02", x"03", x"04", x"03", x"02", x"01", x"02", x"03", x"04", x"03", x"02"),
--(x"01", x"02", x"03", x"04", x"03", x"02", x"01", x"02", x"03", x"04", x"03", x"02"),
--(x"01", x"02", x"03", x"04", x"03", x"02", x"01", x"02", x"03", x"04", x"03", x"02"),
--(x"01", x"02", x"03", x"04", x"03", x"02", x"01", x"02", x"03", x"04", x"03", x"02"),
--(x"01", x"02", x"03", x"04", x"03", x"02", x"01", x"02", x"03", x"04", x"03", x"02"),
--(x"01", x"02", x"03", x"04", x"03", x"02", x"01", x"02", x"03", x"04", x"03", x"02"),
--(x"01", x"02", x"03", x"04", x"03", x"02", x"01", x"02", x"03", x"04", x"03", x"02")
--);
end package;
