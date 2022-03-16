--------------------------------------------------------------------
-- Arquivo   : unidade_controle.vhd
-- Projeto   : Experiencia 5 - Projeto de uma unidade de controle
--------------------------------------------------------------------
-- Descricao : unidade de controle 
--
--             1) codificação VHDL (maquina de Moore)
--
--             2) definicao de valores da saida de depuracao
--                db_estado
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     11/02/2022  1.0     Henrique Matheus  versao inicial
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity unidade_controle is 
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
end entity;

architecture fsm of unidade_controle is
    -- Declaração dos estados
    type t_estado is (inicial, preparacaoGeral, acerto, erro,                                   -- Estados gerais
                      verificaSequencia, proximaSequencia, preparaSequencia,                    -- Controla Sequências
                      carregaDado, mostraDado, zeraLeds, mostraApagado, proximoDado,            -- Mostra Sequência dos leds
                      preparaJogo, esperaJogada, registraJogada, comparaJogada, proximaJogada); -- processa jogadas da sequência
    signal Eatual, Eprox: t_estado;
begin

    -- memoria de estado
    process (clock,reset) -- Processo sensível à mudança do clock e reset
    begin
        if reset='1' then -- Reset possui preferência sobre o clock e é ativo alto
            Eatual <= inicial;
        elsif clock'event and clock = '1' then -- Ocorre na borda de subida do clock
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    -- Aqui foram adicionadas as transicoes entre os novos estados
    Eprox <=
        -- Transições de origem nos estados gerais
        inicial           when Eatual=inicial and iniciar='0' else
        preparacaoGeral   when Eatual=inicial and iniciar='1' else
        preparaSequencia  when Eatual=preparacaoGeral else
        erro              when Eatual=erro and iniciar='0' else -- Mantém no estado final de erro até ser iniciado novamente
        acerto            when Eatual=acerto and iniciar='0' else -- Mantém no estado final de acerto até ser iniciado novamente
        preparacaoGeral   when (Eatual=erro or Eatual=acerto) and iniciar='1' else -- Volta para o estado de preparação após iniciar novamente
        -- Transição de origem dos estados do controle da sequência
        proximaSequencia  when Eatual=verificaSequencia and fimS='0' else
        acerto            when Eatual=verificaSequencia and fimS='1' else
        preparaSequencia  when Eatual=proximaSequencia else
        carregaDado       when Eatual=preparaSequencia else
        -- Transição de origem dos estados que mostram a sequencia dos leds
        mostraDado        when Eatual=carregaDado else
        mostraDado        when Eatual=mostraDado and fimTMR='0' else
        zeraLeds          when Eatual=mostraDado and fimTMR='1' else
        mostraApagado     when Eatual=zeraLeds else
        mostraApagado     when Eatual=mostraApagado and fimTMR='0' else
        proximoDado       when Eatual=mostraApagado and fimTMR='1' and enderecoIgualSequencia='0' else
        preparaJogo       when Eatual=mostraApagado and fimTMR='1' and enderecoIgualSequencia='1' else
        carregaDado       when Eatual=proximoDado else
        -- Transição de origem dos estados que mostram a sequencia dos leds
        esperaJogada      when Eatual=preparaJogo else
        esperaJogada      when Eatual=esperaJogada and fezJogada='0' else
        registraJogada    when Eatual=esperaJogada and fezJogada='1' else
        comparaJogada     when Eatual=registraJogada else
        erro              when Eatual=comparaJogada and chavesIgualMemoria='0' else
        verificaSequencia when Eatual=comparaJogada and chavesIgualMemoria='1' and enderecoIgualSequencia='1' else
        proximaJogada     when Eatual=comparaJogada and chavesIgualMemoria='1' and enderecoIgualSequencia='0' else
        esperaJogada      when Eatual=proximaJogada else
        -- Estado padrão
        inicial;

    -- logica de saída (maquina de Moore)
    -- As saídas correspondentes recebem 1 nos estados declarados, e 0 caso contrário
    with Eatual select
        contaS <=     '1' when proximaSequencia,
                      '0' when others;

    with Eatual select
        zeraS <=      '1' when preparacaoGeral,
                      '0' when others;

    with Eatual select
        contaE <=     '1' when proximoDado | proximaJogada,
                      '0' when others;

    with Eatual select
        zeraE <=      '1' when preparaJogo | PreparaSequencia,
                      '0' when others;
    
    with Eatual select
        registraR <=  '1' when registraJogada,
                      '0' when others;

    with Eatual select
        limpaR <=     '1' when preparacaoGeral,
                      '0' when others;

    with Eatual select
        registraM <=  '1' when carregaDado,
                      '0' when others;

    with Eatual select
        limpaM <=     '1' when preparacaoGeral | zeraLeds,
                      '0' when others;
    
    with Eatual select
        contaTMR <= '1' when mostraDado | mostraApagado,
                    '0' when others;

    with Eatual select
        zeraTMR <=  '1' when carregaDado | zeraleds,
                    '0' when others;

    with Eatual select
        pronto <=   '1' when acerto | erro,
                    '0' when others;

    with Eatual select
        ganhou <=   '1' when acerto,
                    '0' when others;

    with Eatual select
        perdeu <=   '1' when erro,
                    '0' when others;   

    -- saida de depuracao (db_estado)
    -- Adicao da saida para o estado de "esperaJogada"
    with Eatual select
        db_estado <= "00000" when inicial,           -- 0
                     "00010" when preparacaoGeral,   -- 2
                     "00100" when acerto,            -- 4
                     "00110" when erro,              -- 6
                     "01010" when verificaSequencia, -- A
                     "01100" when proximaSequencia,  -- C
                     "01110" when preparaSequencia,  -- E
                     "10000" when carregaDado,       -- 10
                     "10010" when mostraDado,        -- 12
                     "10100" when zeraLeds,          -- 14
                     "10110" when mostraApagado,     -- 16
                     "11000" when proximoDado,       -- 18
                     "11010" when preparaJogo,       -- 1A
                     "11011" when esperaJogada,      -- 1B
                     "11100" when registraJogada,    -- 1C
                     "11101" when comparaJogada,     -- 1D
                     "11110" when proximaJogada,     -- 1E
                     "11111" when others;            -- 1F
end fsm;
