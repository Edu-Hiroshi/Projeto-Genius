------------------------------------------------------------------
-- Arquivo   : circuito_exp5.vhd
-- Projeto   : Experiencia 5
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     11/02/2022  1.0     Henrique Matheus  versao inicial
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity circuito_exp5 is
    port (
    clock          : in std_logic;
    reset          : in std_logic;
    iniciar        : in std_logic;
    botoes         : in std_logic_vector(3 downto 0);
    leds           : out std_logic_vector(3 downto 0);
    pronto         : out std_logic;
    ganhou         : out std_logic;
    perdeu         : out std_logic;
    -- Sinais de depuração
    db_contagem    : out std_logic_vector (6 downto 0);
    db_memoria     : out std_logic_vector (6 downto 0);
    db_sequencia   : out std_logic_vector (6 downto 0);
    db_estado      : out std_logic_vector (6 downto 0);
    db_jogadafeita : out std_logic_vector (6 downto 0);
    db_EndIgualSeq : out std_logic;
    db_JogIgualMem : out std_logic
    );
end entity;

architecture estrutural of circuito_exp5 is
    signal s_contaS, s_zeraS, s_contaE, s_zeraE, s_escreve, s_registraR, s_limpaR, s_contaTMR, s_zeraTMR, s_registraM, s_limpaM : std_logic; 
    signal s_EndMenorOuIgualSeq, s_EndIgualSeq, s_fimTMR, s_fimS, s_fimE, S_JogIgualMem, s_temJogada, s_db_temJogada : std_logic; 
    signal s_sequencia, s_contagem, s_memoria, s_jogada: std_logic_vector (3 downto 0);
    signal s_estado: std_logic_vector (4 downto 0);

    -- Fluxo de dados
    component fluxo_dados is
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
     end component;

    -- Unidade de controle
    component unidade_controle is 
        port ( 
            clock                  : in  std_logic; 
            reset                  : in  std_logic; 
            iniciar                : in  std_logic;
            fimS                   : in  std_logic;
            enderecoIgualSequencia : in  std_logic;
            chavesIgualMemoria     : in  std_logic;
            fimTMR                 : in  std_logic;
            fezJogada              : in  std_logic;
            contaS                 : out std_logic;
            zeraS                  : out std_logic;
            contaE                 : out std_logic;
            zeraE                  : out std_logic;
            registraR              : out std_logic;
            limpaR                 : out std_logic;
            registraM              : out std_logic;
            limpaM                 : out std_logic;
            contaTMR               : out std_logic;
            zeraTMR                : out std_logic;
            pronto                 : out std_logic;
            ganhou                 : out std_logic;
            perdeu                 : out std_logic;
            db_estado              : out std_logic_vector(4 downto 0)
        );
    end component;

    -- Decodificador hexadecimal para display de 7 segmentos
    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Decodificador hexadecimal para display de 7 segmentos para os estados
    component estado7seg is
        port (
            estado : in  std_logic_vector(4 downto 0);
            sseg   : out std_logic_vector(6 downto 0)
        );
    end component;

begin
    fd: fluxo_dados
    port map (
        clock     => clock,
        contaS    => s_contaS,
        zeraS     => s_zeraS,
        contaE    => s_contaE,
        zeraE     => s_zeraE,
        escreve   => s_escreve,
        botoes    => botoes,
        registraR => s_registraR,
        limpaR    => s_limpaR,
        contaTMR  => s_contaTMR,
        zeraTMR   => s_zeraTMR,
        registraM => s_registraM,
        limpaM    => s_limpaM,
        enderecoMenorOuIgualSequencia => s_EndMenorOuIgualSeq,
        enderecoIgualSequencia        => s_EndIgualSeq,
        fimTMR                        => s_fimTMR,
        fimS                          => s_fimS,
        fimE                          => s_fimE,
        chavesIgualMemoria            => S_JogIgualMem,
        temJogada                     => s_temJogada,
        db_temjogada                  => s_db_temJogada,
        db_sequencia                  => s_sequencia,
        db_contagem                   => s_contagem,
        db_memoria                    => s_memoria,
        db_jogada                     => s_jogada
    );

    uc: unidade_controle
    port map (
        clock                  => clock,
        reset                  => reset, 
        iniciar                => iniciar,
        fimS                   => s_fimS,
        enderecoIgualSequencia => s_EndIgualSeq,
        chavesIgualMemoria     => S_JogIgualMem,
        fimTMR                 => s_fimTMR,
        fezJogada              => s_temJogada,
        contaS                 => s_contaS,
        zeraS                  => s_zeraS,
        contaE                 => s_contaE,
        zeraE                  => s_zeraE,
        registraR              => s_registraR,
        limpaR                 => s_limpaR,
        registraM              => s_registraM,
        limpaM                 => s_limpaM,
        contaTMR               => s_contaTMR,
        zeraTMR                => s_zeraTMR,
        pronto                 => pronto,
        ganhou                 => ganhou,
        perdeu                 => perdeu,
        db_estado              => s_estado
    );

    hexCont: hexa7seg
    port map (
        hexa => s_contagem,
        sseg => db_contagem
    );

    hexMem: hexa7seg
    port map (
        hexa => s_memoria,
        sseg => db_memoria
    );

    hexJog: hexa7seg
    port map (
        hexa => s_jogada,
        sseg => db_jogadafeita
    );

    hexSeq: hexa7seg
    port map (
        hexa => s_sequencia,
        sseg => db_sequencia
    );

    hexEst: estado7seg
    port map (
        estado => s_estado,
        sseg   => db_estado
    );

    leds <= s_memoria;
    db_EndIgualSeq <= s_EndIgualSeq;
    db_JogIgualMem <= s_JogIgualMem;
end architecture;
   
