library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main is
  port (
    clk, reset : in std_logic;
    -- values for cmd
    -- 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, +, nothing
    cmd : in std_logic_vector(3 downto 0);
    code_timeout, set_timeout, open_timeout, display_timeout : in std_logic;
    enable_code, reset_code, enable_set, reset_set, enable_open, reset_open, enable_display, reset_display : out std_logic;
    -- values for display_cmd
    -- 0 - 9 : value of BCD
    -- 1010 : '0000'
    -- 1011 : 'Clr'
    -- 1100 : "Err"
    -- 1101 : lockout
    -- 1111 : display off
    vga_display_cmd : out std_logic_vector(3 downto 0);
    seven_seg_cmd : out std_logic_vector(5 downto 0));
end entity main;

architecture main_behavior of main is
  TYPE State_Type IS (s0, s1, s1a, s1b, s1c, s1d, s1e, s1f, s1g, s1h, s1i,
    s1j, s1k, s1l, s1m, s1n, s1o, s1p, s2, s2a, s2b, s2c, s2d, s2e, s2f,
    s2g, s2h, s2i, s2j, s2k, s2l, s2m, s2n, s2o, s2p, s2q, s3, s4, s5,
    s5a, s5b, s5c, s5d, s5e, s5f, s5g, s5h, s5i, s5j, s5k, s5l, s5m, s5n,
    s5o, s5p, sX);
  signal current_state : State_Type := s0;
  signal next_state : State_Type;

  --This signal holds the number of attempts, 0-3
  signal attempts : std_logic_vector (1 downto 0) := "00";

  -- These six signals make up the code for the lock
  -- code_five is most significant digit
  signal code_five : std_logic_vector(3 downto 0) := "0000";
  signal code_four : std_logic_vector(3 downto 0) := "0000";
  signal code_three : std_logic_vector(3 downto 0) := "0000";
  signal code_two : std_logic_vector(3 downto 0) := "0000";
  signal code_one : std_logic_vector(3 downto 0) := "0000";
  signal code_zero : std_logic_vector(3 downto 0) := "0000";

  -- These six signals hold a new code that has not yet been saved
  -- new_code_five is most significant digit
  signal new_code_five : std_logic_vector(3 downto 0) := "0000";
  signal new_code_four : std_logic_vector(3 downto 0) := "0000";
  signal new_code_three : std_logic_vector(3 downto 0) := "0000";
  signal new_code_two : std_logic_vector(3 downto 0) := "0000";
  signal new_code_one : std_logic_vector(3 downto 0) := "0000";
  signal new_code_zero : std_logic_vector(3 downto 0) := "0000";

  -- These six signal hold the users entry for the lock
  -- code_entry_five is most significant digit
  signal code_entry_five : std_logic_vector(3 downto 0) := "0000";
  signal code_entry_four : std_logic_vector(3 downto 0) := "0000";
  signal code_entry_three : std_logic_vector(3 downto 0) := "0000";
  signal code_entry_two : std_logic_vector(3 downto 0) := "0000";
  signal code_entry_one : std_logic_vector(3 downto 0) := "0000";
  signal code_entry_zero : std_logic_vector(3 downto 0) := "0000";

