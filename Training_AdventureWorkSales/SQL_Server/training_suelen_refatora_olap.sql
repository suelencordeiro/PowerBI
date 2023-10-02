--CREATE SCHEMA training_suelen_refatorar_olap;
DROP TABLE training_suelen_refatorar_olap.dim_clientes;
CREATE TABLE training_suelen_refatorar_olap.dim_clientes
(
        sk_clientes INT IDENTITY(1,1) PRIMARY KEY,
        data_de VARCHAR(64),
        data_para VARCHAR(64),
        versao INT,
        nk_id_cliente INT,
        cliente VARCHAR(64), 
        cidade VARCHAR(64),
        estado VARCHAR(64),
        pais VARCHAR(64),
        cod_postal VARCHAR(64)
);


INSERT INTO training_suelen_refatorar_olap.dim_clientes
SELECT 
         '1900-01-01' AS data_de,
         '2200-01-01' AS data_para,
         1 AS vesao,
         CLIENTES.id AS nk_id_cliente,
         CLIENTES.cliente,
         CIDADE.cidade,
         ESTADO.estado_provincia AS estado,
         PAIS.pais_regiao AS pais,
         CLIENTES.cod_postal
                 
FROM training_suelen_refatorar_oltp.clientes CLIENTES
JOIN training_suelen_refatorar_oltp.cidade_cliente CIDADE
        ON CIDADE.id = CLIENTES.id_cidade_cliente
JOIN training_suelen_refatorar_oltp.estado_cliente ESTADO
        ON ESTADO.id = CLIENTES.id_estado_cliente
JOIN training_suelen_refatorar_oltp.pais_regiao_cliente PAIS
        ON PAIS.id = CLIENTES.id_pais_regiao_cliente
------------------------------------------------------------------------------

DROP TABLE training_suelen_refatorar_olap.dim_revendedor;
CREATE TABLE training_suelen_refatorar_olap.dim_revendedor
(
        sk_revendedor INT IDENTITY(1,1) PRIMARY KEY,
        data_de VARCHAR(64),
        data_para VARCHAR(64),
        versao INT,
        nk_id_revendedor INT,
        revendedor VARCHAR(64),
        tipo_de_negocio VARCHAR(64),
        cidade VARCHAR(64),
        estado VARCHAR(64),
        pais VARCHAR(64),
        cod_postal VARCHAR(64)
);


INSERT INTO training_suelen_refatorar_olap.dim_revendedor
SELECT 
         '1900-01-01' AS data_de,
         '2200-01-01' AS data_para,
         1 AS vesao,
         REVENDEDOR.id AS nk_id_revendedor,
         REVENDEDOR.revendedor,
         NEGOCIO.tipo_de_negocio,
         CIDADE.cidade,
         ESTADO.provincia_estado AS estado,
         PAIS.pais_regiao AS pais,
         REVENDEDOR.codigo_postal
                 
FROM training_suelen_refatorar_oltp.revendedor REVENDEDOR
JOIN training_suelen_refatorar_oltp.tipo_de_negocio NEGOCIO
        ON NEGOCIO.id = REVENDEDOR.id_tipo_de_negocio
JOIN training_suelen_refatorar_oltp.cidade_revendedor CIDADE
        ON CIDADE.id = REVENDEDOR.id_cidade_revendedor
JOIN training_suelen_refatorar_oltp.estado_revendedor ESTADO
        ON ESTADO.id = REVENDEDOR.id_estado_revendedor
JOIN training_suelen_refatorar_oltp.pais_regiao_cliente PAIS
        ON PAIS.id = REVENDEDOR.id_regiao_revendedor
------------------------------------------------------------------------------

DROP TABLE training_suelen_refatorar_olap.dim_produtos;
CREATE TABLE training_suelen_refatorar_olap.dim_produtos
(
        sk_produtos INT IDENTITY(1,1) PRIMARY KEY,
        data_de VARCHAR(64),
        data_para VARCHAR(64),
        versao INT,
        nk_id_produtos INT,
        sku VARCHAR(64), 
        modelo VARCHAR(64),
        cor VARCHAR(64),
        subcategoria VARCHAR(64),
        custo_padrao MONEY,
        preco_de_tabela MONEY

);


INSERT INTO training_suelen_refatorar_olap.dim_produtos
SELECT 
         '1900-01-01' AS data_de,
         '2200-01-01' AS data_para,
         1 AS vesao,
         PRODUTOS.id AS nk_id_produtos,
         PRODUTOS.sku,
         MODELO.modelo,
         COR.cor,
         SUB.subcategoria,
         PRODUTOS.custo_padrao,
         PRODUTOS.preco_de_tabela

                 
