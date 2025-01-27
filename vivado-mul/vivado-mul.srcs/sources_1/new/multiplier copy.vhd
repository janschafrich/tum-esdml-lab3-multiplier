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

entity multiplier_new is
    generic (   N : natural := 8
    );
    port (
        a, b : in  bit_vector(N - 1 downto 0);  
        s, v : in  bit;                      
        y    : out bit_vector(2*N - 1 downto 0)
    );
end multiplier_new;


architecture dataflow of multiplier_new is

    component adder is
        generic (N : integer);
        port (
            a, b    : in  bit_vector(N-1 downto 0);
            y       : out bit_vector(N-1 downto 0);
            co     : out bit

        );
    end component;

    -- constant EXTENSION_WIDTH    : integer := 2*N - N;

    type pproduct_t             is array (0 to N-1) of bit_vector(2*N-1 downto 0);    -- N-1 parital products extended to 2*N bits
    type product_extension_t    is array (0 to N - 1) of bit_vector (N-1 downto 0);
    type pp_shifted_t           is array (0 to N-1) of bit_vector (2*N downto 0);
    
    type psum_t     is array (0 downto N - 2) of bit_vector(2*N downto 0); -- N-2 partial sums including overflow bit
    
    signal pp_stage_out : pproduct_t;
    signal prod_extensions : product_extension_t;
    signal shifted_pps :  pp_shifted_t;
    signal adder_stage_out     : psum_t;


begin
    -- Compute partial products
    pp_array_gen: for i in 0 to N-1 generate
        pp_extended : for j in 0 to 2*N-1 generate
                pp_stage_out(i)(j) <=   b(i) AND a(j) when j < N else -- multpi for N-1 : 0
                                        pp_stage_out(i)(N - 1) when j >= N and s = '1' else          -- connect extension signal from 15 to N
                                        (others => '0' ) when j >= N and s = '0' else
                                        '0';
        end generate pp_extended;
    end generate pp_array_gen;

    -- -- extend with sign or zero
    -- prod_extensions_gen: for i in 0 to N-1 generate
    --     prod_extensions(i) <= (others => pp_stage_out(i)(N - 1)) when s = '1' else -- arithmetic sign extension
    --                           (others => '0');                                          -- logical (zero) extension
    -- end generate prod_extensions_gen;

    -- shift left logical 1
    shift_gen : for i in 0 to N-1 generate
        shifted_pps(2*N downto i) <= pp_stage_out(2*N - i downto 0);
    end generate shift_gen;

    -- add shifted partial products

    adder_inst_0 : entity work.adder
        generic map (
            N => 2*N
        )
        port map (
            a => shifted_pps(0),
            b => shifted_pps(1),
            y => adder_stage_out(0)(N*2 - 1 downto 0),
            co => adder_stage_out(0)(N*2)

        );

    
    adder_gen : for i in 0 to N-2 generate 
        
        adder_inst : entity work.adder
            generic map (
                N => 2*N
            )
            port map (
                a => shifted_pps(i+2),
                b => adder_stage_out(i),
                y => adder_stage_out(i+1)(N*2 - 1 downto 0),
                co => adder_stage_out(0)(N*2)
            );
    end generate adder_gen;

    y(0)        <= pp_stage_out(0)(0);

    result_gen : for i in 1 to N - 1 generate
        y(i) <= adder_stage_out(i-1)(0);
    end generate result_gen;

    y(2*N - 1 downto N) <= adder_stage_out(N - 2)(N downto 1); 






    -- generate the adders to sum partial result
    -- adder_gen : for i in 1 to N - 1 generate
    --     signal ppg_in, b_in, adder_out :    bit_vector((2*N - i) - 1 downto 0) := (others => '0') ;
    --     signal co                           : bit_vector(0 downto 0);
    -- begin
    --     -- cut the unneeded sign bits
    --     ppg_in <= pp_stage_out(i)((2*N - i) - 1 downto 0);
        
    --     first_adder_input : if i = 1 generate
    --         -- first adder use partial products 0 and 1
    --         b_in                                 <= pp_stage_out(0)(2*N - 1 downto 1);
    --         adder_stage_out(2*N - i downto 0)    <= co & adder_out;                         -- cat carry with sum
    --     end generate first_adder_input;
        
    --     other_adder_inputs : if i > 1 generate
    --         -- others: use partial product and output of previous adder stage
    --         b_in                                    <= adder_stage_out(i - 2)(2*N - i downto 1);  -- mv window sll,  bit0 is used as output
    --         adder_stage_out(i - 1)(2*N - i downto 0)<= co & adder_out;         -- cat carry with sum
    --     end generate other_adder_inputs;       


    --     adder_inst : entity work.adder
    --         generic map (
    --             N => 2*N - i
    --         )
    --         port map (
    --             a => ppg_in,
    --             b => b_in,
    --             y => adder_out,
    --             co => co
    --         );

    -- end generate adder_gen;

    -- output results

end dataflow;

  

-- Behavioral architecture
architecture behavioral of multiplier_new is
begin
    y <=    bit_vector(unsigned(a)  * unsigned(b) ) when s = '0' and v = '0'                      else
            bit_vector(  signed(a)  *   signed(b))  when s = '1' and v = '0'                            else
            bit_vector(unsigned( a(7 downto 4)) * unsigned( b(7 downto 4)) ) &
            bit_vector(unsigned( a(3 downto 0)) * unsigned( b(3 downto 0)) ) when s = '0' and v = '1'   else
            bit_vector(  signed( a(7 downto 4)) *   signed( b(7 downto 4)) ) &
            bit_vector(  signed( a(3 downto 0)) *   signed( b(3 downto 0)) );

end behavioral;

