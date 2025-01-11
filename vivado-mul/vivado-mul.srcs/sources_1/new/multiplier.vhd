-- ----------------------------------------------------------------------------------
-- -- Company: 
-- -- Engineer: Jan-Eric Schäfrich
-- -- 
-- -- Create Date: 01/05/2025 09:51:19 AM
-- -- Design Name: 
-- -- Module Name: multiplier - Behavioral
-- -- Project Name: 
-- -- Target Devices: 
-- -- Tool Versions: 
-- -- Description: 
-- -- 
-- -- Dependencies: 
-- -- 
-- -- Revision:
-- -- Revision 0.01 - File Created
-- -- Additional Comments:
-- -- 
-- ----------------------------------------------------------------------------------


library IEEE;
use IEEE.NUMERIC_BIT.ALL;

entity multiplier is
    generic (N : natural := 8);
    port (
        a, b : in  bit_vector(N-1 downto 0);  
        s, v : in  bit;                      
        y    : out bit_vector(2*N-1 downto 0)
    );
end multiplier;

-- Dataflow architecture
architecture dataflow of multiplier is

    component adder is
        generic (N : integer);
        port (
            a, b : in  bit_vector(N-1 downto 0);
            y    : out bit_vector(N-1 downto 0);
            co   : out bit
        );
    end component;

    type pproduct is array (natural range <>) of bit_vector(N-1 downto 0); 
    signal p : pproduct (N-1 downto 0); -- Partial products
    -- signal c : bit_vector(N-1 downto 0);
    signal a1,a2,a3,a4,a5,a6,a7 : bit_vector(N-1 downto 0);
    signal b1,b2,b3,b4,b5,b6,b7 : bit_vector(N-1 downto 0);
    signal c1,c2,c3,c4,c5,c6,c7 : bit;                          -- carry
    signal s1,s2,s3,s4,s5,s6,s7 : bit_vector(N-1 downto 0);     -- sum

begin
    -- Compute partial products
    partialproducts: for j in N-1 downto 0 generate
        ands: for i in N-1 downto 0 generate
            p(j)(i) <= b(j) and a(i);
        end generate ands;
    end generate partialproducts;

    -- Sum partial products
    y(0)    <= a(0) AND b(0);       -- half adder

    a1      <= '0' & a(N-1 downto 1)    when b(0) = '1' else b"0000_0000";
    b1      <= a                        when b(1) = '1' else b"0000_0000";
    x1:     entity work.adder(dataflow) port map(a1, b1, s1, c1);
    y(1)    <= s1(0);

    a2      <= c1 & s1(N-1 downto 1);
    b2      <= a when b(2) = '1' else b"0000_0000";
    x2:     entity work.adder(dataflow) port map(a2, b2, s2, c2);
    y(2)    <= s2(0);

    a3      <= c2 & s2(N-1 downto 1);
    b3      <= a when b(3) = '1' else b"0000_0000";
    x3:     entity work.adder(dataflow) port map(a3, b3, s3, c3);
    y(3)    <= s3(0);

    a4      <= c3 & s3(N-1 downto 1);
    b4      <= a when b(4) = '1' else b"0000_0000";
    x4:     entity work.adder(dataflow) port map(a4, b4, s4, c4);
    y(4)    <= s4(0);

    a5      <= c4 & s4(N-1 downto 1);
    b5      <= a when b(5) = '1' else b"0000_0000";
    x5:     entity work.adder(dataflow) port map(a5, b5, s5, c5);
    y(5)    <= s5(0);

    a6      <= c5 & s5(N-1 downto 1);
    b6      <= a when b(6) = '1' else b"0000_0000";
    x6:     entity work.adder(dataflow) port map(a6, b6, s6, c6);
    y(6)    <= s6(0);

    a7      <= c6 & s6(N-1 downto 1);
    b7      <= a when b(7) = '1' else b"0000_0000";
    x7:     entity work.adder(dataflow) port map(a7, b7, s7, c7);
    y(14 downto 7)    <= s7;
    y(15)   <= c7;

end dataflow;

-- Behavioral architecture
architecture behavioral of multiplier is
begin
    y <= bit_vector(unsigned(a) * unsigned(b));
end behavioral;

