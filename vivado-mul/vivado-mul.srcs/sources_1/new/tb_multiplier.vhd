LIBRARY IEEE;
use ieee.std_logic_1164.all;
USE ieee.numeric_bit.all;


entity tb_multiplier is end tb_multiplier;

architecture Behavioral of tb_multiplier is

    COMPONENT multiplier is
        generic (N : integer);
        port (  a,b : in bit_vector(N - 1 downto 0);
                s,v : in bit;
                y : out bit_vector(2*N - 1 downto 0));
    end COMPONENT multiplier;

    constant mul_width : integer := 8;

    signal a, b     : bit_vector(mul_width - 1 downto 0);
    signal s,v      : bit;
    signal y_dataflow, y_behav   : bit_vector(mul_width*2 - 1 downto 0);


begin

    DUT1 : entity work.multiplier(dataflow_new)   generic map (N => mul_width) port map (a,b,s,v,y_dataflow);
    DUT2 : entity work.multiplier(behavioral) generic map (N => mul_width) port map (a,b,s,v,y_behav);


    stimuli : process
    begin

        s <= '0'; v <= '0';

        -- N = 4 tests
        -- a <= "0000"; 
        -- b <= "0000";
        -- wait for 10 ns;
        -- assert (y_dataflow = x"0000" AND y_behav = x"0000")
        --     report "0 * 0 failed"
        --     severity error;

        -- a <= "0010"; 
        -- b <= "0010";
        -- wait for 10 ns;
        -- assert (y_dataflow = x"0004" AND y_behav = x"0004")
        --     report "2 * 2 = 4 failed"
        --     severity error;

        -- s <= '1';

        -- a <= "1000";        -- -8
        -- b <= "0111";        -- 7
        -- wait for 10 ns;
        -- assert (y_dataflow = b"1100_1000" AND y_behav = b"1100_1000")
        --     report "-128 * 1 failed"
        --     severity error;

        -- a <= "0111";        -- 7
        -- b <= "1000";        -- -8
        -- wait for 10 ns;
        -- assert (y_dataflow = b"1100_1000" AND y_behav = b"1100_1000")
        --     report "1 * -128 failed"
        --     severity error;

        -- a <= "1000";        -- -8
        -- b <= "1000";        -- -8
        -- wait for 10 ns;
        -- assert (y_dataflow = b"0100_0000" AND y_behav = b"0100_0000")
        --     report "-128 * -128 failed"
        --     severity error;

        -- N = 8 tests
        -- edge cases
        a <= b"0000_0000"; 
        b <= b"0000_0000";
        wait for 10 ns;
        assert (y_dataflow = x"0000" AND y_behav = x"0000")
            report "0 * 0  = 0 failed"
            severity error;

        a <= b"0000_0010"; 
        b <= b"0000_0010";
        wait for 10 ns;
        assert (y_dataflow = x"0004" AND y_behav = x"0004")
            report "2 * 2 = 4 failed"
            severity error;



        s <= '1';

        a <= "10000000";        -- -128
        b <= "00000001";        -- 1
        wait for 10 ns;
        assert (y_dataflow = b"1111_1111_1000_0000" AND y_behav = b"1111_1111_1000_0000")
            report "-128 * 1 = -128 failed"
            severity error;

        a <= "00000001";        -- 1
        b <= "10000000";        -- -128
        wait for 10 ns;
        assert (y_dataflow = b"1111_1111_1000_0000" AND y_behav = b"1111_1111_1000_0000")
            report "1 * -128 = -128 failed"
            severity error;

        a <= "10000000";        -- -128
        b <= "10000000";        -- -128
        wait for 10 ns;
        assert (y_dataflow = b"0100_0000_0000_0000" AND y_behav = b"0100_0000_0000_0000")
            report "-128 * -128 = 16384 failed"
            severity error;


        -- test all cases
        if s = '0' and v = '0' then
            for ai in 0 to 2**8-1 loop
                a <= bit_vector( to_unsigned(ai, mul_width) );
                for bi in 0 to 2**8-1 loop
                    b <= bit_vector( to_unsigned(bi, mul_width) );
                    wait for 1 ns;
                    assert y_dataflow = y_behav report "Mismatch between dataflow and behavioral results" SEVERITY ERROR;
                end loop;
            end loop;
            
        elsif s = '1' and v = '0' then
            for ai in 0 to 2**8-1 loop
                a <= bit_vector( to_signed(ai, mul_width) );
                for bi in 0 to 2**8-1 loop
                    b <= bit_vector( to_signed(bi, mul_width) );
                    wait for 1 ns;
                    assert y_dataflow = y_behav report "Mismatch between dataflow and behavioral results" SEVERITY ERROR;
                end loop;
            end loop;
        end if;

    -- End of testbench
    assert false
    report "Simulation complete, all test cases passed"
    severity failure;

        -- wait;
    end process;
end Behavioral; 