----------------------------------------------------------------------------------
-- Company: SOA
-- Engineer: Dr. Rourab Paul
-- 
-- Create Date: 09.07.2020 11:44:16
-- Design Name: 
-- Module Name: sys_array - sys_array_arch
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
	use work.tpu_globals.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sys_array is
  generic (b_w : integer:=8;
          m_h : integer:=2);
    Port ( clk : in STD_LOGIC;
           --del_clk : in STD_LOGIC;
           activ : in activ_stream;
           start : in STD_LOGIC;  
           out_reg :   out output_stream;   
          -- out_reg :   out Std_logic_vector(23 downto 0);       
           error_out : out STD_LOGIC;
           done : out STD_LOGIC
           );
end sys_array;

architecture sys_array_arch of sys_array is
  component mac_seq_razor
  generic (b_w : integer:=8;
           m_h : integer:=2);
    port (activ: in Std_logic_vector(7 downto 0);
        weight: in Std_logic_vector(7 downto 0);
        start: in Std_logic;
        clk, del_clk: in Std_logic;
        prev_mac :   in Std_logic_vector(23 downto 0);
        prev_activ : out Std_logic_vector(7 downto 0); 
        mac_out :   out Std_logic_vector(23 downto 0);
        error_out :   out Std_logic       
        );
end component;

  signal prev_mac : prev_mac_array;
  type prev_activ_array is array (0 to mac_n-1, 0 to mac_n) of Std_logic_vector(7 downto 0);
  signal prev_activ : prev_activ_array;
  signal counter : integer range 0 to 255 := 0;
  signal temp_weight : weight_mem;
  signal error, error_temp : err_mem;
  --signal error_temp: Std_logic_vector(mac_n*mac_n-1 downto 0);
-----4X4 weigh matrix
--   signal weight_array: weight_mem:=( (x"11", x"A2", x"B3", x"B3"),
--                                    (x"24", x"E3", x"FF", x"FF"),
--                                    (x"24", x"E3", x"FF", x"FF"),
--                                    (x"41", x"E0", x"AE", x"AE")
-- );
  
  --16x 16 weight matrix
     signal weight_array: weight_mem:=( (x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF",x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE",x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF",x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE",x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                        (x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                        (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                        (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF",x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                        (x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE",x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                        (x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                        (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                        (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF",x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                        (x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE",x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       
                                       (x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF",x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE",x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF",x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE",x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF",x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE",x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF", x"24", x"E3", x"FF", x"FF",x"24", x"E3", x"FF", x"FF", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3"),
                                       (x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE",x"41", x"E0", x"AE", x"AE", x"41", x"E0", x"AE", x"AE", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3", x"11", x"A2", x"B3", x"B3",x"11", x"A2", x"B3", x"B3")
);

begin
temp_weight<=weight_array;
prev_activ_init: for I in 0 to mac_n-1 generate
  prev_activ(I,0)<=activ(I);
end generate prev_activ_init;

prev_mac_init: for I in 0 to mac_n-1 generate
  prev_mac(0,I)<=x"000000";
end generate prev_mac_init;
-- prev_mac(0,0)<=x"000000";
  GEN_REG_I: for X in 0 to mac_n-1 generate
    GEN_REG_J: for Y in 0 to mac_n-1 generate
  uut: mac_seq_razor 
 generic map (b_w   => 8,
               m_h   =>2)
  port map (  
          -- activ => activ(Y),
           activ => prev_activ(Y,X),
           weight  => weight_array(Y,X),
          start=>start,
          clk  => clk, 
          del_clk => clk,
          prev_mac => prev_mac(Y,X),
          prev_activ =>  prev_activ(Y,X+1),  
          mac_out => prev_mac(Y+1,X),
          error_out => error(Y,X)
          --prev_active =>  prev_active         
          );
   end generate GEN_REG_J;
 end generate GEN_REG_I;   
   
   
   process(clk)
   begin
   if start='1' then
     if rising_edge(clk) then
      if counter=mac_n-1 then
        done<='1';
       else
         done<='0';
        counter<=counter+1;
       end if;
     end if;
   end if;
   end process;
   
  output_loop: for I in 0 to mac_n-1 generate
     out_reg(I)<=prev_mac(mac_n, I);
   end generate output_loop;
   
 --err_flag_temp(0)<=error(0,0);
  error_detectioni: for I in 1 to mac_n-1 generate
   error_detectionj: for J in 1 to mac_n-1 generate
     error_temp(I,J)<=error(I-1,J-1) xor error(I,J); 
   end generate error_detectionj;
   end generate error_detectioni;
   --out_reg<=prev_mac(3,2) xor prev_mac(3,1) xor prev_mac(3,0);
   error_out<=error_temp(mac_n-1, mac_n-1);
end sys_array_arch;
