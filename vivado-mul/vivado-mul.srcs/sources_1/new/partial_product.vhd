----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2025 12:42:13 PM
-- Design Name: 
-- Module Name: partial_product - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity partial_product is
    generic (   IN_WIDTH : integer := 8;
                OUT_WIDTH : integer := 8
    );
    port    (   a : in  bit_vector(IN_WIDTH-1 downto 0);
                b, s : in  bit;
                y : out bit_vector(OUT_WIDTH-1 downto 0)
    );
end partial_product;

architecture dataflow of partial_product is

    constant EXTEND_WIDTH   : integer := OUT_WIDTH - IN_WIDTH;

    signal pp_s  : bit_vector(IN_WIDTH-1 downto 0);
    signal product_extension_s    : bit_vector(EXTEND_WIDTH-1 downto 0);

begin

    pp_gen : for i in 0 to IN_WIDTH - 1 generate
        pp_s(i) <= a(i) AND b;
    end generate pp_gen;

    product_extension_s <=  (others => pp_s(IN_WIDTH - 1)) when s = '1' else  -- sign extend
                            (others => '0');        -- logical (zero) extend

    -- ouput extented result
    y <= product_extension_s & pp_s;


end dataflow;
