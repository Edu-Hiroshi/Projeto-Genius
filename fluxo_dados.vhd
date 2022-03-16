------------------------------------------------------------------
-- Arquivo   : fluxo_de_dados.vhd
-- Projeto   : Experiencia 05
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     11/02/2022  1.0     Henrique Matheus  versao inicial
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fluxo_dados is
    port (
        clock     : in std_logic;
        contaS    : in std_logic;
        zeraS     : in std_logic;
        contaE    : in std_logic;
        zeraE     : in std_logic;
        escreve   : in std_logic;
        botoes    : in std_logic_vector (3 downto 0);
        registraR : in std_logic;
        limpaR    : in std_logic;
        contaTMR  : in std_logic;
        zeraTMR   : in std_logic;
        registraM : in std_logic;
        limpaM    : in std_logic;
        enderecoMenorOuIgualSequencia : out std_logic;
        enderecoIgualSequencia        : out std_logic;
        fimTMR                        : out std_logic;
        fimS                          : out std_logic;
        fimE                          : out std_logic;
        chavesIgualMemoria            : out std_logic;
        temJogada                     : out std_logic;
        db_temjogada                  : out std_logic;
        db_sequencia                  : out std_logic_vector (3 downto 0);
        db_contagem                   : out std_logic_vector (3 downto 0);
        db_memoria                    : out std_logic_vector (3 downto 0);
        db_jogada                     : out std_logic_vector (3 downto 0)
    );
 end entity fluxo_dados;
 
architecture estrutural of fluxo_dados is

  signal s_endereco    : std_logic_vector (3 downto 0); -- Endereco de saida
  signal s_dado        : std_logic_vector (3 downto 0); -- Dado de saida
  signal s_jogada      : std_logic_vector (3 downto 0); -- sinal interno da jogada
  signal s_sequencia   : std_logic_vector (3 downto 0); -- sinal interno da sequencia

  signal s_not_zeraS     : std_logic; -- Sinal auxiliar devido ao comportamento ativo baixo do reset do contador da sequência
  signal s_not_zeraE     : std_logic; -- Sinal auxiliar devido ao comportamento ativo baixo do reset do contador do endereço
  signal s_not_registraM : std_logic; -- Sinal auxiliar devido ao comportamento ativo baixo da escrita
  signal s_not_registraR : std_logic; -- Sinal auxiliar devido ao comportamento ativo baixo da escrita no registrador
  signal s_temJogada     : std_logic; -- Sinal auxiliar que informa se houve jogada
  signal s_not_escreve   : std_logic; -- Sinal auxiliar devido ao comportamento ativo baixo da escrita na memória

  -- Contador binario modulo 16
  component contador_163
    port (
        clock : in  std_logic;
        clr   : in  std_logic;
        ld    : in  std_logic;
        ent   : in  std_logic;
        enp   : in  std_logic;
        D     : in  std_logic_vector (3 downto 0);
        Q     : out std_logic_vector (3 downto 0);
        rco   : out std_logic 
    );
  end component;

  -- Comparador de 4 bits, com operacoes de maior, menor e igual
  component comparador_85
    port (
        i_A3   : in  std_logic;
        i_B3   : in  std_logic;
        i_A2   : in  std_logic;
        i_B2   : in  std_logic;
        i_A1   : in  std_logic;
        i_B1   : in  std_logic;
        i_A0   : in  std_logic;
        i_B0   : in  std_logic;
        i_AGTB : in  std_logic;
        i_ALTB : in  std_logic;
        i_AEQB : in  std_logic;
        o_AGTB : out std_logic;
        o_ALTB : out std_logic;
        o_AEQB : out std_logic
    );
  end component;

  -- Memoria RAM 16x4
  component ram_16x4 is
    port (       
       clk          : in  std_logic;
       endereco     : in  std_logic_vector(3 downto 0);
       dado_entrada : in  std_logic_vector(3 downto 0);
       we           : in  std_logic;
       ce           : in  std_logic;
       dado_saida   : out std_logic_vector(3 downto 0)
    );
  end component;

  -- registrador de 4 bits
  component registrador_173 is
    port (
        clock : in  std_logic;
        clear : in  std_logic;
        en1   : in  std_logic;
        en2   : in  std_logic;
        D     : in  std_logic_vector (3 downto 0);
        Q     : out std_logic_vector (3 downto 0)
   );
end component;

