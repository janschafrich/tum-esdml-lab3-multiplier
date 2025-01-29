----------------------------------------------------------------------------------
-- Company:
-- Engineer:   Jan-Eric Schäfrich, Mathis Salmen, Mohamd
--
-- Create Date: 07/10/2023 04:04:01 PM
-- Design Name:
-- Module Name: multiplier - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_BIT.ALL;


--- Add custom modules (adders,...) here
--- ENTER STUDENT CODE BELOW ---
-----------------------------------------------------------------
-- adder definition
-----------------------------------------------------------------

entity adder_def is
    generic(N : integer := 8);
    Port (
        a, b : in bit_vector (N-1 downto 0);
        y    : out bit_vector (N-1 downto 0);
        co   : out bit
     );
end adder_def;

-- ripple carry adder
architecture dataflow of adder_def is
    signal a_and_b, a_xor_b, abc, c: bit_vector(N-1 downto 0);
begin
    g1: for i in 0 to N-1 generate
        a_and_b(i) <= a(i) AND b(i);
        a_xor_b(i) <= a(i) XOR b(i);
        
        g2: if i = 0 generate -- half adder
        y(i)    <= a_xor_b(i);
        c(i)    <= a_and_b(i);
        end generate g2;
        
        g3: if i /= 0 generate -- full adder
        abc(i)<= a_xor_b(i) AND c(i-1);
        c(i)  <= a_and_b(i) OR abc(i);
        y(i)  <= a_xor_b(i) XOR c(i-1);
        end generate g3;
    end generate g1;

    co <= c(N-1);

end dataflow;




-----------------------------------------------------------------
-- multiplier definition
-----------------------------------------------------------------
entity multiplier_def is
    generic (   N : natural := 8
    );
    port (
        a, b : in  bit_vector(N - 1 downto 0);  
        s    : in  bit;                      
        y    : out bit_vector(2*N - 1 downto 0)
    );
end multiplier_def;

architecture dataflow of multiplier_def is

    component adder_def is
        generic (N : natural);
        port (
            a, b    : in  bit_vector(N-1 downto 0);
            y       : out bit_vector(N-1 downto 0);
            co     : out bit
        );
    end component;

    type pproduct_t is array (0 to 2*N-1) of bit_vector(2*N-1 downto 0);
    
    signal a_and_b          : pproduct_t;
    signal pp_stage_out     : pproduct_t;
    signal adder_stage_out  : pproduct_t;
    signal a_ext, b_ext     : bit_vector(N*2-1 downto 0) := (others => '0');

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
        shift_gen : if i > 0 generate
        pp_stage_out(i)(2*N - 1 downto i)  <= a_and_b(i)(N*2-1 - i downto 0); -- Perform left shift
        pp_stage_out(i)(i-1 downto 0)      <= (others => '0'); -- Zero-fill the lower bits
        end generate shift_gen;
        
    end generate products_stages_gen;
        
    -- first stage does not need to be shifted
    pp_stage_out(0)(2*N - 1 downto 0)  <= a_and_b(0)(N*2-1 downto 0);

    -- add shifted partial products
    adder_inst_0 : entity work.adder_def
        generic map (
            N => 2*N
        )
        port map (
            a => pp_stage_out(0),
            b => pp_stage_out(1),
            y => adder_stage_out(0)(N*2 - 1 downto 0)
        );

    adder_gen : for i in 1 to N*2-2 generate 
        adder_inst : entity work.adder_def
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

end dataflow;
--- ENTER STUDENT CODE ABOVE ---





-----------------------------------------------------------------
-- multiplier instantiation
-----------------------------------------------------------------
library IEEE;
use IEEE.NUMERIC_BIT.ALL;

entity multiplier is
    generic ( N : natural := 8);
    Port ( A : in BIT_VECTOR (7 downto 0);
           B : in BIT_VECTOR (7 downto 0);
           S : in BIT;
           V : in BIT;
           Y : out BIT_VECTOR (15 downto 0));
end multiplier;

architecture dataflow of multiplier is

   component multiplier_def is
      generic (N : natural);
      port (
          a, b    : in bit_vector(N-1 downto 0);
          s       : in bit;
          y       : out bit_vector(N*2-1 downto 0)
      );
   end component;
-- SIGNALS
--- ENTER STUDENT CODE BELOW ---

   signal a_i, b_i             : bit_vector(N-1 downto 0);
   signal res_lower, res_upper : bit_vector(N-1 downto 0);
   signal res_scalar           : bit_vector(N*2-1 downto 0);

--- ENTER STUDENT CODE ABOVE ---

begin

--- ENTER STUDENT CODE BELOW ---

   a_i <= a;
   b_i <= b;

   mul_upper : entity work.multiplier_def 
      generic map (
            N => N/2
      )
      port map (
            a => a_i(N-1 downto N/2),
            b => b_i(N-1 downto N/2),
            s => s,
            y => res_upper
      );
            
   mul_lower : entity work.multiplier_def 
      generic map (
            N => N/2
      )
      port map (
            a => a_i(N/2-1 downto 0),
            b => b_i(N/2-1 downto 0),
            s => s,
            y => res_lower
      );

   mul_full : entity work.multiplier_def 
      generic map (
            N => N
      )
      port map (
            a => a_i,
            b => b_i,
            s => s,
            y => res_scalar
      );
                  
   y   <= res_upper & res_lower when v = '1' else res_scalar;

--- ENTER STUDENT CODE ABOVE ---

end dataflow;

-- Behavioral architecture of the array multiplier, can be used as reference during verification --
architecture behavioral of multiplier is

begin

Y <= BIT_VECTOR( unsigned(A) * unsigned(B) )
        when s ='0' AND v = '0' else
     BIT_VECTOR( signed(A) * signed(B) )
        when s ='1' AND v = '0' else
     BIT_VECTOR( unsigned(A(7 downto 4)) * unsigned(B(7 downto 4)) ) &
     BIT_VECTOR( unsigned(A(3 downto 0)) * unsigned(B(3 downto 0)) )
        when s ='0' AND v = '1' else
     BIT_VECTOR( signed(A(7 downto 4)) * signed(B(7 downto 4)) ) &
     BIT_VECTOR( signed(A(3 downto 0)) * signed(B(3 downto 0)) );

end behavioral;
