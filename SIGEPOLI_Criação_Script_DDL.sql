-- =============================================================================
-- Script DDL para a criação do Banco de Dados SIGEPOLI
-- Projecto: SIGEPOLI
-- Disciplina / Cadeira: Base de Dados II
-- Autor: Willfredy Vieira Dias
-- Número de Estudante: 20200204
-- Docente: Judson Paiva
-- Versão: 1.0
--
-- Descrição: Este script cria todo o esquema da base de dados, incluindo
-- tabelas, chaves primárias, chaves estrangeiras, restrições e índices.
-- =============================================================================

-- Criação do Schema (Base de Dados) e Definição para Uso
CREATE SCHEMA IF NOT EXISTS `SIGEPOLI` DEFAULT CHARACTER SET utf8mb4 ; 
USE `SIGEPOLI` ;

-- -----------------------------------------------------
-- Tabela `Departamento`
-- Armazena os departamentos do instituto.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Departamento` (
  `id_departamento` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `orcamento_anual` DECIMAL(15,2) NOT NULL,
  `id_chefe` INT NULL,
  PRIMARY KEY (`id_departamento`),
  UNIQUE INDEX `nome_UNIQUE` (`nome` ASC),
  CONSTRAINT `chk_orcamento_positivo` CHECK (`orcamento_anual` >= 0)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela `Colaborador`
-- Registo unificado de todos os funcionários.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Colaborador` (
  `id_colaborador` INT NOT NULL AUTO_INCREMENT,
  `primeiro_nome` VARCHAR(100) NOT NULL,
  `ultimo_nome` VARCHAR(100) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `telefone` VARCHAR(9) NULL,
  `tipo` ENUM('Administrativo', 'Professor') NOT NULL,
  `titulacao` VARCHAR(255) NULL,
  `id_departamento` INT NOT NULL,
  PRIMARY KEY (`id_colaborador`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC),
  INDEX `fk_Colaborador_Departamento_idx` (`id_departamento` ASC),
  CONSTRAINT `fk_Colaborador_Departamento`
    FOREIGN KEY (`id_departamento`)
    REFERENCES `Departamento` (`id_departamento`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Adiciona a chave estrangeira para o chefe de departamento após a criação da tabela Colaborador
ALTER TABLE `Departamento`
ADD INDEX `fk_Departamento_Colaborador_idx` (`id_chefe` ASC),
ADD CONSTRAINT `fk_Departamento_Colaborador`
  FOREIGN KEY (`id_chefe`)
  REFERENCES `Colaborador` (`id_colaborador`)
  ON DELETE SET NULL
  ON UPDATE CASCADE;


-- -----------------------------------------------------
-- Tabela `Curso`
-- Armazena os cursos oferecidos.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Curso` (
  `id_curso` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(150) NOT NULL,
  `duracao_semestres` INT NOT NULL,
  `id_coordenador` INT NOT NULL,
  PRIMARY KEY (`id_curso`),
  UNIQUE INDEX `nome_UNIQUE` (`nome` ASC),
  UNIQUE INDEX `id_coordenador_UNIQUE` (`id_coordenador` ASC),
  CONSTRAINT `fk_Curso_Colaborador`
    FOREIGN KEY (`id_coordenador`)
    REFERENCES `Colaborador` (`id_colaborador`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `chk_duracao_semestres` CHECK (`duracao_semestres` > 0)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela `Disciplina`
-- Disciplinas que pertencem a cada curso.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Disciplina` (
  `id_disciplina` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(150) NOT NULL,
  `carga_horaria_total` INT NOT NULL,
  `id_curso` INT NOT NULL,
  PRIMARY KEY (`id_disciplina`),
  INDEX `fk_Disciplina_Curso_idx` (`id_curso` ASC),
  UNIQUE INDEX `uq_disciplina_curso` (`nome` ASC, `id_curso` ASC),
  CONSTRAINT `fk_Disciplina_Curso`
    FOREIGN KEY (`id_curso`)
    REFERENCES `Curso` (`id_curso`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `chk_carga_horaria` CHECK (`carga_horaria_total` > 0)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela `Turma`
-- Instância de uma disciplina num ano/semestre específico.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Turma` (
  `id_turma` INT NOT NULL AUTO_INCREMENT,
  `ano_letivo` INT NOT NULL,
  `semestre` INT NOT NULL,
  `vagas` INT NOT NULL,
  `sala` VARCHAR(20) NULL,
  `id_disciplina` INT NOT NULL,
  PRIMARY KEY (`id_turma`),
  INDEX `fk_Turma_Disciplina_idx` (`id_disciplina` ASC),
  CONSTRAINT `fk_Turma_Disciplina`
    FOREIGN KEY (`id_disciplina`)
    REFERENCES `Disciplina` (`id_disciplina`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `chk_semestre` CHECK (`semestre` IN (1, 2)),
  CONSTRAINT `chk_vagas` CHECK (`vagas` >= 0)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela `Horario`
-- Define os dias e horas de aula de uma turma.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Horario` (
  `id_horario` INT NOT NULL AUTO_INCREMENT,
  `id_turma` INT NOT NULL,
  `dia_semana` ENUM('Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado') NOT NULL,
  `hora_inicio` TIME NOT NULL,
  `hora_fim` TIME NOT NULL,
  PRIMARY KEY (`id_horario`),
  INDEX `fk_Horario_Turma_idx` (`id_turma` ASC),
  CONSTRAINT `fk_Horario_Turma`
    FOREIGN KEY (`id_turma`)
    REFERENCES `Turma` (`id_turma`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `chk_hora_ordem` CHECK (`hora_fim` > `hora_inicio`)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela `Aluno`
-- Registo dos estudantes.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Aluno` (
  `id_aluno` INT NOT NULL AUTO_INCREMENT,
  `primeiro_nome` VARCHAR(100) NOT NULL,
  `ultimo_nome` VARCHAR(100) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `data_nascimento` DATE NOT NULL,
  `status_propina` ENUM('Paga', 'Pendente') NOT NULL DEFAULT 'Pendente',
  PRIMARY KEY (`id_aluno`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela `Matricula`
-- Tabela associativa para a relação N:M entre Aluno e Turma.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Matricula` (
  `id_matricula` INT NOT NULL AUTO_INCREMENT,
  `id_aluno` INT NOT NULL,
  `id_turma` INT NOT NULL,
  `data_matricula` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_matricula`),
  INDEX `fk_Matricula_Aluno_idx` (`id_aluno` ASC),
  INDEX `fk_Matricula_Turma_idx` (`id_turma` ASC),
  UNIQUE INDEX `uq_aluno_turma` (`id_aluno` ASC, `id_turma` ASC),
  CONSTRAINT `fk_Matricula_Aluno`
    FOREIGN KEY (`id_aluno`)
    REFERENCES `Aluno` (`id_aluno`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Matricula_Turma`
    FOREIGN KEY (`id_turma`)
    REFERENCES `Turma` (`id_turma`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela `Professor_Turma`
-- Tabela associativa para a relação N:M entre Professor e Turma.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Professor_Turma` (
  `id_professor` INT NOT NULL,
  `id_turma` INT NOT NULL,
  PRIMARY KEY (`id_professor`, `id_turma`),
  INDEX `fk_Professor_Turma_Turma_idx` (`id_turma` ASC),
  CONSTRAINT `fk_Professor_Turma_Colaborador`
    FOREIGN KEY (`id_professor`)
    REFERENCES `Colaborador` (`id_colaborador`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Professor_Turma_Turma`
    FOREIGN KEY (`id_turma`)
    REFERENCES `Turma` (`id_turma`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela `Avaliacao`
-- Registo das notas dos alunos.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Avaliacao` (
  `id_avaliacao` INT NOT NULL AUTO_INCREMENT,
  `id_matricula` INT NOT NULL,
  `descricao` VARCHAR(150) NULL,
  `nota` DECIMAL(4,2) NOT NULL,
  `peso` DECIMAL(3,2) NOT NULL,
  PRIMARY KEY (`id_avaliacao`),
  INDEX `fk_Avaliacao_Matricula_idx` (`id_matricula` ASC),
  CONSTRAINT `fk_Avaliacao_Matricula`
    FOREIGN KEY (`id_matricula`)
    REFERENCES `Matricula` (`id_matricula`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `chk_nota` CHECK (`nota` BETWEEN 0 AND 20),
  CONSTRAINT `chk_peso` CHECK (`peso` > 0 AND `peso` <= 1)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela `Empresa_Terceirizada`
-- Registo das empresas contratadas.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Empresa_Terceirizada` (
  `id_empresa` INT NOT NULL AUTO_INCREMENT,
  `razao_social` VARCHAR(255) NOT NULL,
  `nif` VARCHAR(30) NOT NULL,
  `tipo_servico` ENUM('Limpeza', 'Segurança', 'Cafetaria') NOT NULL,
  PRIMARY KEY (`id_empresa`),
  UNIQUE INDEX `razao_social_UNIQUE` (`razao_social` ASC),
  UNIQUE INDEX `nif_UNIQUE` (`nif` ASC)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela `Contrato`
-- Detalhes dos contratos com as empresas.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Contrato` (
  `id_contrato` INT NOT NULL AUTO_INCREMENT,
  `id_empresa` INT NOT NULL,
  `data_inicio` DATE NOT NULL,
  `data_fim` DATE NOT NULL,
  `valor_mensal` DECIMAL(15,2) NOT NULL,
  `sla_acordado` DECIMAL(5,2) NOT NULL DEFAULT 90.00,
  `data_validade_garantia` DATE NOT NULL,
  PRIMARY KEY (`id_contrato`),
  INDEX `fk_Contrato_Empresa_Terceirizada_idx` (`id_empresa` ASC),
  CONSTRAINT `fk_Contrato_Empresa_Terceirizada`
    FOREIGN KEY (`id_empresa`)
    REFERENCES `Empresa_Terceirizada` (`id_empresa`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `chk_datas_contrato` CHECK (`data_fim` > `data_inicio`),
  CONSTRAINT `chk_valor_mensal` CHECK (`valor_mensal` > 0)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela `Pagamento`
-- Registo dos pagamentos mensais aos fornecedores.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pagamento` (
  `id_pagamento` INT NOT NULL AUTO_INCREMENT,
  `id_contrato` INT NOT NULL,
  `data_pagamento` DATE NOT NULL,
  `mes_referencia` INT NOT NULL,
  `ano_referencia` INT NOT NULL,
  `percentual_sla_apurado` DECIMAL(5,2) NOT NULL,
  `valor_multa` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `valor_pago` DECIMAL(15,2) NOT NULL,
  PRIMARY KEY (`id_pagamento`),
  INDEX `fk_Pagamento_Contrato_idx` (`id_contrato` ASC),
  CONSTRAINT `fk_Pagamento_Contrato`
    FOREIGN KEY (`id_contrato`)
    REFERENCES `Contrato` (`id_contrato`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `chk_mes_referencia` CHECK (`mes_referencia` BETWEEN 1 AND 12)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela `Auditoria`
-- Regista alterações importantes no sistema.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Auditoria` (
  `id_log` INT NOT NULL AUTO_INCREMENT,
  `tabela_afetada` VARCHAR(50) NOT NULL,
  `id_registo_afetado` INT NULL,
  `tipo_operacao` ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
  `descricao` TEXT NOT NULL,
  `utilizador` VARCHAR(100) NOT NULL,
  `data_hora` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_log`)
) ENGINE = InnoDB;


-- =============================================================================
-- Criação de Índices Adicionais para Otimização de Consultas
-- =============================================================================
CREATE INDEX `idx_aluno_nome` ON `Aluno` (`ultimo_nome` ASC, `primeiro_nome` ASC);
CREATE INDEX `idx_colaborador_nome` ON `Colaborador` (`ultimo_nome` ASC, `primeiro_nome` ASC);

