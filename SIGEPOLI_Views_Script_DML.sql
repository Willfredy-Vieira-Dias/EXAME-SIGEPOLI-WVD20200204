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