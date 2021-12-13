library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity halfadder is
    port (a : in std_logic;
            b : in std_logic;
           sum : out std_logic;
           carry : out std_logic
         );
end halfadder;

architecture behavior of halfadder is

begin

sum <= a xor b;
carry <= (a and b);

end;