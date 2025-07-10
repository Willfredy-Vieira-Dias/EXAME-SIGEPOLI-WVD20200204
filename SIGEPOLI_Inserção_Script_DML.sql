-- =============================================================================
-- Script DML (INSERTs) para a Base de Dados SIGEPOLI
-- Projeto: Base de Dados II
-- Versão: 1.0
--
-- Descrição: Este script popula as tabelas com dados de teste realistas.
-- IMPORTANTE: Execute este script APENAS APÓS ter executado o script DDL
-- que cria a estrutura das tabelas. A ordem dos INSERTs é crucial
-- devido às chaves estrangeiras.
-- =============================================================================

-- Usar a base de dados correta
USE `SIGEPOLI`;

-- Desativar temporariamente as verificações de chaves estrangeiras para facilitar a inserção em massa
SET FOREIGN_KEY_CHECKS=0;

-- Limpar as tabelas antes de inserir para garantir um estado limpo (ordem inversa da criação)
TRUNCATE TABLE Pagamento;
TRUNCATE TABLE Contrato;
TRUNCATE TABLE Empresa_Terceirizada;
TRUNCATE TABLE Avaliacao;
TRUNCATE TABLE Professor_Turma;
TRUNCATE TABLE Matricula;
TRUNCATE TABLE Aluno;
TRUNCATE TABLE Horario;
TRUNCATE TABLE Turma;
TRUNCATE TABLE Disciplina;
TRUNCATE TABLE Curso;
TRUNCATE TABLE Colaborador;
TRUNCATE TABLE Departamento;
TRUNCATE TABLE Auditoria;

-- Reativar as verificações
SET FOREIGN_KEY_CHECKS=1;

-- =============================================================================
-- Módulo I: Gestão Administrativa e de Pessoas
-- =============================================================================

-- 1. Inserir Departamentos (sem chefe ainda)
INSERT INTO `Departamento` (`id_departamento`, `nome`, `orcamento_anual`, `id_chefe`) VALUES
(1, 'Departamento de Engenharia e Tecnologias', 50000000.00, NULL),
(2, 'Secretaria Académica', 15000000.00, NULL),
(3, 'Recursos Humanos', 12000000.00, NULL);

-- 2. Inserir Colaboradores
INSERT INTO `Colaborador` (`id_colaborador`, `primeiro_nome`, `ultimo_nome`, `email`, `telefone`, `tipo`, `titulacao`, `id_departamento`) VALUES
(1, 'Judson', 'Paiva', 'judson.paiva@isptec.co.ao', '923111111', 'Professor', 'PhD em Engenharia de Software', 1),
(2, 'Maria', 'Santos', 'maria.santos@isptec.co.ao', '923222222', 'Professor', 'Mestre em Redes de Computadores', 1),
(3, 'Carlos', 'Figueira', 'carlos.figueira@isptec.co.ao', '923333333', 'Professor', 'Mestre em Inteligência Artificial', 1),
(4, 'Ana', 'Gomes', 'ana.gomes@isptec.co.ao', '924444444', 'Administrativo', NULL, 2),
(5, 'Pedro', 'Monteiro', 'pedro.monteiro@isptec.co.ao', '925555555', 'Administrativo', NULL, 3),
(6, 'Joana', 'Lopes', 'joana.lopes@isptec.co.ao', '926666666', 'Professor', 'PhD em Engenharia Civil', 1);

-- 3. Atualizar Departamentos com os Chefes (agora que os colaboradores existem)
UPDATE `Departamento` SET `id_chefe` = 1 WHERE `id_departamento` = 1;
UPDATE `Departamento` SET `id_chefe` = 4 WHERE `id_departamento` = 2;
UPDATE `Departamento` SET `id_chefe` = 5 WHERE `id_departamento` = 3;

-- =============================================================================
-- Módulo II: Gestão Académica
-- =============================================================================

-- 4. Inserir Cursos (com os seus coordenadores)
INSERT INTO `Curso` (`id_curso`, `nome`, `duracao_semestres`, `id_coordenador`) VALUES
(1, 'Engenharia Informática', 10, 1),
(2, 'Engenharia Mecânica', 10, 6);

-- 5. Inserir Disciplinas
INSERT INTO `Disciplina` (`id_disciplina`, `nome`, `carga_horaria_total`, `id_curso`) VALUES
(1, 'Base de Dados II', 96, 1),
(2, 'Programação Orientada a Objectos', 120, 1),
(3, 'Inteligência Artificial', 96, 1),
(4, 'Termodinâmica Aplicada', 120, 2),
(5, 'Mecânica dos Sólidos', 96, 2);

