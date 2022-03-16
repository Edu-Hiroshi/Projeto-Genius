--------------------------------------------------------------------------
-- Arquivo   : circuito_exp5_tb.vhd
-- Projeto   : Experiencia 05 - Jogo Base do Desafio da Memoria
--                              
--------------------------------------------------------------------------
-- Descricao : modelo de testbench para simulação com ModelSim
--
--             implementa o Cenário de Teste 1 do Plano de Teste
--             - acerta as 16 jogadas
--             - usa array de casos de teste
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     04/02/2022  1.0     Edson Midorikawa  criacao (adaptado da Exp.4)
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

-- entidade do testbench
entity circuito_exp5_tb is
end entity;

architecture tb of circuito_exp5_tb is

    -- Componente a ser testado (Device Under Test -- DUT)
    component circuito_exp5
        port (
            clock          : in  std_logic;
            reset          : in  std_logic;
            iniciar        : in  std_logic;
            botoes         : in  std_logic_vector(3 downto 0);
            leds           : out std_logic_vector(3 downto 0);
            pronto         : out std_logic;
            ganhou         : out std_logic;
            perdeu         : out std_logic;
            -- Sinais de depuração
            db_contagem    : out std_logic_vector(6 downto 0);
            db_memoria     : out std_logic_vector(6 downto 0);
            db_sequencia   : out std_logic_vector(6 downto 0);
            db_estado      : out std_logic_vector(6 downto 0);
            db_jogadafeita : out std_logic_vector(6 downto 0);
            db_EndIgualSeq : out std_logic;
            db_JogIgualMem : out std_logic
        );
    end component;
  
    ---- Declaracao de sinais de entrada para conectar o componente
    signal clk_in           : std_logic := '0';
    signal rst_in           : std_logic := '0';
    signal iniciar_in       : std_logic := '0';
    signal botoes_in        : std_logic_vector(3 downto 0) := "0000";
    
    ---- Declaracao dos sinais de saida
    signal leds_out         : std_logic_vector(3 downto 0) := "0000";
    signal pronto_out       : std_logic := '0';
    signal ganhou_out       : std_logic := '0';
    signal perdeu_out       : std_logic := '0';
    
    ---- Declaracao das saidas de depuracao
    -- inserir saidas de depuracao do seu projeto
    -- exemplos:
    -- signal estado_out      : std_logic_vector(6 downto 0) := "0000000";
    -- signal clock_out       : std_logic := '0';
    signal db_contagem_out    : std_logic_vector(6 downto 0) := "0000000";
    signal db_memoria_out     : std_logic_vector(6 downto 0) := "0000000";
    signal db_sequencia_out   : std_logic_vector(6 downto 0) := "0000000";
    signal db_estado_out      : std_logic_vector(6 downto 0) := "0000000";
    signal db_jogadafeita_out : std_logic_vector(6 downto 0) := "0000000";
    signal db_EndIgualSeq_out : std_logic := '0';
    signal db_JogIgualMem_out : std_logic := '0';

    -- Array de casos de teste
    type caso_teste_type is record
        id             : natural; 
        jogada_certa   : std_logic_vector (3 downto 0);
        duracao_jogada : integer;     
    end record;
    
    type casos_teste_array is array (natural range <>) of caso_teste_type;
    constant casos_teste : casos_teste_array :=
        (--  id   jogada_certa   duracao_jogada
            ( 0,     "0001",         5),  -- conteudo da ram_16x4
            ( 1,     "0010",        15),  -- 
            ( 2,     "0100",         7),  -- 
            ( 3,     "1000",        20),  -- 
            ( 4,     "0100",        17),  -- 
            ( 5,     "0010",        33),  -- 
            ( 6,     "0001",        18),  -- 
            ( 7,     "0001",        50),  -- 
            ( 8,     "0010",        22),  -- 
            ( 9,     "0010",        11),  -- 
            (10,     "0100",         6),  -- 
            (11,     "0100",        23),  -- 
            (12,     "1000",        29),  -- 
            (13,     "1000",        16),  -- 
            (14,     "0001",        43),  -- 
            (15,     "0100",         9)   -- 
        );

    -- Identificacao de casos de teste
    signal rodada_jogo     : integer := 0;

    -- Configurações do clock
    signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
    constant clockPeriod   : time := 1 ms;     -- frequencia 1 KHz
  
begin
    -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
    -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
    clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
    
    ---- DUT para Casos de Testes 1 e 2
    dut: circuito_exp5
         port map
         (
            clock     =>   clk_in,
            reset     =>   rst_in,
            iniciar   =>   iniciar_in,
            botoes    =>   botoes_in,
            leds      =>   leds_out, 
            pronto    =>   pronto_out,
            ganhou    =>   ganhou_out,
            perdeu    =>   perdeu_out,
            -- acrescentar saidas de depuracao
            db_contagem    => db_contagem_out,
            db_memoria     => db_memoria_out,
            db_sequencia   => db_sequencia_out,
            db_estado      => db_estado_out,
            db_jogadafeita => db_jogadafeita_out,
            db_EndIgualSeq => db_EndIgualSeq_out,
            db_JogIgualMem => db_JogIgualMem_out
         );
    
    ---- Gera sinais de estimulo para a simulacao
    stimulus: process is
    begin  
        -- inicio da simulacao
        assert false report "inicio da simulacao" severity note;
        keep_simulating <= '1';

    ------------------------------------------------------------
    -- Cenario de Teste #1: acerta as todas as 16 rodadas     --
    ------------------------------------------------------------
        --- Teste 1: Resetar circuito por 1 periodo de clock
        rst_in <= '1';
        wait for clockPeriod;
        rst_in <= '0';
	    
        --- Teste 2: Acionar sinal iniciar por 1 periodo de clock
        wait until falling_edge(clk_in);
        -- pulso do sinal de Iniciar
        iniciar_in <= '1';
        wait until falling_edge(clk_in);
        iniciar_in <= '0';
	    
        wait for 10*clockPeriod;

        --- Testes 3 ao 18: Realizar a jogadas certas de cada rodada
        for rodada in 0 to 15 loop
            rodada_jogo <= rodada;
            for jogada in 0 to rodada loop
                -- espera antes da rodada (espera pela apresentacao das jogadas nos leds)
                wait for (rodada+2) * 1 sec;  -- 1 seg/jogada + 1 seg
                -- realiza jogada certa
                botoes_in <= casos_teste(jogada).jogada_certa;
                wait for casos_teste(jogada).duracao_jogada*clockPeriod;
                botoes_in <= "0000";
                -- espera entre jogadas
                wait for 10*clockPeriod;
            end loop;
        end loop;
 
        -- espera depois da jogada final
        wait for 20*clockPeriod;
	    
        ---- final do testbench
        assert false report "fim da simulacao" severity note;
        keep_simulating <= '0';
        
        wait; -- fim da simulação: processo aguarda indefinidamente
    end process;

end architecture;