begin

  process(clk,reset)
  begin
    if(reset = '1') then
      next_state <= s0;
    elsif(clk'event and clk = '1') then
      case current_state is
        when s0 =>
          if(cmd = "1010") then
            next_state <= s1;
          else
            next_state <= s0;
          end if;
        when s1 =>
          next_state <= s1a;
        when s1a =>
          next_state <= s1b;
        when s1b =>
          if(cmd /= "1011") then
            next_state <= s1c;
            new_code_five <= cmd;
          elsif((cmd = "1010") or (set_timeout = '1')) then
            next_state <= s1o;
          else
            next_state <= s1b;
          end if;
        when s1c =>
          next_state <= s1d;
        when s1d =>
          if(cmd /= "1011") then
            next_state <= s1e;
            new_code_four <= cmd;
          elsif((cmd = "1010") or (set_timeout = '1')) then
            next_state <= s1o;
          else
            next_state <= s1d;
          end if;
        when s1e =>
          next_state <= s1f;
        when s1f =>
          if(cmd /= "1011") then
            next_state <= s1g;
            new_code_three <= cmd;
          elsif((cmd = "1010") or (set_timeout = '1')) then
            next_state <= s1o;
          else
            next_state <= s1f;
          end if;
        when s1g =>
          next_state <= s1h;
        when s1h =>
          if(cmd /= "1011") then
            next_state <= s1i;
            new_code_two <= cmd;
          elsif((cmd = "1010") or (set_timeout = '1')) then
            next_state <= s1o;
          else
            next_state <= s2h;
          end if;
        when s1i =>
          next_state <= s1j;
        when s1j =>
          if(cmd /= "1011") then
            next_state <= s1k;
            new_code_one <= cmd;
          elsif((cmd = "1010") or (set_timeout = '1')) then
            next_state <= s1o;
          end if;
        when s1k =>
          next_state <= s1l;
        when s1l =>
          if(cmd /= "1011") then
            next_state <= s1m;
            new_code_zero <= cmd;
          elsif((cmd = "1010") or (set_timeout = '1')) then
            next_state <= s1o;
          else
            next_state <= s1l;
          end if;
        when s1m =>
          next_state <= s1n;
        when s1n =>
          if(cmd = "1010") then
            next_state <= s2;
            code_five <= new_code_five;
            code_four <= new_code_four;
            code_three <= new_code_three;
            code_two <= new_code_two;
            code_one <= new_code_one;
            code_zero <= new_code_zero;
          elsif((cmd /= "1011") or (set_timeout = '1')) then
            next_state <= s1o;
          else
            next_state <= s1n;
          end if;
        when s1o =>
          next_state <= s1p;
        when s1p =>
          if((cmd /= "1011") or (display_timeout = '1')) then
            next_state <= s1a;
          else
            next_state <= s1p;
          end if;
        when s2 =>
          if(cmd /= "1011") then
            code_entry_five <= cmd;
            next_state <= s2a;
          else
            next_state <= s2;
          end if;
        when s2a =>
          next_state <= s2b;
        when s2b =>
          if(cmd /= "1011") then
            code_entry_four <= cmd;
            next_state <= s2d;
          elsif(display_timeout = '1') then
            next_state <= s2c;
          else
            next_state <= s2b;
          end if;
        when s2c =>
          if(code_timeout = '1') then
            next_state <= s2;
          elsif(cmd /="1011") then
            code_entry_four <= cmd;
            next_state <= s2d;
          else
            next_state <= s2c;
          end if;
        when s2d =>
          next_state <= s2e;
        when s2e =>
          if(cmd /= "1011") then
            code_entry_three <= cmd;
            next_state <= s2g;
          elsif(display_timeout = '1') then
            next_state <= s2f;
          else
            next_state <= s2e;
          end if;
        when s2f =>
          if(code_timeout = '1') then
            next_state <= s2;
          elsif(cmd /="1011") then
            code_entry_three <= cmd;
            next_state <= s2d;
          else
            next_state <= s2f;
          end if;
        when s2g =>
          next_state <= s2h;
        when s2h =>
          if(cmd /= "1011") then
            code_entry_two <= cmd;
            next_state <= s2j;
          elsif(display_timeout = '1') then
            next_state <= s2i;
          else
            next_state <= s2h;
          end if;
        when s2i =>
          if(code_timeout = '1') then
            next_state <= s2;
          elsif(cmd /="1011") then
            code_entry_two <= cmd;
            next_state <= s2j;
          else
            next_state <= s2i;
          end if;
        when s2j =>
          next_state <= s2k;
        when s2k =>
          if(cmd /= "1011") then
            code_entry_one <= cmd;
            next_state <= s2m;
          elsif(display_timeout = '1') then
            next_state <= s2l;
          else
            next_state <= s2k;
          end if;
        when s2l =>
          if(code_timeout = '1') then
            next_state <= s2;
          elsif(cmd /="1011") then
            code_entry_one <= cmd;
            next_state <= s2m;
          else
            next_state <= s2l;
          end if;
        when s2m =>
          next_state <= s2n;
        when s2n =>
          if(cmd /= "1011") then
            code_entry_zero <= cmd;
            next_state <= s2p;
          elsif(display_timeout = '1') then
            next_state <= s2o;
          else
            next_state <= s2n;
          end if;
        when s2o =>
          if(code_timeout = '1') then
            next_state <= s2;
          elsif(cmd /="1011") then
            code_entry_zero <= cmd;
            next_state <= s2p;
          else
            next_state <= s2o;
          end if;
        when s2p =>
          next_state <= s2q;
        when s2q =>
          if((code_entry_five /= code_five) or
          (code_entry_four /= code_four) or
          (code_entry_three /= code_three) or
          (code_entry_two /= code_two) or
          (code_entry_one /= code_one) or
          (code_entry_zero /= code_zero)) then
            if(attempts < "11") then
              next_state <= s3;
              attempts <= std_logic_vector(unsigned(attempts) + 1);
            else
              next_state <= sX;
            end if;
          else
            next_state <= s5;
          end if;
        when s3 =>
          next_state <= s4;
        when s4 =>
          if(display_timeout = '1') then
            next_state <= s2;
          end if;
        when s5 =>
          next_state <= s5a;
        when s5a =>
          next_state <= s5b;
        when s5b =>
          if(open_timeout = '1') then
            next_state <= s2;
          elsif(cmd = "1010") then
            next_state <= s5c;
          else
            next_state <= s5b;
          end if;
        when s5c =>
          next_state <= s5d;
        when s5d =>
          if(cmd /= "1011") then
            new_code_five <= cmd;
            next_state <= s5e;
          elsif((cmd = "1010") or (set_timeout = '1')) then
            next_state <= s2;
          else
            next_state <= s5d;
          end if;
        when s5e =>
          next_state <= s5f;
        when s5f =>
          if(cmd /= "1011") then
            new_code_four <= cmd;
            next_state <= s5g;
          elsif((cmd = "1010") or (set_timeout = '1')) then
            next_state <= s2;
          else
            next_state <= s5f;
          end if;
        when s5g =>
          next_state <= s5h;
        when s5h =>
          if(cmd /= "1011") then
            new_code_three <= cmd;
            next_state <= s5i;
          elsif((cmd = "1010") or (set_timeout = '1')) then
            next_state <= s2;
          else 
            next_state <= s5h;
          end if;
        when s5i =>
          next_state <= s5j;
        when s5j =>
          if(cmd /= "1011") then
            new_code_two <= cmd;
            next_state <= s5k;
          elsif((cmd = "1010") or (set_timeout = '1')) then
            next_state <= s2;
          else
            next_state <= s5j;
          end if;
        when s5k =>
          next_state <= s5l;
        when s5l =>
          if(cmd /= "1011") then
            new_code_one <= cmd;
            next_state <= s5m;
          elsif((cmd = "1010") or (set_timeout = '1')) then
            next_state <= s2;
          else
            next_state <= s5l;
          end if;
        when s5m =>
          next_state <= s5n;
        when s5n =>
          if(cmd /= "1011") then
            new_code_zero <= cmd;
            next_state <= s5o;
          elsif((cmd = "1010") or (set_timeout = '1')) then
            next_state <= s2;
          else
            next_state <= s5n;
          end if;
        when s5o =>
          next_state <= s5p;
        when s5p =>
          if(cmd = "1010") then
            code_five <= new_code_five;
            code_four <= new_code_four;
            code_three <= new_code_three;
            code_two <= new_code_two;
            code_one <= new_code_one;
            code_zero <= new_code_zero;
            next_state <= s2;
          elsif(set_timeout = '1') then
            next_state <= s2;
          else
            next_state <= s5p;
          end if;
        when sX =>
          next_state <= sX;
      end case;
    end if;
  end process;
  process(current_state)
  begin
    case(current_state) is
      when s0 =>
        vga_display_cmd <= "1111";
        seven_seg_cmd <= "000000";
      when s1 =>
        vga_display_cmd <= "1111";
        seven_seg_cmd <= "000001";
      when s1a =>
        vga_display_cmd <= "1111";
        reset_set <= '1';
        enable_set <= '1';
        seven_seg_cmd <= "000010";
      when s1b =>
        reset_set <= '0';
        enable_set <= '1';
        seven_seg_cmd <= "000011";
      when s1c =>
        reset_set <= '1';
        enable_set <= '1';
        seven_seg_cmd <= "000100";
      when s1d =>
        reset_set <= '0';
        enable_set <= '1';
        seven_seg_cmd <= "000101";
      when s1e =>
        reset_set <= '1';
        enable_set <= '1';
        seven_seg_cmd <= "000110";
      when s1f =>
        reset_set <= '0';
        enable_set <= '1';
        seven_seg_cmd <= "000111";
      when s1g =>
        reset_set <= '1';
        enable_set <= '1';
        seven_seg_cmd <= "001000";
      when s1h =>
        reset_set <= '0';
        enable_set <= '1';
        seven_seg_cmd <= "001001";
      when s1i =>
        reset_set <= '1';
        enable_set <= '1';
        seven_seg_cmd <= "001010";
      when s1j =>
        reset_set <= '0';
        enable_set <= '1';
        seven_seg_cmd <= "001011";
      when s1k =>
        reset_set <= '1';
        enable_set <= '1';
        seven_seg_cmd <= "001100";
      when s1l =>
        reset_set <= '0';
        enable_set <= '1';
        seven_seg_cmd <= "001101";
      when s1m =>
        reset_set <= '1';
        enable_set <= '1';
        seven_seg_cmd <= "001110";
      when s1n =>
        reset_set <= '0';
        enable_set <= '1';
        seven_seg_cmd <= "001111";
      when s1o =>
        enable_set <= '0';
        reset_display <= '1';
        enable_display <= '1';
        vga_display_cmd <= "1011";
        seven_seg_cmd <= "010001";
      when s1p =>
        reset_display <= '0';
        enable_display <= '1';
        vga_display_cmd <= "1011";
        seven_seg_cmd <= "010010";
      when s2 =>
        enable_set <= '0';
        enable_open <= '0';
        enable_display <= '0';
        vga_display_cmd <= "1111";
        seven_seg_cmd <= "010011";
      when s2a =>
        reset_code <= '1';
        enable_code <= '1';
        reset_display <= '1';
        enable_display <= '1';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "010100";
      when s2b =>
        reset_code <= '0';
        enable_code <= '1';
        reset_display <= '0';
        enable_display <= '1';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "010101";
      when s2c =>
        reset_code <= '0';
        enable_code <= '1';
        reset_display <= '0';
        enable_display <= '0';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "010110";
      when s2d =>
        reset_code <= '1';
        enable_code <= '1';
        reset_display <= '1';
        enable_display <= '1';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "010111";
      when s2e =>
        reset_code <= '0';
        enable_code <= '1';
        reset_display <= '0';
        enable_display <= '1';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "011000";
      when s2f =>
        reset_code <= '0';
        enable_code <= '1';
        reset_display <= '0';
        enable_display <= '0';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "011001";
      when s2g =>
        reset_code <= '1';
        enable_code <= '1';
        reset_display <= '1';
        enable_display <= '1';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "011010";
      when s2h =>
        reset_code <= '0';
        enable_code <= '1';
        reset_display <= '0';
        enable_display <= '1';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "011011";
      when s2i =>
        reset_code <= '0';
        enable_code <= '1';
        reset_display <= '0';
        enable_display <= '0';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "011100";
      when s2j =>
        reset_code <= '1';
        enable_code <= '1';
        reset_display <= '1';
        enable_display <= '1';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "011101";
      when s2k =>
        reset_code <= '0';
        enable_code <= '1';
        reset_display <= '0';
        enable_display <= '1';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "011110";
      when s2l =>
        reset_code <= '0';
        enable_code <= '1';
        reset_display <= '0';
        enable_display <= '0';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "011111";
      when s2m =>
        reset_code <= '1';
        enable_code <= '1';
        reset_display <= '1';
        enable_display <= '1';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "100000";
      when s2n =>
        reset_code <= '0';
        enable_code <= '1';
        reset_display <= '0';
        enable_display <= '1';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "100001";
      when s2o =>
        reset_code <= '0';
        enable_code <= '1';
        reset_display <= '0';
        enable_display <= '0';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "100010";
      when s2p =>
        reset_code <= '0';
        enable_code <= '0';
        reset_display <= '1';
        enable_display <= '1';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "100011";
      when s2q =>
        reset_display <= '0';
        enable_display <= '1';
        vga_display_cmd <= cmd;
        seven_seg_cmd <= "100100";
      when s3 =>
        reset_display <= '1';
        enable_display <= '1';
        vga_display_cmd <= "1100";
        seven_seg_cmd <= "100101";
      when s4 =>
        reset_display <= '0';
        enable_display <= '1';
        vga_display_cmd <= "1100";
        seven_seg_cmd <= "100110";
      when s5 =>
        vga_display_cmd <= "1010";
        seven_seg_cmd <= "100111";
      when s5a =>
        reset_open <= '1';
        enable_open <= '1';
        vga_display_cmd <= "1010";
        seven_seg_cmd <= "101000";
      when s5b =>
        reset_open <= '0';
        enable_open <= '1';
        vga_display_cmd <= "1010";
        seven_seg_cmd <= "101001";
      when s5c =>
        reset_set <= '1';
        enable_set <= '1';
        seven_seg_cmd <= "101010";
      when s5d =>
        reset_set <= '0';
        enable_set <= '1';
        seven_seg_cmd <= "101011";
      when s5e =>
        reset_set <= '1';
        enable_set <= '1';
        seven_seg_cmd <= "101100";
      when s5f =>
        reset_set <= '0';
        enable_set <= '1';
        seven_seg_cmd <= "101101";
      when s5g =>
        reset_set <= '1';
        enable_set <= '1';
        seven_seg_cmd <= "101110";
      when s5h =>
        reset_set <= '0';
        enable_set <= '1';
        seven_seg_cmd <= "101111";
      when s5i =>
        reset_set <= '1';
        enable_set <= '1';
        seven_seg_cmd <= "110000";
      when s5j =>
        reset_set <= '0';
        enable_set <= '1';
        seven_seg_cmd <= "110001";
      when s5k =>
        reset_set <= '1';
        enable_set <= '1';
        seven_seg_cmd <= "110010";
      when s5l =>
        reset_set <= '0';
        enable_set <= '1';
        seven_seg_cmd <= "110011";
      when s5m =>
        reset_set <= '1';
        enable_set <= '1';
        seven_seg_cmd <= "110100";
      when s5n =>
        reset_set <= '0';
        enable_set <= '1';
        seven_seg_cmd <= "110101";
      when s5o =>
        reset_set <= '1';
        enable_set <= '1';
        seven_seg_cmd <= "110110";
      when s5p =>
        reset_set <= '0';
        enable_set <= '1';
        seven_seg_cmd <= "110111";
      when sx =>
        vga_display_cmd <= "1101";
        seven_seg_cmd <= "111000";
    end case;
  end process;
  current_state <= next_state;
end architecture main_behavior;
