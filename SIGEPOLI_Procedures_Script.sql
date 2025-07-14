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

-- =============================================================================
-- # PROCEDURE PARA MATRICULAR UM ALUNO #
-- =============================================================================
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

-- =============================================================================
-- # PROCEDURE PARA ALOCAR PROFESSOR #
-- =============================================================================

DELIMITER $$

CREATE PROCEDURE `sp_alocar_professor`(
    IN p_id_professor INT,
    IN p_id_turma_nova INT
)
BEGIN
    -- Variável para detetar se existe conflito. 0 = Não, 1 = Sim.
    DECLARE v_conflito_horario INT DEFAULT 0;

    -- O CURSOR vai iterar sobre cada bloco de horário da NOVA turma à qual queremos alocar o professor.
    -- Para cada horário, vamos verificar se ele entra em conflito com algum horário que o professor JÁ TEM.
    DECLARE v_dia_semana_nova ENUM('Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado');
    DECLARE v_hora_inicio_nova TIME;
    DECLARE v_hora_fim_nova TIME;

    -- Variável de controlo para o loop do cursor
    DECLARE done INT DEFAULT FALSE;

    -- Declaração do Cursor
    DECLARE cur_horarios_nova_turma CURSOR FOR
        SELECT dia_semana, hora_inicio, hora_fim
        FROM Horario
        WHERE id_turma = p_id_turma_nova;

    -- Handler para o fim do cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Abrimos o cursor para começar a iterar
    OPEN cur_horarios_nova_turma;

    -- Loop para percorrer cada horário da nova turma
    read_loop: LOOP
        FETCH cur_horarios_nova_turma INTO v_dia_semana_nova, v_hora_inicio_nova, v_hora_fim_nova;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Para cada horário da nova turma, verificamos se existe um conflito
        -- com os horários que o professor já tem.
        SELECT COUNT(*)
        INTO v_conflito_horario
        FROM Professor_Turma pt
        JOIN Horario h ON pt.id_turma = h.id_turma
        WHERE
            pt.id_professor = p_id_professor
            AND h.dia_semana = v_dia_semana_nova
            -- A lógica de sobreposição de tempo:
            -- O novo horário começa durante um horário existente OU
            -- O novo horário termina durante um horário existente OU
            -- O novo horário "engole" completamente um horário existente.
            AND (
                (v_hora_inicio_nova >= h.hora_inicio AND v_hora_inicio_nova < h.hora_fim) OR
                (v_hora_fim_nova > h.hora_inicio AND v_hora_fim_nova <= h.hora_fim) OR
                (v_hora_inicio_nova <= h.hora_inicio AND v_hora_fim_nova >= h.hora_fim)
            );

        -- Se encontrámos um conflito (COUNT > 0), podemos parar de verificar.
        IF v_conflito_horario > 0 THEN
            LEAVE read_loop;
        END IF;

    END LOOP;

    -- Fechamos o cursor pois já não precisamos mais dele
    CLOSE cur_horarios_nova_turma;

    -- Verificação final
    IF v_conflito_horario > 0 THEN
        -- Se a variável de conflito for maior que 0, significa que encontrámos uma sobreposição.
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Alocação falhou. O professor já tem um horário sobreposto.';
    ELSE
        -- Se não houve conflitos, podemos inserir com segurança.
        INSERT INTO Professor_Turma (id_professor, id_turma) VALUES (p_id_professor, p_id_turma_nova);
        SELECT 'SUCESSO: Professor alocado à turma com sucesso.' AS resultado;
    END IF;

END$$

DELIMITER ; 