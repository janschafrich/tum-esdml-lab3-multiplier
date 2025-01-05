-- ----------------------------------------------------------------------------------
-- -- Company: 
-- -- Engineer: 
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


-- library IEEE;
-- use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.numeric_std.all;

-- -- Uncomment the following library declaration if using
-- -- arithmetic functions with Signed or Unsigned values
-- --use IEEE.NUMERIC_STD.ALL;

-- -- Uncomment the following library declaration if instantiating
-- -- any Xilinx leaf cells in this code.
-- --library UNISIM;
-- --use UNISIM.VComponents.all;

-- entity multiplier is
--     generic (N : natural := 8);
--     port (
--         a,b : in bit_vector (N-1 downto 0);             -- can either be 0 or 1, no X, U, Z, L, H
--         s,v : in bit;
--         z : out bit_vector (2*N-1 downto 0);
--     );
-- end multiplier;


-- architecture dataflow of multiplier is

--     component adder is
--     generic (adder_width : integer);
--     Port(
--         a, b    : in bit_vector(adder_width-1 downto 0);
--         z       : out bit_vector(adder_width-1 downto 0);
--         co      : out bit);
--     end component adder;

--     type pproduct8 is array (natural range <>) of bit_vector (N-1 downto 0); -- bits of a partial product
--     signal p : pproduct8 (N-1 downto 0);              -- partial products
--     signal c : bit;
--     signal accumulator, p_padded : bit_vector(2*N-1 downto 0);

-- begin

--     -- compute partial products
--     partialproducts: for j in 7 downto 0 generate
--         ands: for i in 7 downto 0 generate
--             p(j)(i)    <= b(j) and a(i);
--         end generate ands;
--     end generate partialproducts;

--     -- sum partial products
--     gen_adders : for i in 0 to N-1 generate
--         p_padded <= b"0000_0000" & p(i)(N-1 downto 0);

--         adder_inst : adder 
--         generic map (adder_width => 2*N)
--         port map (
--             a => p_padded, b => accumulator , z => accumulator ,co => c
--         );
--     end generate gen_adders;

--     z <= accumulator;


-- end dataflow;

-- architecture behavioral of multiplier is

-- begin

--     z <= std_logic_vector(signed(a) * signed(b));

-- end behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier is
    generic (N : natural := 8);
    port (
        a, b : in std_logic_vector(N-1 downto 0);  -- Use std_logic_vector for inputs
        s, v : in std_logic;                      -- Adjust type for single-bit signals
        z    : out std_logic_vector(2*N-1 downto 0) -- Use std_logic_vector for output
    );
end multiplier;

-- Dataflow architecture
architecture dataflow of multiplier is

    component adder is
        generic (N : integer);
        port (
            a, b : in std_logic_vector(N-1 downto 0);
            z    : out std_logic_vector(N-1 downto 0);
            co   : out std_logic
        );
    end component;

    type pproduct8 is array (natural range <>) of std_logic_vector(N-1 downto 0); 
    signal p : pproduct8 (N-1 downto 0); -- Partial products
    signal c : std_logic;
    signal accumulator, p_padded : std_logic_vector(2*N-1 downto 0);

begin
    -- Compute partial products
    partialproducts: for j in 7 downto 0 generate
        ands: for i in 7 downto 0 generate
            p(j)(i) <= b(j) and a(i);
        end generate ands;
    end generate partialproducts;

    -- Sum partial products
    gen_adders: for i in 0 to N-1 generate
        p_padded <= b"0000_0000" & p(i); -- Extend partial product with zeros
        adder_inst: adder
            generic map (N => 2*N)
            port map (
                a => p_padded,
                b => accumulator,
                z => accumulator,
                co => c
            );
    end generate gen_adders;

    z <= accumulator;

end dataflow;

-- Behavioral architecture
architecture behavioral of multiplier is
begin
    z <= std_logic_vector(signed(a) * signed(b));
end behavioral;

