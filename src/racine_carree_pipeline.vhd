---------------------------------------------------------------------------------------------------
-- 
-- racine_carree_pipeline.vhd
--
-- v. 1.0 2024-08-07 laboratoire #4 INF3500 - code de base
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity racine_carree_pipeline is
  generic (
    -- Nombre de bits de A
    N : positive := 16;
    -- Nombre de bits de X
    M : positive := 8;
    );
  port (
    reset, clk : in  std_logic;
    -- Le nombre dont on cherche la racine carré
    i_A        : in  unsigned(N - 1 downto 0);
    -- '1' quand une données qui est passée à travers la pipeline
    -- est valide
    i_valid    : in  std_logic;
    -- '1' quand la dernière donnée est passée à travers la
    -- pipeline
    i_last     : in  std_logic;
    -- Indique quand le zynq est prêt à recevoir des données
    i_ready    : in  std_logic;
    -- La racine carré de A, telle que X * X = A
    o_X        : out unsigned(M - 1 downto 0);
    -- '1' quand une données qui est passée à travers la pipeline
    -- est valide
    o_valid    : out std_logic;
    -- '1' quand la dernière donnée est passée à travers la
    -- pipeline
    o_last     : out std_logic
    );
end racine_carree_pipeline;

architecture newton of racine_carree_pipeline is
  -- Pour le module de division, nombre de bits pour exprimer les réciproques
  constant W_frac : integer := 14;

  -- Types que vous pouvez utiliser pour implémenter la pipeline
  type pipeline_vec_n_t is array(0 to 2) of unsigned(N-1 downto 0);
  type pipeline_bit_t is array(0 to 2) of std_logic;

  signal A_pipeline                    : pipeline_vec_n_t;
  signal valid_pipeline, last_pipeline : pipeline_bit_t;
begin
  -- Mettre les valeurs de sortie au dernier étage de pipeline
  o_X     <= A_pipeline(2)(M-1 downto 0);
  o_valid <= valid_pipeline(2);
  o_last  <= last_pipeline(2);

  -- diviseur_0 : entity division_par_reciproque(arch)
  --   generic map(N, M, W_frac)
  --   port map(
  --     num      => un_signal_ici
  --     denom    => un_autre_signal
  --     quotient => encore_un_signal
  --     );

  process (clk, reset) is
  begin
    if reset = '1' then
      -- Réinitialiser les pipelines
      A_pipeline     <= (others => (others => '0'));
      valid_pipeline <= (others => '0');
      last_pipeline  <= (others => '0');
    elsif rising_edge(clk) and i_ready = '1' then
      -- Le premier élément de la pipeline est l'entrée, on lit une entrée à
      -- chaque coup d'horloge
      A_pipeline(0)     <= i_A;
      valid_pipeline(0) <= i_valid;
      last_pipeline(0)  <= i_last;

      -- Faire circuler les données dans la pipeline à chaque coup d'horloge
      -- (ici, aucune opération n'est réalisée, on se contente de faire passer
      -- les données de l'entrée vers la sortie. C'est à vous d'implémenter le
      -- module)
      A_pipeline(1)     <= A_pipeline(0);
      valid_pipeline(1) <= valid_pipeline(0);
      last_pipeline(1)  <= last_pipeline(0);

      A_pipeline(2)     <= A_pipeline(1);
      valid_pipeline(2) <= valid_pipeline(1);
      last_pipeline(2)  <= last_pipeline(1);
    end if;
  end process;

end newton;