-- 6. Inserir Turmas (Ano Letivo 2025, 1º Semestre)
INSERT INTO `Turma` (`id_turma`, `ano_letivo`, `semestre`, `vagas`, `sala`, `id_disciplina`) VALUES
(1, 2025, 1, 40, 'Sala B201', 1), -- Turma de Base de Dados II
(2, 2025, 1, 35, 'Lab B105', 2), -- Turma de POO
(3, 2025, 1, 30, 'Sala C102', 4); -- Turma de Termodinâmica

-- 7. Inserir Horários
INSERT INTO `Horario` (`id_turma`, `dia_semana`, `hora_inicio`, `hora_fim`) VALUES
(1, 'Segunda', '08:00:00', '10:00:00'),
(1, 'Quarta', '10:00:00', '12:00:00'),
(2, 'Terça', '14:00:00', '17:00:00'),
(3, 'Sexta', '08:00:00', '11:00:00');

-- 8. Inserir Alunos
INSERT INTO `Aluno` (`id_aluno`, `primeiro_nome`, `ultimo_nome`, `email`, `data_nascimento`, `status_propina`) VALUES
(1, 'Miguel', 'Ferreira', 'miguel.f@email.com', '2003-05-15', 'Paga'),
(2, 'Sofia', 'Costa', 'sofia.c@email.com', '2004-02-20', 'Paga'),
(3, 'Rui', 'Almeida', 'rui.a@email.com', '2003-11-10', 'Pendente'),
(4, 'Catarina', 'Martins', 'catarina.m@email.com', '2002-08-01', 'Paga'),
(5, 'André', 'Rodrigues', 'andre.r@email.com', '2004-01-30', 'Paga');

-- 9. Alocar Professores às Turmas
INSERT INTO `Professor_Turma` (`id_professor`, `id_turma`) VALUES
(1, 1), -- Judson Paiva na turma de Base de Dados II
(2, 2), -- Maria Santos na turma de POO
(3, 1), -- Carlos Figueira também na turma de Base de Dados II (co-lecionação)
(6, 3); -- Joana Lopes na turma de Termodinâmica

-- 10. Realizar Matrículas
INSERT INTO `Matricula` (`id_aluno`, `id_turma`) VALUES
(1, 1), -- Miguel em Base de Dados II
(1, 2), -- Miguel em POO
(2, 1), -- Sofia em Base de Dados II
(4, 3), -- Catarina em Termodinâmica
(5, 1); -- André em Base de Dados II

-- 11. Lançar Avaliações
-- Assumindo que os IDs das matrículas são gerados sequencialmente (1, 2, 3, 4, 5)
INSERT INTO `Avaliacao` (`id_matricula`, `descricao`, `nota`, `peso`) VALUES
(1, 'Prova 1', 15.5, 0.4), -- Nota do Miguel em BD2
(1, 'Trabalho Prático', 18.0, 0.6), -- Nota do Miguel em BD2
(3, 'Prova 1', 8.0, 0.4), -- Nota da Sofia em BD2
(3, 'Trabalho Prático', 12.5, 0.6); -- Nota da Sofia em BD2

-- =============================================================================
-- Módulo III: Gestão Operacional
-- =============================================================================

-- 12. Inserir Empresas Terceirizadas
INSERT INTO `Empresa_Terceirizada` (`id_empresa`, `razao_social`, `nif`, `tipo_servico`) VALUES
(1, 'LimpaTudo - Serviços de Limpeza, Lda.', '500123456', 'Limpeza'),
(2, 'Segurança Máxima 24/7, S.A.', '500789123', 'Segurança');

-- 13. Inserir Contratos
INSERT INTO `Contrato` (`id_contrato`, `id_empresa`, `data_inicio`, `data_fim`, `valor_mensal`, `sla_acordado`, `data_validade_garantia`) VALUES
(1, 1, '2025-01-01', '2025-12-31', 1500000.00, 90.00, '2026-01-15'),
(2, 2, '2025-02-01', '2026-01-31', 2500000.00, 95.00, '2026-02-15');

-- 14. Inserir alguns Pagamentos
INSERT INTO `Pagamento` (`id_contrato`, `data_pagamento`, `mes_referencia`, `ano_referencia`, `percentual_sla_apurado`, `valor_multa`, `valor_pago`) VALUES
(1, '2025-02-10', 1, 2025, 92.50, 0.00, 1500000.00), -- Pagamento com SLA OK
(1, '2025-03-11', 2, 2025, 88.00, 150000.00, 1350000.00), -- Pagamento com multa (exemplo)
(2, '2025-03-15', 2, 2025, 96.00, 0.00, 2500000.00); -- Pagamento com SLA OK

