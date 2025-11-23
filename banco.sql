-- =========================================================
-- SCRIPT DE CRIAÇÃO DO BANCO DE DADOS
-- Professor: Álvaro Lindão
-- =========================================================

-- 1. CRIAÇÃO DAS TABELAS

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY, -- LEMBRANDO QUE O SERIAL ADICIONA AUTOINCREMENTO
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    destino_producao VARCHAR(20) CHECK (destino_producao IN ('COPA', 'COZINHA')) NOT NULL
);

CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL,
    id_categoria INTEGER REFERENCES categorias(id),
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE comandas (
    id SERIAL PRIMARY KEY,
    numero_mesa INTEGER NOT NULL,
    nome_cliente VARCHAR(100),
    id_usuario INTEGER REFERENCES usuarios(id),
    status VARCHAR(20) DEFAULT 'ABERTA' CHECK (status IN ('ABERTA', 'FECHADA')),
    valor_total DECIMAL(10, 2) DEFAULT 0.00,
    data_abertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_fechamento TIMESTAMP
);

CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    id_comanda INTEGER REFERENCES comandas(id) ON DELETE CASCADE,
    id_produto INTEGER REFERENCES produtos(id),
    quantidade INTEGER NOT NULL DEFAULT 1,
    status_producao VARCHAR(20) DEFAULT 'PENDENTE' CHECK (status_producao IN ('PENDENTE', 'EM_PREPARO', 'PRONTO', 'ENTREGUE')),
    preco_unitario DECIMAL(10, 2) NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. CRIAÇÃO DE ÍNDICES

-- Criei índices somente para as colunas que eu achei relevante.

CREATE INDEX idx_usuario_email ON usuarios(email);
CREATE INDEX idx_comanda_status ON comandas(status);
CREATE INDEX idx_pedidos_comanda ON pedidos(id_comanda);

-- 3. CRIAÇÃO DE TRIGGER

-- Funcionalidade: Pega o preço atual do produto, salva na tabela pedido automaticamente.

CREATE OR REPLACE FUNCTION preencher_preco_pedido()
RETURNS TRIGGER AS $$
BEGIN
    SELECT preco INTO NEW.preco_unitario
    FROM produtos
    WHERE id = NEW.id_produto;

    IF NEW.preco_unitario IS NULL THEN
        RAISE EXCEPTION 'Produto não encontrado para o ID informado';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_preencher_preco
BEFORE INSERT ON pedidos
FOR EACH ROW
EXECUTE FUNCTION preencher_preco_pedido();

-- 4. CRIAÇÃO STORED PROCEDURE

-- Funcionalidade: Calcula o total e fecha a comanda.

CREATE OR REPLACE PROCEDURE fechar_comanda(p_id_comanda INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total DECIMAL(10, 2);
BEGIN
    IF NOT EXISTS (SELECT 1 FROM comandas WHERE id = p_id_comanda AND status = 'ABERTA') THEN
        RAISE EXCEPTION 'Comanda não encontrada ou já fechada.';
    END IF;

    SELECT COALESCE(SUM(quantidade * preco_unitario), 0)
    INTO v_total
    FROM pedidos
    WHERE id_comanda = p_id_comanda;

    UPDATE comandas
    SET status = 'FECHADA',
        valor_total = v_total,
        data_fechamento = CURRENT_TIMESTAMP
    WHERE id = p_id_comanda;
    
    RAISE NOTICE 'Comanda % fechada. Total a pagar: R$ %', p_id_comanda, v_total;
END;
$$;

-- 5. DADOS DE TESTE

-- Para vocês não começarem com o banco de dados vazio Sz :)

INSERT INTO usuarios (nome, email, senha) VALUES ('Garçom Viccenzo Lindão', 'viccenzolindao@gmail.com', '123456');

INSERT INTO categorias (nome, destino_producao) VALUES 
('Bebidas', 'COPA'), 
('Pratos Principais', 'COZINHA');

INSERT INTO produtos (nome, descricao, preco, id_categoria) VALUES 
('Coca-Cola', 'Lata 350ml', 6.00, 1),
('Parmegiana', 'Acompanha fritas', 45.00, 2);

-- Exemplo de abertura de comanda
INSERT INTO comandas (numero_mesa, nome_cliente, id_usuario) VALUES (10, 'Augusto Lindão', 1);

-- Exemplo de pedido (O trigger vai preencher o preço sozinho)
INSERT INTO pedidos (id_comanda, id_produto, quantidade) VALUES (1, 2, 2);
INSERT INTO pedidos (id_comanda, id_produto, quantidade) VALUES (1, 1, 3);
