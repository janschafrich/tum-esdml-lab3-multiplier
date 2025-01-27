----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/05/2025 11:10:16 AM
-- Design Name: 
-- Module Name: adder - Behavioral
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
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_BIT.ALL;

entity adder is
    generic(N : integer := 8);
    Port (
        a, b : in bit_vector (N-1 downto 0);
        y    : out bit_vector (N-1 downto 0);
        co   : out bit
     );
end adder;

architecture dataflow of adder is
-- ripple carry adder
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
    -- o   <= c(N-1) XOR c(N-2);       -- overflow

end dataflow;
