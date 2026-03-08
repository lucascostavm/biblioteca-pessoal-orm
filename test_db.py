from models import engine
from sqlalchemy import text

try:
    # Tenta abrir uma conexão com o banco
    with engine.connect() as connection:
        # Executa um comando SQL bem simples só para testar
        result = connection.execute(text("SELECT version();"))
        
        print("\n✅ SUCESSO! A conexão com o banco de dados funcionou perfeitamente.")
        for row in result:
            print(f"Detalhes do banco: {row[0]}\n")
            
except Exception as e:
    print("\n❌ ERRO! Não foi possível conectar ao banco de dados. Verifique sua senha ou nome do banco no .env.")
    print(f"Detalhes do erro: {e}\n")