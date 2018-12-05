library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity digital_lock is
  port(ps2_data, ps2_clk, clk, reset : in std_logic;
    vga_data : out std_logic_vector(13 downto 0);
    lockout_led : out std_logic;
    med_clk_led : out std_logic);
end entity digital_lock;

architecture digital_lock_arch of digital_lock is

  -- Signals for clock divider
  signal start_timer : std_logic := '0';
  signal fast_clk, med_clk, slow_clk, slow_clk_led : std_logic;

  -- Signals for input controller
  signal ps2_code_new : std_logic;
  signal ps2_code : std_logic_vector(3 downto 0);

  -- Signals for output controller
  signal display_cmd : std_logic_vector(3 downto 0);
  signal vga_sig : std_logic_vector(13 downto 0);
  signal lockout_led_sig : std_logic;

  -- Signals for code timeout timer
  signal enable_code, reset_code : std_logic;
  signal code_timeout : std_logic;

  -- Signals for display timeout timer
  signal enable_display, reset_display : std_logic;
  signal display_timeout : std_logic;

  -- Signals for open timeout timer
  signal enable_open, reset_open : std_logic;
  signal open_timeout : std_logic;

  -- Signals for set timeout timer
  signal enable_set, reset_set : std_logic;
  signal set_timeout : std_logic;

  component clock_divider is
    port(clk : in std_logic;
         start_timer : in std_logic;
         FastClock,MediumClock,SlowClock, led0 : out std_logic);
  end component clock_divider;

  component input_controller is
    port(clk, ps2_clk, ps2_data : in std_logic;
      ps2_code_new : out std_logic;
      ps2_code     : out std_logic_vector(3 downto 0));
  end component input_controller;

  component output_controller is
    port(display : in std_logic_vector(3 downto 0);
      clk : in std_logic;
      lockout_led : out std_logic;
      vga : out std_logic_vector(13 downto 0));
  end component output_controller;

  component code_timeout_timer is
    port(enable, reset, one_hz_clk : in std_logic;
      done : out std_logic);
  end component code_timeout_timer;

  component display_timeout_timer is
    port(enable, reset, one_hz_clk : in std_logic;
      done : out std_logic);
  end component display_timeout_timer;

  component open_timeout_timer is
    port(enable, reset, one_hz_clk : in std_logic;
      done : out std_logic);
  end component open_timeout_timer;

  component set_timeout_timer is
    port(enable, reset, one_hz_clk : in std_logic;
      done : out std_logic);
  end component set_timeout_timer;

  component main is
    port(sys_clk, clk, reset : in std_logic;
      cmd : in std_logic_vector(3 downto 0);
      code_timeout, set_timeout, open_timeout, display_timeout : in std_logic;
      enable_code, reset_code, enable_set, reset_set, enable_open, reset_open,
      enable_display, reset_display : out std_logic;
      lockout_led : out std_logic;
      display_cmd : out std_logic_vector(3 downto 0));
  end component main;

begin
  ic : input_controller port map(clk, ps2_clk, ps2_data, ps2_code_new, ps2_code);
  clk_div : clock_divider port map(clk, start_timer, fast_clk, med_clk, slow_clk, slow_clk_led);
  oc : output_controller port map(display_cmd, clk, lockout_led_sig, vga_sig);
  code_timer : code_timeout_timer port map(enable_code, reset_code, slow_clk, code_timeout);
  display_timer : display_timeout_timer port map(enable_display, reset_display, slow_clk, display_timeout);
  open_timer : open_timeout_timer port map(enable_open, reset_open, slow_clk, open_timeout);
  set_timer : set_timeout_timer port map(enable_set, reset_set, slow_clk, set_timeout);
  main_fsm : main port map(clk, med_clk, reset, ps2_code, code_timeout, set_timeout, open_timeout, display_timeout, enable_code, reset_code, enable_set, reset_set, enable_open, reset_open, enable_display, reset_display, lockout_led, display_cmd);

  lockout_led <= lockout_led_sig;
  vga_data <= vga_sig;
  med_clk_led <= med_clk;
end architecture digital_lock_arch;
