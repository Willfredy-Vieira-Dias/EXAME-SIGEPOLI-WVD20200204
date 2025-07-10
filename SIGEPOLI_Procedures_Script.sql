-- =============================================================================
-- Script que contém os PROCEDURES do Banco de Dados SIGEPOLI
-- Projecto: SIGEPOLI
-- Disciplina / Cadeira: Base de Dados II
-- Autor: Willfredy Vieira Dias
-- Número de Estudante: 20200204
-- Docente: Judson Paiva
-- Versão: 1.0
--
-- Descrição: Esta procedure realiza a matrícula de um aluno numa turma,
-- implementando a Regra de Negócio RN02.
--
-- Regra de Negócio (RN02):
-- 1. Verifica se a turma tem vagas disponíveis.
-- 2. Verifica se o aluno tem a propina paga.
-- 3. Se ambas as condições forem verdadeiras, insere o registo na tabela Matricula.
-- 4. Retorna uma mensagem de sucesso ou de erro.
-- =============================================================================

-- Usar a base de dados correta
USE `SIGEPOLI`;

-- O DELIMITER é usado para mudar o finalizador de comando padrão (;)
-- para que possamos usar ; dentro da nossa procedure sem que o script termine prematuramente.
DELIMITER $$

CREATE PROCEDURE `sp_matricular_aluno`(
    IN p_id_aluno INT,
    IN p_id_turma INT
)
BEGIN
    -- Declaração de variáveis para guardar os dados que vamos consultar
    DECLARE v_vagas_disponiveis INT;
    DECLARE v_total_matriculados INT;
    DECLARE v_status_propina ENUM('Paga', 'Pendente');
    DECLARE v_aluno_ja_matriculado INT;

    -- 1. Verificar se o aluno já está matriculado nesta turma para evitar erros de chave duplicada
    SELECT COUNT(*)
    INTO v_aluno_ja_matriculado
    FROM Matricula
    WHERE id_aluno = p_id_aluno AND id_turma = p_id_turma;

    IF v_aluno_ja_matriculado > 0 THEN
        -- Se o aluno já está matriculado, sinalizamos o erro e terminamos
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERRO: Aluno já se encontra matriculado nesta turma.';
    ELSE
        -- 2. Obter o número de vagas da turma e o total de alunos já matriculados
        SELECT vagas INTO v_vagas_disponiveis FROM Turma WHERE id_turma = p_id_turma;
        SELECT COUNT(*) INTO v_total_matriculados FROM Matricula WHERE id_turma = p_id_turma;

        -- 3. Verificar se ainda existem vagas
        IF (v_vagas_disponiveis > v_total_matriculados) THEN
            -- Se há vagas, vamos verificar o status da propina do aluno
            SELECT status_propina INTO v_status_propina FROM Aluno WHERE id_aluno = p_id_aluno;

            -- 4. Verificar se a propina está 'Paga'
            IF (v_status_propina = 'Paga') THEN
                -- Se ambas as condições são verdadeiras, realiza a matrícula
                INSERT INTO Matricula (id_aluno, id_turma) VALUES (p_id_aluno, p_id_turma);

                -- Retorna uma mensagem de sucesso.
                SELECT 'SUCESSO: Aluno matriculado com sucesso.' AS resultado;
            ELSE
                -- Se a propina não está paga, sinaliza o erro específico
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERRO: Matrícula não permitida. A propina encontra-se pendente.';
            END IF;
        ELSE
            -- Se não há vagas, sinaliza o erro específico
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERRO: Matrícula não permitida. A turma não possui vagas disponíveis.';
        END IF;
    END IF;

END$$

-- Voltamos a definir o delimitador padrão como ;
DELIMITER ;