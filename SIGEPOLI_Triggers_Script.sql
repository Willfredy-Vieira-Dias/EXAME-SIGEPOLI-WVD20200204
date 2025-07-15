-- =============================================================================
-- Script DML (INSERTs) para o Banco de Dados SIGEPOLI
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
-- # TRIGGER PARA AUDITAR AS MATRICULAS #
--
-- Descrição: Este trigger é disparado automaticamente APÓS cada nova
--            inserção na tabela Matricula. O seu objetivo é criar um
--            registo de log na tabela Auditoria.
--
-- Evento: AFTER INSERT ON Matricula
-- =============================================================================

DELIMITER $$

CREATE TRIGGER `trg_auditoria_matriculas`
AFTER INSERT ON `Matricula`
FOR EACH ROW
BEGIN
    -- Declaração de variáveis para tornar a descrição mais legível
    DECLARE v_nome_aluno VARCHAR(200);
    DECLARE v_nome_disciplina VARCHAR(150);

    -- Obter o nome do aluno e da disciplina para a descrição do log
    SELECT CONCAT(a.primeiro_nome, ' ', a.ultimo_nome) INTO v_nome_aluno
    FROM Aluno a WHERE a.id_aluno = NEW.id_aluno;

    SELECT d.nome INTO v_nome_disciplina
    FROM Disciplina d
    JOIN Turma t ON d.id_disciplina = t.id_disciplina
    WHERE t.id_turma = NEW.id_turma;

    -- Inserir o registo na tabela de auditoria
    INSERT INTO Auditoria (
        tabela_afetada,
        id_registo_afetado,
        tipo_operacao,
        descricao,
        utilizador
        -- data_hora é preenchida por DEFAULT
    )
    VALUES (
        'Matricula',
        NEW.id_matricula, -- 'NEW' refere-se à nova linha que foi inserida
        'INSERT',
        CONCAT('Nova matrícula realizada: Aluno "', v_nome_aluno, '" inscrito na disciplina "', v_nome_disciplina, '".'),
        USER() -- USER() é uma função do MySQL que retorna o utilizador da sessão atual
    );
END$$

DELIMITER ;