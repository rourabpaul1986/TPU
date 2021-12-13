----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.12.2021 10:17:51
-- Design Name: 
-- Module Name: tecu_top - tecu_top_arch
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library work;
	use work.tecu_package.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tecu_top_arraytype is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           prev_active : in STD_LOGIC_VECTOR (7 downto 0);
           cur_active : in STD_LOGIC_VECTOR (7 downto 0);
           err_flag : in STD_LOGIC_VECTOR (mac_row_size-1 downto 0);
           rte :  out STD_LOGIC;
           pattern_match : out STD_LOGIC_vector(b_w-1 downto 0)
           );
end tecu_top_arraytype;

architecture tecu_top_arch of tecu_top_arraytype is

     signal similarity : memory_type_16xb_w_size;
     signal new_pattern:  STD_LOGIC_VECTOR (7 downto 0);
    -- signal err:  STD_LOGIC:='0';
     signal err, err_flag_temp : STD_LOGIC_VECTOR (mac_row_size-1 downto 0):=(others=>'0');
     signal num_zero_sim, num_zero_new :   memory_type_16x5_size:=((others=> (others=>'0')));
     signal num_zero_sim_prev, num_zero_new_prev :  Std_logic_vector(4 downto 0):=(others=>'0');
     signal bit16sim, bit16new :   memory_type_16xmem_size:=((others=> (others=>'0')));
     signal index,k : integer range 0 to mem_size:=0;
     signal mac_pos_err : integer range 0 to mac_row_size:=0;
     signal saved_pat: pattern_memory_type :=(x"1010", x"A020", x"01B3", x"2402", 
                                              x"E003", x"00FF", x"4100", x"E000",
                                              x"1010", x"A020", x"01B3", x"2402", 
                                              x"E003", x"00FF", x"4100", x"E000"
                                              );
      component num_zeros is
           Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
                  zeros : out  STD_LOGIC_VECTOR (4 downto 0));
       end component;


begin

new_pattern<=prev_active xor cur_active;
-----------------------------------------------------------------------------
pattern_search: for I in 0 to mem_size-1 generate
 similarity(I) <= saved_pat(I)(b_w-1 downto 0) or new_pattern;
-- num_zero_gen: for J in 0 to b_w-1 generate
--  num_zero_new(I)<=num_zero_new_prev+1 when similarity(I)(J)='0';  
--  num_zero_sim(I)<=num_zero_sim_prev+1 when saved_pat(I)(b_w-1 downto 0)(J)='0'; 
--  num_zero_new_prev<=num_zero_new(I);
-- end generate num_zero_gen;
 bit16new(I)<="00000000" & similarity(I);
 bit16sim(I)<="00000000" & saved_pat(I)(b_w-1 downto 0);
 zero_sim0       : num_zeros port map (A=>bit16new(I), zeros=>num_zero_new(I));
 zero_saved_pat0 : num_zeros port map (A=>bit16sim(I), zeros=>num_zero_sim(I));
 -------------------------------------1----------------------------------------
 end generate pattern_search;
 process(clk,index)
 begin
 if rising_edge(clk) then
   if(index/=mem_size-1) then
     index<=index+1;
         if (num_zero_sim(index) < num_zero_new(index)) then
          pattern_match <=saved_pat(index)(b_w+b_w-1 downto b_w);
          rte<='1';
         else
          rte<='0';
         end if;
    else
        index<=0;    
   end if;
 end if;
 end process;
--------------------------error detection process-----------------
 err_flag_temp(0)<=err_flag(0);
 error_detection: for J in 1 to mac_row_size-1 generate
   err(J)<=err_flag_temp(J-1) or err_flag(J); 
 end generate error_detection;
 ------------------------------------------------------------ 
 mac_pos_err<=finding_first_one(err_flag);
 process(clk,err)
  begin
   if rising_edge(clk) then
    if(err(mac_row_size-1)='1') then
     saved_pat(k) <= (prev_active xor cur_active) & std_logic_vector(to_unsigned(mac_pos_err, 8));
    end if;
   end if;
   end process;
end;