component contador_m is
  generic (
      constant M: integer := 25000000 -- tempo máximo de contagem = 0,5s
  );
  port (
      clock   : in  std_logic;
      zera_as : in  std_logic;
      zera_s  : in  std_logic;
      conta   : in  std_logic;
      Q       : out std_logic_vector(natural(ceil(log2(real(M))))-1 downto 0);
      fim     : out std_logic;
      meio    : out std_logic
  );
end component;

component edge_detector is
  port (
      clock  : in  std_logic;
      reset  : in  std_logic;
      sinal  : in  std_logic;
      pulso  : out std_logic
  );
end component;

begin

  -- Sinais ativos baixo
  s_not_zeraS     <= not zeraS;
  s_not_zeraE     <= not zeraE;
  s_not_registraM <= not registraM;
  s_not_registraR <= not registraR;
  s_not_escreve   <= not escreve;

  s_temJogada <= botoes(0) or botoes(1) or botoes(2) or botoes(3);
  
  ContSeq: contador_163
    port map (
        clock => clock,
        clr   => s_not_zeraS, -- clr ativo baixo
        ld    => '1', -- ld inativo
        ent   => '1',
        enp   => contaS,
        D     => "0000",
        Q     => s_sequencia,
        rco   => fimS
    );

  ContEnd: contador_163
    port map (
        clock => clock,
        clr   => s_not_zeraE, -- clr ativo baixo
        ld    => '1', -- ld inativo
        ent   => '1',
        enp   => contaE,
        D     => "0000",
        Q     => s_endereco,
        rco   => fimE
    );

  CompSeq: comparador_85
    port map (
        i_A3   => s_sequencia(3),
        i_B3   => s_endereco(3),
        i_A2   => s_sequencia(2),
        i_B2   => s_endereco(2),
        i_A1   => s_sequencia(1),
        i_B1   => s_endereco(1),
        i_A0   => s_sequencia(0),
        i_B0   => s_endereco(0),
        i_AGTB => '0',
        i_ALTB => '0',
        i_AEQB => '1', -- Pré estabelece relação de igualdade entre "A" e "B"
        o_AGTB => enderecoMenorOuIgualSequencia,
        o_ALTB => open,
        o_AEQB => enderecoIgualSequencia -- Saida que indica se "A = B"
    );

  CompJog: comparador_85
    port map (
        i_A3   => s_dado(3),
        i_B3   => s_jogada(3),
        i_A2   => s_dado(2),
        i_B2   => s_jogada(2),
        i_A1   => s_dado(1),
        i_B1   => s_jogada(1),
        i_A0   => s_dado(0),
        i_B0   => s_jogada(0),
        i_AGTB => '0',
        i_ALTB => '0',
        i_AEQB => '1', -- Pré estabelece relação de igualdade entre "A" e "B"
        o_AGTB => open,
        o_ALTB => open,
        o_AEQB => chavesIgualMemoria -- Saida que indica se "A = B"
    );

  -- memoria: ram_16x4  -- usar para Quartus
  MemJog: entity work.ram_16x4(ram_modelsim) -- usar para ModelSim
    port map (
       clk          => clock,
       endereco     => s_endereco,
       dado_entrada => s_jogada,
       we           => s_not_escreve, -- we ativo baixo
       ce           => '0',
       dado_saida   => s_dado
    );

  RegBotoes: registrador_173 
    port map (
       clock => clock,
       clear => limpaR,
       en1   => s_not_registraR,
       en2   => '0',
       D     => botoes,
       Q     => s_jogada
    );

  RegMem: registrador_173 
    port map (
       clock => clock,
       clear => limpaM,
       en1   => s_not_registraM,
       en2   => '0',
       D     => s_dado,
       Q     => db_memoria
    );

  contadorM: contador_m
    -- generic map para caso quiser mudar o tempo
	port map (
        clock   => clock,
        zera_as => zeraTMR,
		zera_s  => zeraTMR,
        conta   => contaTMR,
        Q       => open,
        fim     => fimTMR,
		meio    => open
    );

  edgeDetector: edge_detector 
    port map (
       clock => clock,
       reset => limpaR,
       sinal => s_temJogada,
       pulso => temJogada
    ); 

  db_contagem   <= s_endereco;  -- Para debbug: valor da contagem (valor do endereco da memoria)
  db_sequencia  <= s_sequencia; -- Para debbug: valor da sequência (valor do dado acessado)
  db_temjogada  <= s_temJogada; -- Para debbug: informa se alguma chave foi acionada
  db_jogada     <= s_jogada;    -- Para debbug: informa qual chave foi acionada

end estrutural;
