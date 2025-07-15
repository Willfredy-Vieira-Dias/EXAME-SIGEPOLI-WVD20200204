-- =============================================================================
-- Script que contém as VIEWS para o Banco de Dados SIGEPOLI
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
-- # VIEW QUE APRESENTA A GRADE HORÁRIA POR CURSO #
--
-- Descrição: Esta view cria uma tabela virtual que apresenta a grade horária
--            completa para todos os cursos, juntando informações de várias
--            tabelas para uma consulta simplificada.
-- =============================================================================

-- CREATE OR REPLACE VIEW: Cria a view se ela não existir, ou substitui-a se já existir.
-- Isto é útil para fazer ajustes sem precisar de apagar a view manualmente.
CREATE OR REPLACE VIEW `vw_grade_horaria_curso` AS
SELECT
    c.nome AS nome_curso,
    t.ano_letivo,
    t.semestre,
    d.nome AS nome_disciplina,
    -- Usamos GROUP_CONCAT para o caso de uma turma ter mais de um professor
    GROUP_CONCAT(DISTINCT CONCAT(col.primeiro_nome, ' ', col.ultimo_nome) SEPARATOR ', ') AS professores,
    h.dia_semana,
    h.hora_inicio,
    h.hora_fim,
    t.sala
FROM
    Curso c
    -- Junta Curso com Disciplina para obter as disciplinas de cada curso
    JOIN Disciplina d ON c.id_curso = d.id_curso
    -- Junta Disciplina com Turma para obter as turmas de cada disciplina
    JOIN Turma t ON d.id_disciplina = t.id_disciplina
    -- Junta Turma com Horario para obter os horários de cada turma
    JOIN Horario h ON t.id_turma = h.id_turma
    -- Junta Turma com a tabela associativa Professor_Turma
    LEFT JOIN Professor_Turma pt ON t.id_turma = pt.id_turma
    -- Junta Professor_Turma com Colaborador para obter o nome do professor
    LEFT JOIN Colaborador col ON pt.id_professor = col.id_colaborador
GROUP BY
    c.nome, t.ano_letivo, t.semestre, d.nome, h.dia_semana, h.hora_inicio, h.hora_fim, t.sala
ORDER BY
    c.nome, t.ano_letivo, t.semestre, h.dia_semana, h.hora_inicio;
    
-- =============================================================================
-- # VIEW QUE APRESENTA A CARGA HORÁRIA DO PROFESSOR #
--
-- Descrição: Esta view calcula a carga horária total de aulas atribuída a
--            cada professor, somando a carga horária das disciplinas
--            que ele leciona.
-- =============================================================================

CREATE OR REPLACE VIEW `vw_carga_horaria_professor` AS
SELECT
    col.id_colaborador,
    CONCAT(col.primeiro_nome, ' ', col.ultimo_nome) AS nome_professor,
    d.nome AS nome_departamento,
    -- Soma a carga horária de todas as disciplinas que o professor leciona
    SUM(disc.carga_horaria_total) AS carga_horaria_total_atribuida,
    -- Conta o número de turmas distintas que o professor tem
    COUNT(DISTINCT pt.id_turma) AS numero_de_turmas
FROM
    Colaborador col
    -- Filtra para garantir que estamos a olhar apenas para professores
    JOIN Professor_Turma pt ON col.id_colaborador = pt.id_professor
    -- Junta com Turma para obter a disciplina
    JOIN Turma t ON pt.id_turma = t.id_turma
    -- Junta com Disciplina para obter a carga horária
    JOIN Disciplina disc ON t.id_disciplina = disc.id_disciplina
    -- Junta com Departamento para obter o nome do departamento do professor
    JOIN Departamento d ON col.id_departamento = d.id_departamento
WHERE
    col.tipo = 'Professor'
GROUP BY
    col.id_colaborador, nome_professor, nome_departamento
ORDER BY
    carga_horaria_total_atribuida DESC;
    
-- =============================================================================
-- # VIEW QUE APRESENTA O RESUMO DE CUSTOS DE SERVIÇOS POR MÊS #
--
-- Descrição: Esta view cria um relatório financeiro que resume os custos
--            mensais com empresas terceirizadas, agrupados por tipo de
--            serviço (Limpeza, Segurança, Cafetaria).
-- =============================================================================

CREATE OR REPLACE VIEW `vw_resumo_custos_servicos` AS
SELECT
    p.ano_referencia,
    p.mes_referencia,
    et.tipo_servico,
    -- Soma o valor total pago para aquele tipo de serviço naquele mês
    SUM(p.valor_pago) AS total_pago,
    -- Soma o total de multas aplicadas para referência
    SUM(p.valor_multa) AS total_multas,
    -- Conta quantos pagamentos foram feitos para aquele serviço no mês
    COUNT(p.id_pagamento) AS numero_de_pagamentos
FROM
    Pagamento p
    -- Junta com Contrato para obter a referência da empresa
    JOIN Contrato c ON p.id_contrato = c.id_contrato
    -- Junta com Empresa_Terceirizada para obter o tipo de serviço
    JOIN Empresa_Terceirizada et ON c.id_empresa = et.id_empresa
GROUP BY
    p.ano_referencia,
    p.mes_referencia,
    et.tipo_servico
ORDER BY
    p.ano_referencia DESC,
    p.mes_referencia DESC,
    et.tipo_servico;