FROM training_suelen_refatorar_oltp.produtos PRODUTOS
JOIN training_suelen_refatorar_oltp.modelo MODELO
        ON MODELO.id = PRODUTOS.id_modelo
JOIN training_suelen_refatorar_oltp.cor COR
        ON COR.id = PRODUTOS.id_cor
JOIN training_suelen_refatorar_oltp.subcategoria SUB
        ON SUB.id = PRODUTOS.id_subcategoria

----------------------------------------------------------------------------

DROP TABLE training_suelen_refatorar_olap.dim_territorio;
CREATE TABLE training_suelen_refatorar_olap.dim_territorio
(
        sk_territorio INT IDENTITY(1,1) PRIMARY KEY,
        data_de VARCHAR(64),
        data_para VARCHAR(64),
        versao INT,
        nk_id_territorio INT,
        regiao VARCHAR(64), 
        pais VARCHAR(64),
        grupo VARCHAR(64)

);

INSERT INTO training_suelen_refatorar_olap.dim_territorio
SELECT 
         '1900-01-01' AS data_de,
         '2200-01-01' AS data_para,
         1 AS vesao,
         TERRITORIO.id AS nk_id_territorio,
         TERRITORIO.regiao,
         PAIS.país AS pais,
         GRUPO.grupo
              
FROM training_suelen_refatorar_oltp.territorio_de_vendas_regiao TERRITORIO
JOIN training_suelen_refatorar_oltp.territorio_de_vendas_pais PAIS
        ON PAIS.id = TERRITORIO.id_pais
JOIN training_suelen_refatorar_oltp.territorio_de_vendas_grupo GRUPO
        ON GRUPO.id = TERRITORIO.id_grupo

------------------------------------------------------------------------------------

DROP TABLE training_suelen_refatorar_olap.fato_vendas;
CREATE TABLE training_suelen_refatorar_olap.fato_vendas
(
        sk_vendas INT IDENTITY(1,1) PRIMARY KEY,
        data_de VARCHAR(64),
        data_para VARCHAR(64),
        versao INT,
        data_pedido VARCHAR(64),
        data_vencimento VARCHAR(64),
        data_de_envio VARCHAR(64),
        nk_id_vendas INT,
        chave_do_produto INT,
        sk_produtos INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_olap.dim_produtos(sk_produtos),
        sk_clientes INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_olap.dim_clientes(sk_clientes),
        sk_revendedor INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_olap.dim_revendedor(sk_revendedor),
        sk_territorio INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_olap.dim_territorio(sk_territorio),
        quantidade_do_pedido INT,
        preco_unitario MONEY,
        quantidade_extendida MONEY,
        preco_unitario_desconto_pct MONEY,
        custo_padrao_do_produto MONEY,
        custo_total_produto MONEY,
        valor_total_vendas MONEY,
        desconto_pct MONEY
);

INSERT INTO training_suelen_refatorar_olap.fato_vendas
SELECT 
         '1900-01-01' AS data_de,
         '2200-01-01' AS data_para,
         1 AS vesao,
         VENDAS.data_pedido,
         VENDAS.data_vencimento,
         VENDAS.data_de_envio,
         VENDAS.id AS nk_id_vendas,
         VENDAS.chave_do_produto,
         PRODUTOS.sk_produtos,
         D_CLIENTES.sk_clientes,
         D_REVENDEDOR.sk_revendedor,
         TERRITORIO.sk_territorio,
         VENDAS.quantidade_do_pedido,
         VENDAS.preco_unitario,
         VENDAS.quantidade_extendida,
         VENDAS.preco_unitario_desconto_pct,
         VENDAS.custo_padrao_do_produto,
         VENDAS.custo_total_produto,
         VENDAS.valor_total_vendas,
         
         CASE WHEN valor_total_vendas < quantidade_extendida THEN (quantidade_extendida - valor_total_vendas)
         ELSE 0
         END AS desconto_pct
         
       
FROM training_suelen_refatorar_oltp.dados_vendas VENDAS
JOIN training_suelen_refatorar_olap.dim_produtos PRODUTOS
        ON PRODUTOS.nk_id_produtos = VENDAS.id_produto
JOIN training_suelen_refatorar_olap.dim_clientes D_CLIENTES
        ON D_CLIENTES.nk_id_cliente = VENDAS.id_clientes
JOIN training_suelen_refatorar_olap.dim_revendedor D_REVENDEDOR
        ON D_REVENDEDOR.nk_id_revendedor = VENDAS.id_revendedor
JOIN training_suelen_refatorar_olap.dim_territorio TERRITORIO
        ON TERRITORIO.nk_id_territorio = VENDAS.id_territorio_vendas_regiao