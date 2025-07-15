-- =============================================================================
-- Script que contém os PROCEDURES do Banco de Dados SIGEPOLI
-- Projecto: SIGEPOLI
-- Disciplina / Cadeira: Base de Dados II
-- Autor: Willfredy Vieira Dias
-- Número de Estudante: 20200204
-- Docente: Judson Paiva
-- Versão: 1.0
-- =============================================================================

-- Usar a base de dados correta
USE `SIGEPOLI`;

-- =============================================================================
-- # FUNÇÃO PARA CALCULAR A MÉDIA PONDERADA DE UM ALUNO #
--
-- Descrição: Esta função calcula a média ponderada final de um aluno numa
--            determinada disciplina, com base nas notas e pesos registados
--            na tabela Avaliacao.
--
-- Lógica:
-- 1. Recebe como parâmetros o ID do aluno e o ID da disciplina.
-- 2. Encontra a matrícula correspondente do aluno naquela disciplina/turma.
-- 3. Soma o resultado de (nota * peso) para todas as avaliações dessa matrícula.
-- 4. Retorna a média final calculada.
-- =============================================================================

DELIMITER $$

CREATE FUNCTION `fn_calcular_media_ponderada`(
    p_id_aluno INT,
    p_id_disciplina INT
)
RETURNS DECIMAL(5,2) -- A função vai retornar um número decimal com 2 casas (ex: 15.75)
DETERMINISTIC -- Indica que a função sempre retorna o mesmo resultado para os mesmos parâmetros de entrada
BEGIN
    -- Declaração de variáveis
    DECLARE v_media_final DECIMAL(5,2);
    DECLARE v_id_turma INT;
    DECLARE v_id_matricula INT;

    -- Para simplificar, esta função assume que um aluno só está matriculado
    -- numa única turma de uma dada disciplina por semestre.
    -- Primeiro, encontramos a turma ativa da disciplina.
    SELECT id_turma INTO v_id_turma
    FROM Turma
    WHERE id_disciplina = p_id_disciplina
    ORDER BY ano_letivo DESC, semestre DESC
    LIMIT 1;

    -- Depois, encontramos o ID da matrícula específica do aluno nessa turma
    SELECT id_matricula INTO v_id_matricula
    FROM Matricula
    WHERE id_aluno = p_id_aluno AND id_turma = v_id_turma;

    -- Se não houver matrícula, retorna NULL
    IF v_id_matricula IS NULL THEN
        RETURN NULL;
    END IF;

    -- Agora, calculamos a média ponderada somando (nota * peso) para a matrícula encontrada
    SELECT SUM(nota * peso)
    INTO v_media_final
    FROM Avaliacao
    WHERE id_matricula = v_id_matricula;

    -- Retornamos o valor final calculado
    RETURN v_media_final;

END$$

DELIMITER ;