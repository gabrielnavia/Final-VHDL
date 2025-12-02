library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Memoria is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        address     : in  std_logic_vector(7 downto 0);
        datain      : in  std_logic_vector(7 downto 0);
        write       : in  std_logic;
        port_in_00  : in  std_logic_vector(7 downto 0);  
        port_out_00 : out std_logic_vector(7 downto 0); 
        dataout     : out std_logic_vector(7 downto 0);
        hex0        : out std_logic_vector(6 downto 0);
        hex1        : out std_logic_vector(6 downto 0);
        hex2        : out std_logic_vector(6 downto 0);
        hex3        : out std_logic_vector(6 downto 0)
    );
end entity;

architecture Memoria_arch of Memoria is
    
    type rom_type is array (0 to 127) of std_logic_vector(7 downto 0);
    type ram_type is array (0 to 127) of std_logic_vector(7 downto 0);
    
    constant ROM : rom_type := (
        0  => x"86",  
        1  => x"AA",
        2  => x"96",  
        3  => x"E0",
        4  => x"20",  
        5  => x"00",
        others => x"00"
    );
    
    signal RAM : ram_type;
    signal rom_dataout : std_logic_vector(7 downto 0);
    signal rw_dataout : std_logic_vector(7 downto 0);
    signal dataout_internal : std_logic_vector(7 downto 0);
    signal address_int      : integer range 0 to 255;
    signal reg_port_out_00  : std_logic_vector(7 downto 0);

    function hex_to_7seg(hex: std_logic_vector(3 downto 0)) return std_logic_vector is
        variable segs : std_logic_vector(6 downto 0);
    begin
        case hex is
            when "0000" => segs := "1000000"; 
            when "0001" => segs := "1111001"; 
            when "0010" => segs := "0100100"; 
            when "0011" => segs := "0110000"; 
            when "0100" => segs := "0011001"; 
            when "0101" => segs := "0010010"; 
            when "0110" => segs := "0000010"; 
            when "0111" => segs := "1111000"; 
            when "1000" => segs := "0000000"; 
            when "1001" => segs := "0010000"; 
            when "1010" => segs := "0001000"; 
            when "1011" => segs := "0000011"; 
            when "1100" => segs := "1000110"; 
            when "1101" => segs := "0100001"; 
            when "1110" => segs := "0000110"; 
            when "1111" => segs := "0001110"; 
            when others => segs := "1111111"; 
        end case;
        return segs;
    end function;

begin

    address_int <= to_integer(unsigned(address));
    port_out_00 <= reg_port_out_00;
    dataout <= dataout_internal;

    process(clock)
    begin
        if rising_edge(clock) then
            if address_int <= 127 then
                rom_dataout <= ROM(address_int);
            else
                rom_dataout <= (others => '0');
            end if;
        end if;
    end process;

    process(clock, reset)
    begin
        if reset = '1' then
            reg_port_out_00 <= (others => '0');
        elsif rising_edge(clock) then
            if address_int = 224 and write = '1' then 
                reg_port_out_00 <= datain;
            end if;
        end if;
    end process;

    process(clock, reset)
    begin
        if reset = '1' then
            for i in 0 to 127 loop
                RAM(i) <= (others => '0');
            end loop;
            rw_dataout <= (others => '0');
        elsif rising_edge(clock) then
            if address_int >= 128 and address_int <= 255 then
                if write = '1' then
                    RAM(address_int - 128) <= datain;
                end if;
                rw_dataout <= RAM(address_int - 128);
            else
                rw_dataout <= (others => '0');
            end if;
        end if;
    end process;

	process(address_int, rom_dataout, rw_dataout, reg_port_out_00, port_in_00)
	begin
		 if address_int <= 127 then         
			  dataout_internal <= rom_dataout;
		 elsif address_int <= 255 then      
			  dataout_internal <= rw_dataout;
		 
		 elsif address_int = 0 then         
			  dataout_internal <= port_in_00;
		 elsif address_int = 224 then       
			  dataout_internal <= reg_port_out_00;
		 elsif address_int = 240 then       
			  dataout_internal <= x"E0";
		 else
			  dataout_internal <= (others => '0');
		 end if;
	end process;

    hex3 <= hex_to_7seg(address(7 downto 4));
    hex2 <= hex_to_7seg(address(3 downto 0));
    hex1 <= hex_to_7seg(dataout_internal(7 downto 4));
    hex0 <= hex_to_7seg(dataout_internal(3 downto 0));

end architecture;