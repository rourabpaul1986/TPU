library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity num_zeros is
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
           zeros : out  STD_LOGIC_VECTOR (4 downto 0));
end num_zeros;

architecture Behavioral of num_zeros is

component fulladder is
    port (a : in std_logic;
            b : in std_logic;
           cin : in std_logic;
           sum : out std_logic;
           carry : out std_logic
         );
end component;

component halfadder is
    port (a : in std_logic;
            b : in std_logic;
           sum : out std_logic;
           carry : out std_logic
         );
end component;

signal S,C : std_logic_vector(17 downto 0);

begin

fa0 : fulladder port map(A(0),A(1),A(2),S(0),C(0));
fa1 : fulladder port map(A(3),A(4),A(5),S(1),C(1));
fa2 : fulladder port map(A(6),A(7),A(8),S(2),C(2));
fa3 : fulladder port map(A(9),A(10),A(11),S(3),C(3));
fa4 : fulladder port map(A(12),A(13),A(14),S(4),C(4));

fa5 : fulladder port map(S(0),S(1),S(2),S(5),C(5));
fa6 : fulladder port map(S(3),S(4),A(15),S(6),C(6));
fa7 : fulladder port map(C(0),C(1),C(2),S(7),C(7));
ha8 : halfadder port map(C(3),C(4),S(8),C(8));

ha9 : halfadder port map(S(5),S(6),S(9),C(9));
ha10 : halfadder port map(S(7),S(8),S(10),C(10));
ha11 : halfadder port map(C(5),C(6),S(11),C(11));
ha12 : halfadder port map(C(7),C(8),S(12),C(12));

fa13 : fulladder port map(S(10),S(11),C(9),S(13),C(13));
fa14 : fulladder port map(S(12),C(10),C(11),S(14),C(14));

ha15 : halfadder port map(S(14),C(13),S(15),C(15));
ha16 : halfadder port map(C(12),C(14),S(16),C(16));

ha17 : halfadder port map(S(16),C(15),S(17),C(17));

--ones <= C(17) & S(17) & S(15) & S(13) & S(9); --final output assignment.
zeros<= C(17) & S(17) & S(15) & S(13) & S(9);
end Behavioral;