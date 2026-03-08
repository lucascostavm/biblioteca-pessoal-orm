from models import SessionLocal, Publicacao, Leitura, Anotacao
from sqlalchemy.orm import joinedload
from sqlalchemy import desc

def executar_operacoes():
    session = SessionLocal()
    
    try:
        print("\n" + "="*50)
        print(" PARTE 3: OPERAÇÕES CRUD VIA ORM")
        print("="*50)
        
        # 1. CREATE: Inserir publicações verificando se já existem
        print("\n[1] CREATE: Verificando e inserindo publicações...")
        
        # Verifica se o livro já existe antes de tentar inserir
        livro_existe = session.query(Publicacao).filter(Publicacao.titulo == "Memórias Póstumas de Brás Cubas").first()
        
        if not livro_existe:
            pub1 = Publicacao(titulo="Memórias Póstumas de Brás Cubas", autor="Machado de Assis", ano=1881, tipo="LIVRO", genero="Romance", num_paginas=320)
            pub2 = Publicacao(titulo="Código Limpo", autor="Robert C. Martin", ano=2008, tipo="LIVRO", genero="Tecnologia", num_paginas=425)
            pub3 = Publicacao(titulo="Sapiens: Uma Breve História da Humanidade", autor="Yuval Noah Harari", ano=2011, tipo="LIVRO", genero="História", num_paginas=464)
            pub4 = Publicacao(titulo="Revista Piauí", autor="Editora Alvinegra", ano=2023, tipo="REVISTA", genero="Jornalismo", num_paginas=80)
            
            session.add_all([pub1, pub2, pub3, pub4])
            session.commit()
            print("    ✅ 4 publicações inseridas com sucesso!")
        else:
            print("    ⚠️ As publicações já existem no banco. Pulando inserção para evitar duplicatas.")

        # 2. READ: Listar registros com ordenação
        print("\n[2] READ: Listando publicações ordenadas por ano de lançamento...")
        publicacoes_ordenadas = session.query(Publicacao).order_by(Publicacao.ano).limit(5).all()
        for p in publicacoes_ordenadas:
            print(f"    -> {p.titulo} ({p.ano}) - {p.autor}")

        # 3. UPDATE: Atualizar 1 registro
        print("\n[3] UPDATE: Atualizando o gênero de Sapiens...")
        livro_update = session.query(Publicacao).filter(Publicacao.titulo == "Sapiens: Uma Breve História da Humanidade").first()
        if livro_update:
            livro_update.genero = "História e Antropologia"
            session.commit()
            print(f"    ✅ Gênero do livro Sapiens atualizado para: {livro_update.genero}")
        else:
             print("    ⚠️ Livro Sapiens não encontrado para atualizar.")

        # 4. DELETE: Remover 1 registro
        print("\n[4] DELETE: Removendo a Revista Piauí...")
        revista_remover = session.query(Publicacao).filter(Publicacao.titulo == "Revista Piauí").first()
        if revista_remover:
            session.delete(revista_remover)
            session.commit()
            print("    ✅ Revista removida com sucesso!")
        else:
            print("    ⚠️ Revista Piauí já foi removida anteriormente.")


        print("\n" + "="*50)
        print(" PARTE 4: CONSULTAS COM RELACIONAMENTO")
        print("="*50)

        # Consulta 1: JOIN explícito via ORM (Listar Leituras trazendo dados da Publicação)
        print("\n[Consulta 1] JOIN: Leituras cadastradas e seus respectivos livros:")
        leituras = session.query(Leitura).options(joinedload(Leitura.publicacao)).limit(4).all()
        for l in leituras:
            print(f"    -> Status: {l.status} | Livro: {l.publicacao.titulo}")

        # Consulta 2: JOIN + Filtro (Buscar anotações de um autor específico)
        print("\n[Consulta 2] JOIN + Filtro: Anotações feitas em livros do George Orwell:")
        anotacoes = session.query(Anotacao).join(Publicacao).filter(Publicacao.autor == "George Orwell").all()
        for a in anotacoes:
            print(f"    -> Livro: {a.publicacao.titulo} | Trecho: {a.trecho}")

        # Consulta 3: Filtro + Ordenação (Top leituras por avaliação)
        print("\n[Consulta 3] Filtro + Ordenação: Leituras concluídas (LIDO) ordenadas por nota:")
        top_leituras = session.query(Leitura).filter(Leitura.status == 'LIDO').order_by(desc(Leitura.avaliacao)).limit(3).all()
        for tl in top_leituras:
            print(f"    -> Avaliação: {tl.avaliacao}/10 | Páginas lidas: {tl.pagina_atual}")

    except Exception as e:
        session.rollback()
        print(f"\n❌ Ocorreu um erro: {e}")
    finally:
        session.close()

if __name__ == "__main__":
    executar_operacoes()