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
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_BIT.ALL;

entity multiplier is
    generic (   N : natural := 8
    );
    port (
        a, b : in  bit_vector(N - 1 downto 0);  
        s, v : in  bit;                      
        y    : out bit_vector(2*N - 1 downto 0)
    );
end multiplier;


architecture dataflow_new of multiplier is

    component adder is
        generic (N : integer);
        port (
            a, b    : in  bit_vector(N-1 downto 0);
            y       : out bit_vector(N-1 downto 0);
            co     : out bit

        );
    end component;

    type pproduct_t is array (0 to 2*N-1) of bit_vector(2*N-1 downto 0);    -- N-1 parital products     
    
    signal a_and_b          : pproduct_t;
    signal pp_stage_out     : pproduct_t;
    signal adder_stage_out  : pproduct_t;
    signal a_ext, b_ext   : bit_vector(N*2-1 downto 0) := (others => '0');


begin
    -- extend the input operands to product width N*2
    a_ext(N-1 downto 0) <= a;
    b_ext(N-1 downto 0) <= b;

    op_extend_gen : for i in N to N*2-1 generate 
        a_ext(i) <= s AND a(N-1);
        b_ext(i) <= s AND b(N-1);
    end generate op_extend_gen;


    -- multiply and sign extend
    products_stages_gen: for i in 0 to N*2-1 generate
        -- multiply 
        mul_gen : for j in 0 to N*2-1 generate
            a_and_b(i)(j) <= a_ext(j) AND b_ext(i);    -- mulitply bit i of b, with every bit j of a
        end generate mul_gen;

        -- shift left logical 1
        skip_first_shift : if i = 0 generate  
            pp_stage_out(0)(2*N - 1 downto 0)  <= a_and_b(0)(N*2-1 downto 0);
        end generate skip_first_shift;
        
        shift_gen : if i > 0 generate
            pp_stage_out(i)(2*N - 1 downto i)  <= a_and_b(i)(N*2-1 - i downto 0); -- Perform left shift
            pp_stage_out(i)(i-1 downto 0)      <= (others => '0'); -- Zero-fill the lower bits
        end generate shift_gen;
        
    end generate products_stages_gen;


    -- add shifted partial products
    adder_inst_0 : entity work.adder
        generic map (
            N => 2*N
        )
        port map (
            a => pp_stage_out(0),
            b => pp_stage_out(1),
            y => adder_stage_out(0)(N*2 - 1 downto 0)
        );

    
    adder_gen : for i in 1 to N*2-2 generate 
        adder_inst : entity work.adder
            generic map (
                N => 2*N
            )
            port map (
                a => pp_stage_out(i+1),
                b => adder_stage_out(i-1)(N*2 - 1 downto 0),
                y => adder_stage_out(i)(N*2 - 1 downto 0)
            );
    end generate adder_gen;

    y <= adder_stage_out(2*N-2)(2*N-1 downto 0);

end dataflow_new;




architecture dataflow of multiplier is

    component adder is
        generic (N : integer);
        port (
            a, b    : in  bit_vector(N-1 downto 0);
            y       : out bit_vector(N-1 downto 0);
            co     : out bit

        );
    end component;

    type pproduct_t is array (0 to N-1) of bit_vector(2*N-1 downto 0);    -- N-1 parital products extended to 2*N bits
    type psum_t     is array (0 to N - 2) of bit_vector(2*N downto 0); -- N-2 partial sums including overflow bit

    signal a_and_b          : pproduct_t;
    -- signal pp_stage_out     : pproduct_t;
    signal adder_stage_out  : psum_t;


begin
    -- multiply and sign extend
    products_stages_gen: for i in 0 to N-1 generate
        -- multiply 
        mul_gen : for j in 0 to N-1 generate
            a_and_b(i)(j) <= b(i) AND a(j);
        end generate mul_gen;
        
        -- sign extend
        signextend_gen : for j in N to 2*N-1 generate
            a_and_b(i)(j) <= s AND a(N-1);
        end generate signextend_gen;
    end generate products_stages_gen;



    -- generate the adders to sum partial result
    adder_gen : for i in 1 to N - 1 generate
        signal ppg_in, b_in, adder_out : bit_vector((2*N - i) - 1 downto 0) := (others => '0') ;
        signal co                      : bit;
    begin
        -- cut the unneeded sign bits
        ppg_in <= a_and_b(i)((2*N - i) - 1 downto 0);
        
        first_adder_input : if i = 1 generate
            -- first adder use partial products 0 and 1
            b_in                                    <= a_and_b(0)(2*N - 1 downto 1);
            adder_stage_out(0)((2*N - i) downto 0)       <= co & adder_out;         -- cat carry with sum
        end generate first_adder_input;
        
        other_adder_inputs : if i > 1 generate
            -- others: use partial product and output of previous adder stage
            b_in                                    <= adder_stage_out(i - 2)(2*N - i downto 1);  -- mv window sll, bit0 is used as output
            adder_stage_out(i - 1)((2*N - i) downto 0)<= co & adder_out;         -- cat carry with sum
        end generate other_adder_inputs;       


        adder_inst : entity work.adder
            generic map (
                N => 2*N - i
            )
            port map (
                a => ppg_in,
                b => b_in,
                y => adder_out
                -- co => co
            );

    end generate adder_gen;



    -- output results
    y(0)        <= a_and_b(0)(0);

    result_gen : for i in 1 to N - 1 generate
        y(i) <= adder_stage_out(i-1)(0);
    end generate result_gen;

    y(2*N - 1 downto N) <= adder_stage_out(N - 2)(N downto 1); 

end dataflow;

  

-- Behavioral architecture
architecture behavioral of multiplier is
begin
    y <=    bit_vector(unsigned(a)  * unsigned(b) ) when s = '0' and v = '0'                      else
            bit_vector(  signed(a)  *   signed(b))  when s = '1' and v = '0';
            --                             else
            -- bit_vector(unsigned( a(7 downto 4)) * unsigned( b(7 downto 4)) ) &
            -- bit_vector(unsigned( a(3 downto 0)) * unsigned( b(3 downto 0)) ) when s = '0' and v = '1'   else
            -- bit_vector(  signed( a(7 downto 4)) *   signed( b(7 downto 4)) ) &
            -- bit_vector(  signed( a(3 downto 0)) *   signed( b(3 downto 0)) );

end behavioral;

