-- =============================================================================
-- Script que contém as CONSULTAS DE TESTE para o Banco de Dados SIGEPOLI
-- Projecto: SIGEPOLI
-- Disciplina / Cadeira: Base de Dados II
-- Autor: Willfredy Vieira Dias
-- Número de Estudante: 20200204
-- Docente: Judson Paiva
-- Versão: 1.0
-- =============================================================================

USE `SIGEPOLI`;

-- =============================================================================
-- # SCRIPT PARA CONSULTAS DE TESTES
--
-- Descrição: Este script contém mais de 15 consultas SELECT para testar
--            a lógica da base de dados e demonstrar que as Regras de
--            Negócio (RN) estão a ser cumpridas.
-- =============================================================================

-- === Demonstração de Regras de Negócio (RN) e Lógica ===

-- Consulta 1: (Demonstra RN02) Listar todos os alunos com propinas pendentes.
-- Útil para a secretaria saber quem não pode realizar matrículas.
SELECT id_aluno, primeiro_nome, ultimo_nome, email
FROM Aluno
WHERE status_propina = 'Pendente';

-- Consulta 2: (Demonstra RN02) Verificar a capacidade atual das turmas.
-- Mostra as vagas totais, quantos alunos já estão matriculados e quantas vagas restam.
SELECT
    t.id_turma,
    d.nome AS disciplina,
    t.vagas AS vagas_totais,
    COUNT(m.id_matricula) AS matriculados,
    (t.vagas - COUNT(m.id_matricula)) AS vagas_restantes
FROM Turma t
JOIN Disciplina d ON t.id_disciplina = d.id_disciplina
LEFT JOIN Matricula m ON t.id_turma = m.id_turma
GROUP BY t.id_turma, d.nome, t.vagas;

-- Consulta 3: (Demonstra RN01 e RN06) Usar a View para ver a carga horária de um professor específico.
-- O coordenador pode usar isto para verificar a carga horária dos professores do seu curso.
SELECT * FROM vw_carga_horaria_professor WHERE id_colaborador = 1;

-- Consulta 4: (Demonstra RN04) Listar todos os contratos e verificar a validade das suas garantias.
-- Mostra quais garantias estão válidas e quais expiraram.
SELECT
    c.id_contrato,
    et.razao_social,
    c.data_validade_garantia,
    IF(c.data_validade_garantia >= CURDATE(), 'Válida', 'EXPIRADA') AS status_garantia
FROM Contrato c
JOIN Empresa_Terceirizada et ON c.id_empresa = et.id_empresa;

-- Consulta 5: (Demonstra RN05) Mostrar todos os pagamentos em que foi aplicada uma multa por baixo SLA.
SELECT
    p.id_pagamento,
    et.razao_social,
    p.mes_referencia,
    p.ano_referencia,
    p.percentual_sla_apurado,
    p.valor_multa
FROM Pagamento p
JOIN Contrato c ON p.id_contrato = c.id_contrato
JOIN Empresa_Terceirizada et ON c.id_empresa = et.id_empresa
WHERE p.valor_multa > 0;

-- Consulta 6: (Demonstra RN03) Verificar se todas as notas na base de dados cumprem a regra 0-20.
-- Se esta consulta retornar alguma linha, há um problema. (Não deve retornar nada).
SELECT * FROM Avaliacao WHERE nota < 0 OR nota > 20;


-- === Consultas Ad-Hoc Adicionais para Teste e Relatórios ===

-- Consulta 7: Gerar uma pauta final para a disciplina de "Base de Dados II" (ID 1), usando a nossa função.
SELECT
    a.primeiro_nome,
    a.ultimo_nome,
    fn_calcular_media_ponderada(a.id_aluno, 1) AS media_final,
    IF(fn_calcular_media_ponderada(a.id_aluno, 1) >= 9.5, 'Aprovado', 'Reprovado') AS resultado_final
FROM Aluno a
JOIN Matricula m ON a.id_aluno = m.id_aluno
JOIN Turma t ON m.id_turma = t.id_turma
WHERE t.id_disciplina = 1;

-- Consulta 8: Usar a View para ver a grade horária completa do curso de "Engenharia Informática".
SELECT nome_disciplina, professores, dia_semana, hora_inicio, hora_fim, sala
FROM vw_grade_horaria_curso
WHERE nome_curso = 'Engenharia Informática';

-- Consulta 9: Usar a View para ver o resumo de custos de serviços para o mês 2 de 2025.
SELECT tipo_servico, total_pago, total_multas
FROM vw_resumo_custos_servicos
WHERE ano_referencia = 2025 AND mes_referencia = 2;

-- Consulta 10: Listar todos os professores com a titulação de 'PhD'.
SELECT primeiro_nome, ultimo_nome, email, titulacao
FROM Colaborador
WHERE tipo = 'Professor' AND titulacao LIKE '%PhD%';

-- Consulta 11: Encontrar todos os alunos matriculados na turma de "Base de Dados II" (ID da Turma 1).
SELECT a.primeiro_nome, a.ultimo_nome, a.email
FROM Aluno a
JOIN Matricula m ON a.id_aluno = m.id_aluno
WHERE m.id_turma = 1;

-- Consulta 12: Mostrar os detalhes de um contrato específico e da empresa associada.
SELECT
    c.id_contrato,
    et.razao_social,
    et.nif,
    et.tipo_servico,
    c.data_inicio,
    c.data_fim,
    c.valor_mensal
FROM Contrato c
JOIN Empresa_Terceirizada et ON c.id_empresa = et.id_empresa
WHERE c.id_contrato = 1;

-- Consulta 13: Listar todos os registos de auditoria relacionados com 'Pagamento'.
SELECT id_log, descricao, utilizador, data_hora
FROM Auditoria
WHERE tabela_afetada = 'Pagamento';

-- Consulta 14: Encontrar o departamento com o maior orçamento anual.
SELECT nome, orcamento_anual
FROM Departamento
ORDER BY orcamento_anual DESC
LIMIT 1;

-- Consulta 15: Contar quantos cursos cada coordenador está a gerir (deve ser sempre 1 no nosso modelo).
SELECT
    CONCAT(c.primeiro_nome, ' ', c.ultimo_nome) AS nome_coordenador,
    COUNT(cu.id_curso) AS numero_de_cursos
FROM Colaborador c
JOIN Curso cu ON c.id_colaborador = cu.id_coordenador
GROUP BY c.id_colaborador;

-- Consulta 16: Listar todas as disciplinas de um curso específico ('Engenharia Mecânica').
SELECT nome, carga_horaria_total
FROM Disciplina
WHERE id_curso = (SELECT id_curso FROM Curso WHERE nome = 'Engenharia Mecânica');

-- Consulta 17: Mostrar o histórico de SLA de um contrato específico (Contrato 1).
SELECT mes_referencia, ano_referencia, percentual_sla_apurado
FROM Pagamento
WHERE id_contrato = 1
ORDER BY ano_referencia, mes_referencia;