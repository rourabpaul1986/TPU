----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dr. Rourab Paul
-- 
-- Create Date: 20.07.2020 12:16:44
-- Design Name: 
-- Module Name: mac_seqrazor - mac_seqrazor_arch
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mac_seq_razor is
  generic (b_w : integer:=8;
           m_h : integer:=2);
    Port ( activ : in STD_LOGIC_VECTOR (7 downto 0);
           weight : in STD_LOGIC_VECTOR (7 downto 0);
           prev_mac : in STD_LOGIC_VECTOR (23 downto 0);
           clk : in STD_LOGIC;
           del_clk : in STD_LOGIC;
           start : in STD_LOGIC;
           prev_activ : out STD_LOGIC_VECTOR (7 downto 0);
           mac_out : out STD_LOGIC_VECTOR (23 downto 0);
           error_out : out STD_LOGIC);
end mac_seq_razor;

architecture mac_seq_razor_arch of mac_seq_razor is
signal  sig_mult : STD_LOGIC_VECTOR (15 downto 0);
 signal  sig_mac_out, del_sig_mac_out  : STD_LOGIC_VECTOR (23 downto 0);
 signal A_int: integer;
 signal B_int: integer;
 signal RES_int: integer;
 signal  RES :  STD_LOGIC_VECTOR (15 downto 0);
begin
	A_int <= to_integer(unsigned(activ));
    B_int <= to_integer(unsigned(weight));
clk_proc: process(clk)
begin
if start='1' then
if rising_edge(clk) then
RES_int <=  to_integer(unsigned(activ)) * to_integer(unsigned(weight));
RES <= std_logic_vector(to_unsigned(to_integer(unsigned(activ)) * to_integer(unsigned(weight)) , RES'length) );
sig_mac_out  <= std_logic_vector(to_unsigned(to_integer(unsigned(activ)) * to_integer(unsigned(weight))+ to_integer(unsigned(prev_mac)), sig_mac_out'length) );
prev_activ<=activ;
end if;
end if;
end process clk_proc;

delclk_proc: process(del_clk)
begin
if rising_edge(del_clk) then
del_sig_mac_out  <= std_logic_vector(to_unsigned(to_integer(unsigned(activ)) * to_integer(unsigned(weight))+ to_integer(unsigned(prev_mac)), sig_mac_out'length) );
end if;
end process delclk_proc;

err_proc: process(clk)
begin
if rising_edge(del_clk) then
if (del_sig_mac_out/=sig_mac_out) then
error_out<='1';
else
error_out<='0';
end if;
end if;
end process err_proc;
mac_out<=sig_mac_out;
end mac_seq_razor_arch;
