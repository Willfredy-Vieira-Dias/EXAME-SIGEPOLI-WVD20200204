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

-- =============================================================================
-- # TRIGGER PARA AUDITAR OS PAGAMENTOS #
--
-- Descrição: Este trigger é disparado automaticamente APÓS cada nova
--            inserção na tabela Pagamento. O seu objetivo é criar um
--            registo de log na tabela Auditoria.
--
-- Evento: AFTER INSERT ON Pagamento
-- =============================================================================

DELIMITER $$

CREATE TRIGGER `trg_auditoria_pagamentos`
AFTER INSERT ON `Pagamento`
FOR EACH ROW
BEGIN
    -- Declaração de variáveis para a descrição
    DECLARE v_razao_social VARCHAR(255);

    -- Obter a razão social da empresa para a descrição do log
    SELECT et.razao_social INTO v_razao_social
    FROM Empresa_Terceirizada et
    JOIN Contrato c ON et.id_empresa = c.id_empresa
    WHERE c.id_contrato = NEW.id_contrato;

    -- Inserir o registo na tabela de auditoria
    INSERT INTO Auditoria (
        tabela_afetada,
        id_registo_afetado,
        tipo_operacao,
        descricao,
        utilizador
    )
    VALUES (
        'Pagamento',
        NEW.id_pagamento, -- 'NEW' refere-se à nova linha que foi inserida
        'INSERT',
        CONCAT('Pagamento processado para a empresa "', v_razao_social, '". Valor pago: ', FORMAT(NEW.valor_pago, 2, 'de_DE'), ' Kz.'),
        USER() -- Função do MySQL que retorna o utilizador da sessão atual
    );
END$$

DELIMITER ;

-- =============================================================================
-- # TRIGGER PARA BLOQUEIO AUTOMÁTICO DE PAGAMENTO SEM GARANTIA (RN04) #
--
-- Descrição: Este trigger é disparado automaticamente ANTES de cada nova
--            inserção na tabela Pagamento. Ele implementa a RN04,
--            verificando se a garantia do contrato associado ainda é válida.
--            Se a garantia estiver expirada, a operação é cancelada.
--
-- Evento: BEFORE INSERT ON Pagamento
-- =============================================================================

DELIMITER $$

CREATE TRIGGER `trg_bloquear_pagamento_sem_garantia`
BEFORE INSERT ON `Pagamento`
FOR EACH ROW
BEGIN
    -- Declaração de variável para guardar a data de validade da garantia
    DECLARE v_data_validade_garantia DATE;

    -- Obter a data de validade da garantia do contrato correspondente
    SELECT data_validade_garantia INTO v_data_validade_garantia
    FROM Contrato
    WHERE id_contrato = NEW.id_contrato; -- NEW refere-se à linha que está a TENTAR ser inserida

    -- Verificar se a data de validade da garantia é anterior à data atual
    IF v_data_validade_garantia < CURDATE() THEN
        -- Se a garantia expirou, cancela a operação de INSERT
        -- e lança uma mensagem de erro personalizada.
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO (RN04): Pagamento bloqueado. A garantia do contrato associado expirou.';
    END IF;
    -- Se a condição do IF não for satisfeita, o trigger termina sem fazer nada,
    -- e a operação de INSERT prossegue normalmente.
END$$

DELIMITER ;