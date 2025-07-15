**SIGEPOLI - Projeto Final de Base de Dados II**

Este repositório contém o projeto final para a cadeira curricular de **Base de Dados II**, da Licenciatura em Engenharia Informática do Instituto Superior Politécnico de Tecnologias e Ciências (ISPTEC).

---

## Índice

1. [Sobre o Projeto](#sobre-o-projeto)
2. [Modelo Conceitual da Base de Dados](#modelo-conceitual-da-base-de-dados)
3. [Tecnologias Utilizadas](#tecnologias-utilizadas)
4. [Como Executar o Projeto](#como-executar-o-projeto)
5. [Funcionalidades Implementadas](#funcionalidades-implementadas)
6. [Autor](#autor)

---

## Sobre o Projeto

O **SIGEPOLI** (Sistema Integrado de Gestão Académica, Pessoal e Operacional) é um projeto de base de dados relacional desenhado para gerir de forma integrada as principais operações de uma instituição de ensino superior.

O sistema foi modelado para cobrir três áreas de negócio críticas:

* **Gestão Académica**: Controle de cursos, disciplinas, turmas, matrículas de alunos e lançamento de avaliações.
* **Gestão de Pessoas**: Administração de colaboradores, incluindo docentes, pessoal administrativo, chefes de departamento e coordenadores de curso.
* **Gestão Operacional**: Gestão de contratos e pagamentos a empresas terceirizadas (ex.: limpeza, segurança), com controle de Acordos de Nível de Serviço (SLA).

O objetivo principal é centralizar a informação, eliminar redundâncias e fornecer mecanismos robustos para garantir a integridade e a rastreabilidade dos dados.

---

## Modelo Conceitual da Base de Dados

Abaixo segue o diagrama de alto nível do sistema, com as principais entidades e respetivas relações.

```mermaid
%%{init: {'theme':'default'}}%%
flowchart TD
    subgraph "Módulo I: Gestão Administrativa e de Pessoas"
        A("<b>Departamento</b><br><small>Armazena os departamentos do instituto.</small>")
        B("<b>Colaborador</b><br><small>Centraliza professores e administrativos.</small>")
    end
    subgraph "Módulo II: Gestão Académica"
        C("<b>Curso</b><br><small>Contém os cursos oferecidos.</small>")
        D("<b>Disciplina</b><br><small>Disciplinas que compõem cada curso.</small>")
        E("<b>Turma</b><br><small>Instância de uma disciplina num período.</small>")
        F("<b>Aluno</b><br><small>Registo central de estudantes.</small>")
        G("<b>Horario</b><br><small>Define os horários de uma turma.</small>")
    end
    subgraph "Entidades Associativas (Resolução N:M)"
        H("<b>Matrícula</b><br><small>Resolve a relação Aluno-Turma.</small>")
        I("<b>Professor_Turma</b><br><small>Resolve a relação Professor-Turma.</small>")
        J("<b>Avaliação</b><br><small>Notas de um aluno numa matrícula.</small>")
    end
    subgraph "Módulo III: Gestão Operacional"
        K("<b>Empresa_Terceirizada</b><br><small>Empresas de serviços contratadas.</small>")
        L("<b>Contrato</b><br><small>Contratos associados a cada empresa.</small>")
        M("<b>Pagamento</b><br><small>Registo de pagamentos mensais.</small>")
    end
    subgraph "Módulo IV: Auditoria"
        N("<b>Auditoria</b><br><small>Tabela técnica que regista alterações sensíveis.</small>")
    end
    A -- "1..N possui" --> B
    B -- "1..1 coordena" --> C
    C -- "1..N é composto por" --> D
    D -- "0..N oferece" --> E
    E -- "0..N tem" --> G
    E -- "0..N é lecionada por" --> I
    B -- "0..N leciona em" --> I
    E -- "0..N recebe" --> H
    F -- "0..N inscreve-se em" --> H
    H -- "1..N resulta em" --> J
    K -- "0..N assina" --> L
    L -- "0..N gera" --> M
    style subGraph0 fill:#BBDEFB,stroke:#333
    style subGraph1 fill:#FFE0B2,stroke:#333
    style subGraph2 fill:#FFCDD2,stroke:#333
    style subGraph3 fill:#C8E6C9,stroke:#333
    style subGraph4 fill:#E1BEE7,stroke:#333
```

---

## Tecnologias Utilizadas

* **SGBD**: MySQL
* **Ferramenta de Modelação**: MySQL Workbench

---

## Como Executar o Projeto

Siga os passos abaixo para criar e popular a base de dados **SIGEPOLI** no seu ambiente local.

### Pré-requisitos

* MySQL Server instalado
* MySQL Workbench (ou outro cliente SQL compatível)

### Passos de Instalação

1. Clone este repositório:

   ```bash
   git clone https://github.com/seu-usuario/sigepoli.git
   ```
2. Abra o seu cliente SQL e conecte-se ao servidor MySQL.
3. Execute os scripts SQL pela ordem abaixo:

   ```bash
   # Criação do esquema e tabelas
   mysql -u usuario -p < scripts/1_ddl_schema.sql

   # Inserção de dados de teste
   mysql -u usuario -p < scripts/2_dml_inserts.sql

   # Lógica de negócio: procedures, functions e triggers
   mysql -u usuario -p < scripts/3_procedures.sql
   mysql -u usuario -p < scripts/4_functions.sql
   mysql -u usuario -p < scripts/5_triggers.sql
   ```
4. A base de dados estará pronta para consulta e testes.

---

## Funcionalidades Implementadas

### Stored Procedures

* **sp\_matricular\_aluno**: Realiza a matrícula de um aluno, validando vagas e estado das propinas (RN02).
* **sp\_alocar\_professor**: Aloca um docente a uma turma, prevenindo conflitos de horário (RN01).
* **sp\_processar\_pagamento**: Processa pagamentos a empresas, calculando multas com base no SLA (RN05).

### Functions

* **fn\_calcular\_media\_ponderada**: Calcula a média final ponderada de um aluno numa disciplina.
* **fn\_obter\_sla\_mensal**: Consulta o SLA apurado para um contrato no mês.

### Triggers

* **trg\_auditoria\_matriculas**: Regista log na tabela Auditoria após cada nova matrícula.
* **trg\_auditoria\_pagamentos**: Regista log na tabela Auditoria após cada novo pagamento.
* **trg\_bloquear\_pagamento\_sem\_garantia**: Bloqueia pagamento se a garantia do contrato estiver expirada (RN04).

### Views

* **vw\_grade\_horaria\_curso**: Relatório consolidado da grade horária por curso.
* **vw\_carga\_horaria\_professor**: Resumo da carga horária total por docente.
* **vw\_resumo\_custos\_servicos**: Agrega custos mensais com serviços terceirizados.

---

## Autor

**Willfredy Eliúde Pinto Vieira Dias**
[willfredvd@gmail.com](mailto:o.seu.email@exemplo.com)

> Projeto desenvolvido no âmbito da avaliação da cadeira de Base de Dados II.
