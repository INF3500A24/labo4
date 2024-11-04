---------------------------------------------------------------------------------------------------
-- 
-- racine_carree_tb.vhd
--
-- v. 1.0 Pierre Langlois 2022-02-25 laboratoire #4 INF3500, fichier de démarrage
-- v. 1.1 2024-07-29
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;

entity racine_carree_tb is
  generic (
    N : positive := 16;
    M : positive := 8
    );
end racine_carree_tb;

architecture arch of racine_carree_tb is
  signal reset     : std_logic;
  signal clk       : std_logic := '0';
  constant periode : time      := 10 ns;
  constant MAX     : integer   := 10;

  -- Sigaux pour le module
  signal A         : unsigned(N - 1 downto 0);
  signal valid     : std_logic;
  signal last_in   : std_logic;
  signal ready_in  : std_logic;
  signal valid_in  : std_logic;
  signal X         : unsigned(M - 1 downto 0);
  signal last_out  : std_logic;
  signal valid_out : std_logic;
begin
  UUT : entity racine_carree_pipeline(newton)
    generic map(N, M, 11)
    port map(
      reset   => reset,
      clk     => clk,
      i_A     => A,
      i_valid => valid_in,
      i_last  => last_in,
      i_ready => ready_in,
      o_X     => X,
      o_valid => valid_out,
      o_last  => last_out
      );

  -- Simualtion de l'horloge et du power-on reset
  clk   <= not clk after periode / 2;
  reset <= '1'     after 0 ns, '0' after 5 * periode / 4;

  process(clk, reset)
    variable i : integer := 0;
  begin
    if reset = '1' then
      A        <= (others => '0');
      valid_in <= '0';
      last_in  <= '0';
      ready_in <= '0';
    elsif falling_edge(clk) then
      -- Pour le test-bench, on considère que le handshake AXI est
      -- toujours fait
      valid_in <= '1';
      ready_in <= '1';
      -- Last sur la dernière donnée
      if A = 2 ** N - 2 then
        last_in <= '1';
      else
        last_in <= '0';
      end if;

      A <= to_unsigned(i, N);

      i := i + 1;
      report integer'image(i) severity note;
      if i = MAX then
        report "Fin de simulation" severity failure;
      end if;
    end if;
  end process;

end arch;
