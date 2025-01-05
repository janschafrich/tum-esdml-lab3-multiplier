LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity tb_multiplier is end tb_multiplier;

architecture Behavioral of tb_multiplier is

    COMPONENT multiplier is
        generic (N : integer);
        port (  a,b : in std_logic_vector(N -1 downto 0);
                s,v : in std_logic;
                z : out std_logic_vector(2*N -1 downto 0));
    end COMPONENT multiplier;

    constant mul_width : integer := 8;

    signal a, b     : std_logic_vector(mul_width - 1 downto 0);
    signal s,v      : std_logic;
    signal z1, z2   : std_logic_vector(mul_width*2 - 1 downto 0);


begin

    DUT1 : entity work.multiplier(dataflow)   generic map (N => mul_width) port map (a,b,s,v,z1);
    DUT2 : entity work.multiplier(behavioral) generic map (N => mul_width) port map (a,b,s,v,z2);


    stimuli : process
    begin
        s <= '0'; v <= '0';

        for ai in 0 to 2**8-1 loop
            a <= std_logic_vector(to_unsigned(ai, mul_width));
            for bi in 0 to 2**8-1 loop
                b <= std_logic_vector(to_unsigned(bi, mul_width));
                wait for 1 ns;
                assert z1 = z2 report "Mismatch between dataflow and behavioral results" SEVERITY ERROR;
            end loop;
        end loop;
        wait;
    end process;
end Behavioral; 