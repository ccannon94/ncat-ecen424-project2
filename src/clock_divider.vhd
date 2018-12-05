library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider is
     port(clk : in std_logic;
          start_timer : in std_logic;
	  clk_25,FastClock,MediumClock,SlowClock, led0 : out std_logic);
end clock_divider;

architecture clock_divider_arch of clock_divider is
signal slowClock_sig : STD_LOGIC;

begin
    process
    variable cnt :	std_logic_vector(26 downto 0):= "000000000000000000000000000";
    begin
        wait until ((clk'EVENT) AND (clk = '1'));
		if (start_timer = '1') then
	       cnt := "000000000000000000000000000";
	    else
           cnt := STD_LOGIC_VECTOR(unsigned(cnt) + 1);
	    end if;
   	    FastClock <= cnt(22);
   	    MediumClock <= cnt(24);
   	    SlowClock <= cnt(26);
        slowClock_sig <= cnt(26);
        if (slowClock_sig = '1') then
		  led0 <= '1';
	    else
		  led0 <= '0';
	    end if;
	end process;
    process
     variable cnt2 :    std_logic_vector(2 downto 0):= "000";
    begin
        wait until ((clk'EVENT) AND (clk = '1'));
           if (start_timer = '1') then
              cnt2 := "000";
           else
              cnt2 := STD_LOGIC_VECTOR(unsigned(cnt2) + 1);
           end if;
          if(cnt2 >= "11") then
            clk_25 <= '1';
            cnt2 := "000";
          end if;
       end process;

end clock_divider_arch;
