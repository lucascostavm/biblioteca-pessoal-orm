# 📚 Biblioteca Pessoal Digital - Acesso via ORM

Este projeto é a entrega do **Projeto Final 7**, focado em conectar a aplicação "Biblioteca Pessoal Digital" ao banco de dados PostgreSQL utilizando o ORM **SQLAlchemy** em Python.

O objetivo principal é demonstrar o mapeamento de tabelas relacionais para classes (orientação a objetos) e realizar operações de CRUD e consultas complexas (JOINs, Filtros e Ordenações) sem a escrita direta de código SQL.

---

## 🚀 Tecnologias Utilizadas

- **Linguagem:** Python 3.x
- **Banco de Dados:** PostgreSQL
- **ORM:** SQLAlchemy
- **Gerenciamento de Dependências:** pip / venv
- **Segurança:** python-dotenv (para ocultar credenciais)

---

## ⚙️ Configuração do Banco de Dados

1. **Scripts SQL:** Certifique-se de ter rodado o script de criação (`DDL`) e inserção de dados (`DML`) no seu servidor PostgreSQL. O banco deve se chamar `biblioteca_db` (ou o nome que você definiu).
2. **Variáveis de Ambiente:** O projeto utiliza um arquivo `.env` na raiz para ler as credenciais de forma segura. Você deve criar este arquivo seguindo o modelo abaixo:

**Crie um arquivo `.env` na raiz do projeto com o seguinte formato:**
```env
DB_USER=seu_usuario_postgres
DB_PASSWORD=sua_senha
DB_HOST=localhost
DB_PORT=5432
DB_NAME=biblioteca_db
💻 Como Executar o Projeto (Passo a Passo)
Siga os comandos abaixo no terminal para rodar o projeto localmente:

1. Clonar o repositório
Bash
git clone [https://github.com/lucascostavm/biblioteca-pessoal-orm.git](https://github.com/SEU_USUARIO/biblioteca-pessoal-orm.git)
cd biblioteca-pessoal-orm
2. Criar e ativar o ambiente virtual (Recomendado)
No Windows:

Bash
python -m venv venv
.\venv\Scripts\activate
No Linux/Mac:

Bash
python3 -m venv venv
source venv/bin/activate
3. Instalar as dependências
Bash
pip install sqlalchemy psycopg2-binary python-dotenv
4. Executar as operações ORM
Após configurar o .env, rode o script principal que fará as operações no banco:

Bash
python crud.py
📊 Exemplos de Uso e Saída Esperada
Ao executar python crud.py, o ORM realizará as operações das Partes 3 e 4 da atividade. Abaixo está um exemplo da saída esperada no terminal:

Plaintext
==================================================
 PARTE 3: OPERAÇÕES CRUD VIA ORM
==================================================

[1] CREATE: Verificando e inserindo publicações reais...
    ✅ 4 publicações inseridas com sucesso!

[2] READ: Listando publicações ordenadas por ano de lançamento...
    -> Memórias Póstumas de Brás Cubas (1881) - Machado de Assis
    -> Código Limpo (2008) - Robert C. Martin
    -> Sapiens: Uma Breve História da Humanidade (2011) - Yuval Noah Harari

[3] UPDATE: Atualizando o gênero de Sapiens...
    ✅ Gênero do livro Sapiens atualizado para: História e Antropologia

[4] DELETE: Removendo a Revista Piauí...
    ✅ Revista removida com sucesso!

==================================================
 PARTE 4: CONSULTAS COM RELACIONAMENTO
==================================================

[Consulta 1] JOIN: Leituras cadastradas e seus respectivos livros:
    -> Status: LIDO | Livro: O Pequeno Príncipe
    -> Status: LENDO | Livro: O Caso Evandro

[Consulta 2] JOIN + Filtro: Anotações feitas em livros do George Orwell:
    -> Livro: 1984 | Trecho: O Grande Irmão está de olho em você.

[Consulta 3] Filtro + Ordenação: Leituras concluídas (LIDO) ordenadas por nota:
    -> Avaliação: 10/10 | Páginas lidas: 96
    -> Avaliação: 9/10 | Páginas lidas: 336
Nota para a entrega: Prints reais do terminal em funcionamento foram anexados na submissão da plataforma para evidenciar o funcionamento (Evidências de Funcionamento).