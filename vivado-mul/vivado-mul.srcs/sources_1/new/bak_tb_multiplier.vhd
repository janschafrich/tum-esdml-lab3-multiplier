LIBRARY IEEE;
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

    signal a, b      : bit_vector(mul_width - 1 downto 0);
    signal s,v       : bit;
    signal y, y_ref  : bit_vector(mul_width*2 - 1 downto 0);


begin

    DUT1 : entity work.multiplier(dataflow)   generic map (N => mul_width) port map (a,b,s,v,y);
    DUT2 : entity work.multiplier(behavioral) generic map (N => mul_width) port map (a,b,s,v,y_ref);

    stimuli : process
        variable ErrorCount_unv : integer := 0;
        variable ErrorCount_snv : integer := 0;
        variable ErrorCount_uv : integer := 0;
        variable ErrorCount_sv : integer := 0;
    begin

        
        
        ---------------------------------------------------------------------------------------------------
        -- non vector edge cases
        ---------------------------------------------------------------------------------------------------
        
        v <= '0';
        
        -- unsigned
        s <= '0';
        
        b <= b"0000_0000";
        a <= b"0000_0000"; 
        wait for 10 ns;
        assert (y = x"0000" AND y_ref = x"0000")
            report "0 * 0  = 0 failed"
            severity error;

        a <= b"0000_0010"; 
        b <= b"0000_0010";
        wait for 10 ns;
        assert (y = x"0004" AND y_ref = x"0004")
            report "2 * 2 = 4 failed"
            severity error;

        -- signed
        s <= '1';

        a <= "10000000";        -- -128
        b <= "00000001";        -- 1
        wait for 10 ns;
        assert (y = b"1111_1111_1000_0000" AND y_ref = b"1111_1111_1000_0000")
            report "-128 * 1 = -128 failed"
            severity error;

        a <= "00000001";        -- 1
        b <= "10000000";        -- -128
        wait for 10 ns;
        assert (y = b"1111_1111_1000_0000" AND y_ref = b"1111_1111_1000_0000")
            report "1 * -128 = -128 failed"
            severity error;

        a <= "10000000";        -- -128
        b <= "10000000";        -- -128
        wait for 10 ns;
        assert (y = b"0100_0000_0000_0000" AND y_ref = b"0100_0000_0000_0000")
            report "-128 * -128 = 16384 failed"
            severity error;


        ---------------------------------------------------------------------------------------------------
        -- vector edge cases
        ---------------------------------------------------------------------------------------------------
        
        v <= '1';
        s <= '0';
        
        a <= b"1000_1000";        -- 8   8 
        b <= b"1000_1000";        -- 8   8
        wait for 10 ns;
        assert (y = b"0100_0000_0100_0000" AND y_ref = b"0100_0000_0100_0000")
        report "-8 :: -8  * -8 :: -8  = 64 :: 64 failed"
        severity error;
        
        
        s <= '1';
        
        a <= b"1000_1000";        -- -8   -8 
        b <= b"1000_1000";        -- -8   -8
        wait for 10 ns;
        assert (y = b"0100_0000_0100_0000" AND y_ref = b"0100_0000_0100_0000")
        report "-8 :: -8  * -8 :: -8  = 64 :: 64 failed"
        severity error;


        ---------------------------------------------------------------------------------------------------
        -- test all cases
        ---------------------------------------------------------------------------------------------------
        
        s <= '0';
        v <= '0';   

        if s = '0' and v = '0' then
            for ai in 0 to 2**8-1 loop
                a <= bit_vector( to_unsigned(ai, mul_width) );
                for bi in 0 to 2**8-1 loop
                    b <= bit_vector( to_unsigned(bi, mul_width) );
                    wait for 1 ns;
                    if y /= y_ref then ErrorCount_unv := ErrorCount_unv + 1; end if;
                end loop;
            end loop;


        s <= '1';
        v <= '0';
  
        elsif s = '1' and v = '0' then
            for ai in 0 to 2**8-1 loop
                a <= bit_vector( to_signed(ai, mul_width) );
                for bi in 0 to 2**8-1 loop
                    b <= bit_vector( to_signed(bi, mul_width) );
                    wait for 1 ns;
                    if y /= y_ref then ErrorCount_snv := ErrorCount_snv + 1; end if;
                end loop;
            end loop;


        s <= '0';
        v <= '1';

        elsif s = '0' and v = '1' then
            for ai in 0 to 2**3-1 loop
                a <= bit_vector( to_unsigned(ai, mul_width/2) ) & bit_vector( to_unsigned(ai, mul_width/2) );
                for bi in 0 to 2**3-1 loop
                    b <= bit_vector( to_unsigned(bi, mul_width/2) ) & bit_vector( to_unsigned(bi, mul_width/2) );
                    wait for 1 ns;
                    if y /= y_ref then ErrorCount_uv := ErrorCount_uv + 1; end if;
                end loop;
            end loop;

        s <= '1';
        v <= '1';

        elsif s = '1' and v = '1' then
            for ai in 0 to 2**3-1 loop
                a <= bit_vector( to_signed(ai, mul_width/2) ) & bit_vector( to_signed(ai, mul_width/2) );
                for bi in 0 to 2**3-1 loop
                    b <= bit_vector( to_signed(bi, mul_width/2) ) & bit_vector( to_signed(bi, mul_width/2) );
                    wait for 1 ns;
                    if y /= y_ref then ErrorCount_sv := ErrorCount_sv + 1; end if;
                end loop;
            end loop;
        end if;

        -- End of testbench
        report "Test unsigned   non vector  completed with " & integer'image(ErrorCount_unv) & " errors";
        report "Test signed     non vector  completed with " & integer'image(ErrorCount_snv) & " errors";
        report "Test unsigned   vector      completed with " & integer'image(ErrorCount_uv) & " errors";
        report "Test signed     vector      completed with " & integer'image(ErrorCount_sv) & " errors";
        wait;
    end process;
end Behavioral; 