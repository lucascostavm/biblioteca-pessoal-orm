import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, Column, Integer, String, Date, Text, DateTime, ForeignKey, CheckConstraint, UniqueConstraint
from sqlalchemy.orm import declarative_base, relationship, sessionmaker
from datetime import datetime

# ==========================================
# PARTE 1: CONFIGURAÇÃO E CONEXÃO
# ==========================================
# Carrega as variáveis de ambiente do arquivo .env
load_dotenv()

db_user = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")
db_host = os.getenv("DB_HOST")
db_port = os.getenv("DB_PORT")
db_name = os.getenv("DB_NAME")

# Monta a string de conexão do PostgreSQL
DATABASE_URL = f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"

# Cria a "engine" de conexão com o banco
engine = create_engine(DATABASE_URL, echo=False)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ==========================================
# PARTE 2: MAPEAMENTO DAS ENTIDADES
# ==========================================

class Configuracao(Base):
    __tablename__ = 'configuracao'
    
    id_configuracao = Column(Integer, primary_key=True, autoincrement=True)
    genero_favorito = Column(String(50), unique=True) # UniqueConstraint aplicada
    limite_simultaneas = Column(Integer, default=3)
    meta_anual_leituras = Column(Integer, nullable=False)

class Publicacao(Base):
    __tablename__ = 'publicacao'
    
    id_publicacao = Column(Integer, primary_key=True, autoincrement=True)
    titulo = Column(String(200), nullable=False)
    autor = Column(String(150), nullable=False)
    ano = Column(Integer)
    tipo = Column(String(20), nullable=False)
    genero = Column(String(50))
    num_paginas = Column(Integer)
    data_inclusao = Column(DateTime, default=datetime.now)

    __table_args__ = (
        UniqueConstraint('titulo', 'autor', name='unq_publicacao_titulo_autor'), #
        CheckConstraint('ano >= 1500', name='ck_publicacao_ano'), #
        CheckConstraint('num_paginas > 0', name='ck_publicacao_paginas_validas'), #
    )

    # Relacionamentos (Obrigatório na atividade: 1 para N)
    leituras = relationship("Leitura", back_populates="publicacao", cascade="all, delete-orphan")
    anotacoes = relationship("Anotacao", back_populates="publicacao", cascade="all, delete-orphan")

class Leitura(Base):
    __tablename__ = 'leitura'
    
    id_leitura = Column(Integer, primary_key=True, autoincrement=True)
    id_publicacao = Column(Integer, ForeignKey('publicacao.id_publicacao', ondelete='CASCADE'), nullable=False) #
    data_inicio = Column(Date)
    data_fim = Column(Date)
    status = Column(String(20), default='NAO LIDO')
    pagina_atual = Column(Integer, default=0)
    avaliacao = Column(Integer)

    __table_args__ = (
        CheckConstraint('pagina_atual >= 0', name='ck_leitura_pagina_nao_negativa'), #
    )

    # Relacionamento de volta para Publicacao (N para 1)
    publicacao = relationship("Publicacao", back_populates="leituras")

class Anotacao(Base):
    __tablename__ = 'anotacao'
    
    id_anotacao = Column(Integer, primary_key=True, autoincrement=True)
    id_publicacao = Column(Integer, ForeignKey('publicacao.id_publicacao', ondelete='CASCADE'), nullable=False) #
    texto = Column(Text, nullable=False)
    trecho = Column(Text)
    data_anotacao = Column(DateTime, default=datetime.now)

    # Relacionamento de volta para Publicacao (N para 1)
    publicacao = relationship("Publicacao", back_populates="anotacoes")