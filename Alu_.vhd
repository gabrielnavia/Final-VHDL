library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
   port(
      A     : in  std_logic_vector(7 downto 0);
      B     : in  std_logic_vector(7 downto 0);
      Sel   : in  std_logic; 
      
      Y     : out std_logic_vector(7 downto 0);
      Carry : out std_logic;
      Ovf   : out std_logic;
      Neg   : out std_logic;
      Zero  : out std_logic;
      
      hex0  : out std_logic_vector(6 downto 0);  
      hex1  : out std_logic_vector(6 downto 0);  
      hex2  : out std_logic_vector(6 downto 0);  
      hex3  : out std_logic_vector(6 downto 0)   
   );
end entity;

architecture rtl of ALU is

   signal result_extended : unsigned(8 downto 0);  
   signal output_value    : std_logic_vector(7 downto 0);
   signal signed_A        : signed(8 downto 0); 
   signal signed_B        : signed(8 downto 0);

   function hex_to_7seg(nibble : std_logic_vector(3 downto 0)) return std_logic_vector is
      variable segments : std_logic_vector(6 downto 0);
   begin
      case nibble is
         when "0000" => segments := "1000000"; when "0001" => segments := "1111001";
         when "0010" => segments := "0100100"; when "0011" => segments := "0110000";
         when "0100" => segments := "0011001"; when "0101" => segments := "0010010";
         when "0110" => segments := "0000010"; when "0111" => segments := "1111000";
         when "1000" => segments := "0000000"; when "1001" => segments := "0010000";
         when "1010" => segments := "0001000"; when "1011" => segments := "0000011";
         when "1100" => segments := "1000110"; when "1101" => segments := "0100001";
         when "1110" => segments := "0000110"; when "1111" => segments := "0001110";
         when others => segments := "1111111"; 
      end case;
      return segments;
   end function;

begin

   result_extended <= ('0' & unsigned(A)) + ('0' & unsigned(B)) when Sel = '0' else
                      ('0' & unsigned(A)) - ('0' & unsigned(B));
   
   signed_A <= signed('0' & A);
   signed_B <= signed('0' & B);

   output_value <= std_logic_vector(result_extended(7 downto 0));
   Y <= output_value;

   Carry <= result_extended(8);

   process(Sel, signed_A, signed_B, output_value)
      variable signed_result : signed(8 downto 0);
   begin
      if Sel = '0' then
         signed_result := signed_A + signed_B;
         if (signed_A(7) = signed_B(7)) and (signed_result(7) /= signed_A(7)) then
            Ovf <= '1';
         else
            Ovf <= '0';
         end if;
      else
         signed_result := signed_A - signed_B;
         if (signed_A(7) /= signed_B(7)) and (signed_result(7) = signed_B(7)) then
            Ovf <= '1';
         else
            Ovf <= '0';
         end if;
      end if;
   end process;

   Neg <= output_value(7);
   Zero <= '1' when output_value = "00000000" else '0';

   hex0 <= hex_to_7seg(output_value(3 downto 0));   
   hex1 <= hex_to_7seg(output_value(7 downto 4));   
   hex2 <= hex_to_7seg(B(3 downto 0));            
   hex3 <= hex_to_7seg(B(7 downto 4));            

end architecture;