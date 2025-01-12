LIBRARY IEEE;
USE ieee.numeric_bit.all;

library UNISIM;
use UNISIM.VComponents.all;

entity tb_multiplier is end tb_multiplier;

architecture Behavioral of tb_multiplier is

    COMPONENT multiplier is
        generic (N : integer);
        port (  a,b : in bit_vector(N -1 downto 0);
                s,v : in bit;
                y : out bit_vector(2*N downto 0));
    end COMPONENT multiplier;

    constant mul_width : integer := 8;

    signal a, b     : bit_vector(mul_width - 1 downto 0);
    signal s,v      : bit;
    signal y1, y2   : bit_vector(mul_width*2 downto 0);


begin

    DUT1 : entity work.multiplier(dataflow)   generic map (N => mul_width) port map (a,b,s,v,y1);
    DUT2 : entity work.multiplier(behavioral) generic map (N => mul_width) port map (a,b,s,v,y2);


    stimuli : process
    begin
        s <= '1'; v <= '0';

        if s = '0' and v = '0' then
            for ai in 0 to 2**8-1 loop
                a <= bit_vector( to_unsigned(ai, mul_width) );
                for bi in 0 to 2**8-1 loop
                    b <= bit_vector( to_unsigned(bi, mul_width) );
                    wait for 1 ns;
                    assert y1 = y2 report "Mismatch between dataflow and behavioral results" SEVERITY ERROR;
                end loop;
            end loop;
            
        elsif s = '1' and v = '0' then
            for ai in -2**7 to 2**7-1 loop
                a <= bit_vector( to_signed(ai, mul_width) );
                for bi in -2**7 to 2**7-1 loop
                    b <= bit_vector( to_signed(bi, mul_width) );
                    wait for 1 ns;
                    assert y1 = y2 report "Mismatch between dataflow and behavioral results" SEVERITY ERROR;
                end loop;
            end loop;
        end if;

        wait;
    end process;
end Behavioral; 