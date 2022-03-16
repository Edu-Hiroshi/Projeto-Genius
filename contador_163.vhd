------------------------------------------------------------------
-- Arquivo   : contador_163.vhd (Copia de "Projeto_1")
-- Projeto   : Experiencia 01 - Primeiro Contato com VHDL
------------------------------------------------------------------
-- Descricao : contador binario hexadecimal (modulo 16) 
--             similar ao CI 74163
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     29/12/2020  1.0     Edson Midorikawa  criacao
--     07/01/2022  2.0     Edson Midorikawa  revisao do componente
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_163 is
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
end contador_163;

architecture comportamental of contador_163 is
    signal IQ: integer range 0 to 15; -- Declaração do sinal interno de contagem
begin
  
    -- contagem
    process (clock)
    begin
    
        if clock'event and clock='1' then -- Se o clock altera o sinal para 1 (1)
            if clr='0' then   IQ <= 0;    -- Se o clear foi ativado (Ativo baixo), zera a contagem (2)
            elsif ld='0' then IQ <= to_integer(unsigned(D)); -- Se o load foi ativado (Ativo baixo), atrubui valor de D para o contador
            elsif ent='1' and enp='1' then -- Se ent e enp estiverem ativados simultâneamente
                if IQ=15 then IQ <= 0;  -- Se a contagem já atingiu 15, a contagem é zerada (3)
                else          IQ <= IQ + 1; -- senão, incrementa a contagem
                end if; -- Fim do if 3
            else              IQ <= IQ; -- senão, mantém contagem anterior
            end if; -- Fim do if 2
        end if; -- Fim do if 1

    end process;

    -- saida rco
    rco <= '1' when IQ=15 and ent='1' else -- rco recebe 1 no final da contagem, com ent ativo alto
           '0'; -- senão, recebe 0

    -- saida Q
    Q <= std_logic_vector(to_unsigned(IQ, Q'length)); -- Saida Q recebe o valor do contador convertido para vetor binário

end comportamental;
