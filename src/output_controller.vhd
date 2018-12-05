library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity output_controller is
  port(display : in std_logic_vector(3 downto 0);
    clk : in std_logic;
    lockout_led : out std_logic;
    vga : out std_logic_vector(13 downto 0));
end entity output_controller;

architecture output_behavior of output_controller is

  signal refresh_counter : std_logic_vector(19 downto 0);
  signal anode_counter : std_logic_vector(1 downto 0);
  signal display_one, display_two, display_three, display_four : std_logic_vector(7 downto 0);

begin

    -- Clock process for a 10.5ms refresh period
    process(clk)
    begin
        if(clk'event and clk = '1') then
            refresh_counter <= std_logic_vector(unsigned(refresh_counter) + 1);
        end if;
    end process;
    anode_counter <= refresh_counter(19 downto 18);
    process(anode_counter)
    begin
        case anode_counter is
        when "00" =>
            vga(11 downto 8) <= "0111";
            vga(7 downto 0) <= display_one;
        when "01" =>
            vga(11 downto 8) <= "1011";
            vga(7 downto 0) <= display_two;
        when "10" =>
            vga(11 downto 8) <= "1101";
            vga(7 downto 0) <= display_three;
        when "11" =>
            vga(11 downto 8) <= "1110";
            vga(7 downto 0) <= display_four;
        end case;
    end process;

    process(display)
        begin
            case display is
              when "0000" =>
                -- display '0'
                display_one <= "11111111";
                display_two <= "11111111";
                display_three <= "11111111";
                display_four <= "00000011";
                lockout_led <= '0';
              when "0001" =>
                -- display '1'
                display_one <= "11111111";
                display_two <= "11111111";
                display_three <= "11111111";
                display_four <= "10011111";
                lockout_led <= '0';
              when "0010" =>
                -- display '2'
                display_one <= "11111111";
                display_two <= "11111111";
                display_three <= "11111111";
                display_four <= "00100101";
                lockout_led <= '0';
              when "0011" =>
                -- display '3'
                display_one <= "11111111";
                display_two <= "11111111";
                display_three <= "11111111";
                display_four <= "00001101";
                lockout_led <= '0';
              when "0100" =>
                -- display '4'
                display_one <= "11111111";
                display_two <= "11111111";
                display_three <= "11111111";
                display_four <= "10011001";
                lockout_led <= '0';
              when "0101" =>
                -- display '5'
                display_one <= "11111111";
                display_two <= "11111111";
                display_three <= "11111111";
                display_four <= "01001001";
                lockout_led <= '0';
              when "0110" =>
                -- display '6'
                display_one <= "11111111";
                display_two <= "11111111";
                display_three <= "11111111";
                display_four <= "01000001";
                lockout_led <= '0';
              when "0111" =>
                -- display '7'
                display_one <= "11111111";
                display_two <= "11111111";
                display_three <= "11111111";
                display_four <= "00011111";
                lockout_led <= '0';
              when "1000" =>
                -- display '8'
                display_one <= "11111111";
                display_two <= "11111111";
                display_three <= "11111111";
                display_four <= "00000001";
                lockout_led <= '0';
              when "1001" =>
                -- display '9'
                display_one <= "11111111";
                display_two <= "11111111";
                display_three <= "11111111";
                display_four <= "00001001";
                lockout_led <= '0';
              when "1010" =>
                -- make display show "0000"
                display_one <= "00000011";
                display_two <= "00000011";
                display_three <= "00000011";
                display_four <= "00000011";
                lockout_led <= '0';
              when "1011" =>
                -- make display show "Clr"
                display_one <= "11111111";
                display_two <= "11100101";
                display_three <= "11110011";
                display_four <= "11110101";
                lockout_led <= '0';
              when "1100" =>
                -- make display show "err"
                display_one <= "11111111";
                display_two <= "01100001";
                display_three <= "11110101";
                display_four <= "11110101";
                lockout_led <= '0';
              when "1101" =>
                -- lockout led
                display_one <= "11111111";
                display_two <= "11111111";
                display_three <= "11111111";
                display_four <= "11111111";
                lockout_led <= '1';
              when others =>
                -- display off
                display_one <= "11111111";
                display_two <= "11111111";
                display_three <= "11111111";
                display_four <= "11111111";
                lockout_led <= '0';
            end case;
        end process;
end architecture output_behavior;
