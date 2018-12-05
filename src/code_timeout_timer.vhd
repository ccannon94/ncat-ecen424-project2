library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity code_timeout_timer is
  port(enable, reset, one_hz_clk : in std_logic; done : out std_logic);
end entity code_timeout_timer;

architecture code_timeout_behavior of code_timeout_timer is

signal current_count : std_logic_vector(4 downto 0) := "00000";


begin

    process(one_hz_clk, reset)
    begin
        if(reset = '1') then 
	    current_count <= "00000";
	    done <= '0';
        elsif(one_hz_clk'event and one_hz_clk = '1' and enable = '1') then
            if(current_count < "10100") then
                current_count <= std_logic_vector(unsigned(current_count) + 1);
                done <= '0';
            else
                done <= '1';
            end if;
        end if;
end process;

end architecture code_timeout_behavior;
