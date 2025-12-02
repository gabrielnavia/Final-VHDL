library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Top is
    port (
        CLOCK_50 : in  std_logic;
        SW       : in  std_logic_vector(9 downto 0);
        KEY0     : in  std_logic;
        GPIO_EXT : in  std_logic_vector(7 downto 0);
        LEDR     : out std_logic_vector(7 downto 0);
        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX2     : out std_logic_vector(6 downto 0);
        HEX3     : out std_logic_vector(6 downto 0)
    );
end Top;

architecture rtl of Top is

    signal address_raw : std_logic_vector(7 downto 0);
    signal address     : std_logic_vector(7 downto 0);
    signal datain      : std_logic_vector(7 downto 0);
    signal write_en    : std_logic;
    signal reset_sync  : std_logic;

begin

    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            reset_sync <= not KEY0;  
        end if;
    end process;

    address_raw <= SW(7 downto 0);

    process(SW, GPIO_EXT, address_raw)
    begin
        address  <= address_raw;
        datain   <= (others => '0');
        write_en <= '0';

        case SW(9 downto 8) is
            when "00" =>  
                null;

            when "01" =>  
                datain   <= GPIO_EXT;
                write_en <= '1';

            when "10" =>  
                datain <= GPIO_EXT;
                if address_raw = x"E0" then
                    write_en <= '1';
                end if;

            when "11" => 
                address  <= x"E0";
                datain   <= GPIO_EXT;
                write_en <= '1';

            when others =>
                null;
        end case;
    end process;

    U_MEM: entity work.Memoria
    port map (
        clock        => CLOCK_50,
        reset        => reset_sync,   
        address      => address,
        datain       => datain,
        write        => write_en,
        port_in_00   => GPIO_EXT,
        port_out_00  => LEDR,
        dataout      => open,
        hex0         => HEX0,      
        hex1         => HEX1,
        hex2         => HEX2,
        hex3         => HEX3
    );

end rtl;
