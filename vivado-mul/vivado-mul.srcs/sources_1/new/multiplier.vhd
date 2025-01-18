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
    generic (   IN_WIDTH : natural := 8;
                OUT_WIDTH : natural := 16
    );
    port (
        a, b : in  bit_vector(IN_WIDTH - 1 downto 0);  
        s, v : in  bit;                      
        y    : out bit_vector(2*IN_WIDTH - 1 downto 0)
    );
end multiplier;


architecture dataflow of multiplier is

    component adder is
        generic (IN_WIDTH : integer);
        port (
            a, b    : in  bit_vector(IN_WIDTH-1 downto 0);
            y       : out bit_vector(IN_WIDTH-1 downto 0);
            co     : out bit

        );
    end component;

    constant EXTENSION_WIDTH    : integer := OUT_WIDTH - IN_WIDTH;

    type pproduct_t is array (0 to IN_WIDTH - 1) of bit_vector(IN_WIDTH*2-1 downto 0); 
    type product_extension_t is array (0 to IN_WIDTH - 1) of bit_vector (EXTENSION_WIDTH downto 0);
    
    signal pproducts : pproduct_t;
    signal prod_extensions : product_extension_t;


begin
    -- Compute partial products
    pp_array_gen: for i in 0 to IN_WIDTH-1 generate
        pp_extended : for j in 0 to OUT_WIDTH-1 generate
                pproducts(i)(j) <= b(i) AND a(j) when j < IN_WIDTH else prod_extensions(i)(j-EXTENSION_WIDTH);
        end generate pp_extended;
    end generate pp_array_gen;

    -- extend with sign or zero
    prod_extensions_gen: for i in 0 to IN_WIDTH-1 generate
        prod_extensions(i) <= (others => pproducts(i)(IN_WIDTH - 1)) when s = '1' else -- arithmetic sign extension
                              (others => '0');                                          -- logical (zero) extension
    end generate prod_extensions_gen;

    -- add extended partial products
    adder_gen : for i in 1 to IN_WIDTH - 1 generate
        signal extpp_in, acc_in, adder_out  : bit_vector(2*IN_WIDTH - 1 downto 0) := (others => '0');
        signal co                           : bit;
    begin
        -- logical shift left by row number j bits 

        extpp_in <= ( pproducts(i)(OUT_WIDTH - 1 downto i)  &  (i - 1 downto 0 => '0') ) when i < OUT_WIDTH else (others => '0');

        adder_inst : entity work.adder
            generic map (
                N => OUT_WIDTH
            )
            port map (
                a => extpp_in,
                b => adder_out,
                y => adder_out
            );

    end generate adder_gen;

end dataflow;

  




-- Behavioral architecture
architecture behavioral of multiplier is
begin
    y <=    bit_vector(unsigned(a)  * unsigned(b) ) when s = '0' and v = '0'                      else
            bit_vector(  signed(a)  *   signed(b))  when s = '1' and v = '0'                            else
            bit_vector(unsigned( a(7 downto 4)) * unsigned( b(7 downto 4)) ) &
            bit_vector(unsigned( a(3 downto 0)) * unsigned( b(3 downto 0)) ) when s = '0' and v = '1'   else
            bit_vector(  signed( a(7 downto 4)) *   signed( b(7 downto 4)) ) &
            bit_vector(  signed( a(3 downto 0)) *   signed( b(3 downto 0)) );

end behavioral;

