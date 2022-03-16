-----------------------------------------------------------------
-- Arquivo   : registrador_173.vhd
-- Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle
-----------------------------------------------------------------
-- Descricao : registrador de 4 bits
--             similar ao CI 74173
-----------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     18/01/2022  1.0     Edson Midorikawa  versao inicial
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity registrador_173 is
    port (
        clock : in  std_logic;
        clear : in  std_logic;
        en1   : in  std_logic;
        en2   : in  std_logic;
        D     : in  std_logic_vector (3 downto 0);
        Q     : out std_logic_vector (3 downto 0)
   );
end entity registrador_173;

architecture comportamental of registrador_173 is
begin
  
    process (clock, clear)
    begin
        if clear='1' then -- Clear assíncrono ativo alto
            Q <= "0000";  -- Zera saída
        elsif clock'event and clock='1' then -- Na borda de subida
            if en1='0' and en2='0'then  -- Se ambos os enables estiverem em 0 (Ativos baixo)
                Q <= D; -- Saída recebe valor da entrada D
            end if;
        end if;
    end process;

    -- Caso as condições acima não forem atendidas, a saída se manterá constante

end architecture comportamental;
