--CREATE SCHEMA training_suelen_refatorar_oltp;

DROP TABLE training_suelen_refatorar_oltp.dados_vendas;
CREATE TABLE training_suelen_refatorar_oltp.dados_vendas
(
        id INT IDENTITY(1,1) PRIMARY KEY,
        id_old INT,
        chave_do_produto INT,
        data_pedido VARCHAR(64),
        data_vencimento VARCHAR(64),
        data_de_envio VARCHAR(64),
        quantidade_do_pedido INT,
        preco_unitario MONEY,
        quantidade_extendida MONEY,
        preco_unitario_desconto_pct MONEY,
        custo_padrao_do_produto MONEY,
        custo_total_produto MONEY,
        valor_total_vendas MONEY,
        id_produto INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.produtos(id),
        id_clientes INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.clientes(id),
        id_revendedor INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.revendedor(id),
        id_territorio_vendas_regiao INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.territorio_de_vendas_regiao(id),
        desconto_pct MONEY
        
);

INSERT INTO training_suelen_refatorar_oltp.dados_vendas
SELECT 
        EX.id_old,
        EX.product_key AS chave_do_produto,
        EX.order_date AS data_pedido,
        EX.due_date AS data_vencimento,
        EX.ship_date AS data_de_envio,
        EX.order_quantity AS quantidade_do_pedido,
        EX.unit_price AS preco_unitario,
        EX.extended_amount AS quantidade_extendida,
        EX.unit_price_discount_pct AS preco_unitario_desconto_pct,
        EX.product_standard_cost AS custo_padrao_do_produto,
        EX.total_product_cost AS custo_total_produto,
        EX.sales_amount AS valor_total_vendas,
        PD.id AS id_produto,
        CL.id AS id_clientes,
        RV.id AS id_revendedor,
        TR.id AS id_territorio_vendas_regiao,
        
        CASE WHEN sales_amount < extended_amount THEN (extended_amount - sales_amount)
             ELSE 0
             END AS desconto_pct
             
FROM training_suelen.sales_data EX
JOIN training_suelen_refatorar_oltp.produtos PD
        ON PD.id_old = EX.product_key
JOIN training_suelen_refatorar_oltp.clientes CL
        ON CL.chave_do_cliente = EX.CustomerKey
JOIN training_suelen_refatorar_oltp.revendedor RV
        ON RV.chave_do_revendedor = EX.ResellerKey
JOIN training_suelen_refatorar_oltp.territorio_de_vendas_regiao TR
        ON TR.id_old = EX.SalesTerritoryKey
-------------------------------------------------------------------------------------------

DROP TABLE training_suelen_refatorar_oltp.cor;
CREATE TABLE training_suelen_refatorar_oltp.cor
(
        id INT IDENTITY(1,1) PRIMARY KEY,
        cor VARCHAR(64)
);

INSERT INTO training_suelen_refatorar_oltp.cor
SELECT 
        color AS cor
        
FROM training_suelen.products_excel
GROUP BY color
ORDER BY color;
-----------------------------------------------------------------------------------------

DROP TABLE training_suelen_refatorar_oltp.modelo;
CREATE TABLE training_suelen_refatorar_oltp.modelo
(
        id INT IDENTITY(1,1) PRIMARY KEY,
        modelo VARCHAR(64)
);

INSERT INTO training_suelen_refatorar_oltp.modelo
SELECT 
        model AS modelo
        
FROM training_suelen.products_excel
GROUP BY model
ORDER BY model;
-------------------------------------------------------------------------------------

DROP TABLE training_suelen_refatorar_oltp.subcategoria;
CREATE TABLE training_suelen_refatorar_oltp.subcategoria
(
        id INT IDENTITY(1,1) PRIMARY KEY,
        subcategoria VARCHAR(64),
        id_categoria INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.categoria(id)
);

INSERT INTO training_suelen_refatorar_oltp.subcategoria
SELECT 
        EX.subcategory AS subcategoria,
        CAT.id AS id_categoria
        
FROM training_suelen.products_excel EX
JOIN training_suelen_refatorar_oltp.categoria CAT
        ON CAT.categoria = EX.category
GROUP BY EX.subcategory,CAT.id
ORDER BY EX.subcategory,CAT.id;

------------------------------------------------------------------------------------

DROP TABLE training_suelen_refatorar_oltp.categoria;
CREATE TABLE training_suelen_refatorar_oltp.categoria
(
        id INT IDENTITY(1,1) PRIMARY KEY,
        categoria VARCHAR(64)
);

INSERT INTO training_suelen_refatorar_oltp.categoria
SELECT 
        category AS categoria
        
FROM training_suelen.products_excel
GROUP BY category
ORDER BY category;
-----------------------------------------------------------------------------------

DROP TABLE training_suelen_refatorar_oltp.produtos;
CREATE TABLE training_suelen_refatorar_oltp.produtos
(
        id INT IDENTITY(1,1) PRIMARY KEY,
        id_old INT,
        sku VARCHAR(64),
        custo_padrao MONEY,
        preco_de_tabela MONEY,
        id_modelo INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.modelo(id),
        id_subcategoria INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.subcategoria(id),
        id_cor INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.cor(id)
        
        
);


INSERT INTO training_suelen_refatorar_oltp.produtos
SELECT 
        EX.product_key AS id_old,
        EX.sku,
        EX.standard_cost AS custo_padrao,
        EX.list_price AS preco_de_tabela,
        MOD.id AS id_modelo,
        SUBCAT.id AS id_subcategoria,
        COR.id AS id_cor 

FROM training_suelen.products_excel EX
JOIN training_suelen_refatorar_oltp.modelo MOD
        ON MOD.modelo = EX.model
JOIN training_suelen_refatorar_oltp.subcategoria SUBCAT
        ON SUBCAT.subcategoria = EX.subcategory
JOIN training_suelen_refatorar_oltp.cor COR
        ON COR.cor = EX.color
GROUP BY  EX.product_key,EX.sku,EX.standard_cost,EX.list_price,MOD.id,SUBCAT.id,COR.id
ORDER BY  EX.product_key,EX.sku,EX.standard_cost,EX.list_price,MOD.id,SUBCAT.id,COR.id;
---------------------------------------------------------------------------------

DROP TABLE training_suelen_refatorar_oltp.cidade_cliente;
CREATE TABLE training_suelen_refatorar_oltp.cidade_cliente
(
        id INT IDENTITY(1,1) PRIMARY KEY,
        cidade VARCHAR(64)
);

INSERT INTO training_suelen_refatorar_oltp.cidade_cliente
SELECT 
        City AS cidade

FROM training_suelen.custumer_data
GROUP BY  City
ORDER BY  City;
--------------------------------------------------------------------------------
DROP TABLE training_suelen_refatorar_oltp.estado_cliente;
CREATE TABLE training_suelen_refatorar_oltp.estado_cliente
(
        id INT IDENTITY(1,1) PRIMARY KEY,
        estado_provincia VARCHAR(64)
);

INSERT INTO training_suelen_refatorar_oltp.estado_cliente
SELECT 
        "State-Province" AS estado

FROM training_suelen.custumer_data
GROUP BY  "State-Province"
ORDER BY  "State-Province";
-
------------------------------------------------------------------------------

DROP TABLE training_suelen_refatorar_oltp.pais_regiao_cliente;
CREATE TABLE training_suelen_refatorar_oltp.pais_regiao_cliente
(
        id INT IDENTITY(1,1) PRIMARY KEY,
        pais_regiao VARCHAR(64)
);

INSERT INTO training_suelen_refatorar_oltp.pais_regiao_cliente
SELECT 
        "Country-Region" AS pais_regiao

FROM training_suelen.custumer_data
GROUP BY  "Country-Region"
ORDER BY  "Country-Region";
----------------------------------------------------------------------------
DROP TABLE training_suelen_refatorar_oltp.clientes;
CREATE TABLE training_suelen_refatorar_oltp.clientes
(
        id INT IDENTITY(1,1) PRIMARY KEY,
        chave_do_cliente INT,
        identificação_do_cliente VARCHAR(64),
        cliente VARCHAR(64),
        id_cidade_cliente INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.cidade_cliente(id),
        id_estado_cliente INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.estado_cliente(id),
        id_pais_regiao_cliente INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.pais_regiao_cliente(id),
        cod_postal VARCHAR(64)
);

INSERT INTO training_suelen_refatorar_oltp.clientes
SELECT 
        EX.CustomerKey AS chave_do_cliente,
        EX."Customer ID" AS identificação_do_cliente,
        EX.Customer AS cliente,
        C.id AS id_cidade_cliente,
        E.id AS id_estado_cliente,
        P.id AS id_pais_regiao_cliente,
        EX."Postal Code" AS cod_postal

FROM training_suelen.custumer_data EX
JOIN training_suelen_refatorar_oltp.cidade_cliente C
        ON C.cidade = EX.City
JOIN training_suelen_refatorar_oltp.estado_cliente E
        ON E.estado_provincia = EX."State-Province"
JOIN training_suelen_refatorar_oltp.pais_regiao_cliente P
        ON P.pais_regiao = EX."Country-Region"
GROUP BY  EX.CustomerKey, EX."Customer ID",EX.Customer, C.id, E.id, P.id, EX."Postal Code"
ORDER BY  EX.CustomerKey, EX."Customer ID",EX.Customer, C.id, E.id, P.id, EX."Postal Code";
----------------------------------------------------------------------------

DROP TABLE training_suelen_refatorar_oltp.revendedor;
CREATE TABLE training_suelen_refatorar_oltp.revendedor
(
       id INT IDENTITY(1,1) PRIMARY KEY,
       chave_do_revendedor INT,
       id_vendedor VARCHAR(64),
       revendedor VARCHAR(64),
       id_tipo_de_negocio INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.tipo_de_negocio(id),
       id_cidade_revendedor INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.cidade_revendedor(id),
       id_estado_revendedor INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.estado_revendedor(id),
       id_regiao_revendedor INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.regiao_revendedor(id),
       codigo_postal VARCHAR(64)
);

INSERT INTO training_suelen_refatorar_oltp.revendedor
SELECT 
        EX.ResellerKey AS chave_do_revendedor,
        EX.reseller_id AS id_vendedor,
        EX.Reseller AS revendedor,
        T.id AS id_tipo_de_negocio,
        CR.id AS id_cidade_revendedor,
        ER.id AS id_estado_revendedor,
        RR.id AS id_regiao_revendedor,
        EX.postal_code AS codigo_postal
        
FROM training_suelen.reseller_data EX
JOIN training_suelen_refatorar_oltp.tipo_de_negocio T
        ON T.tipo_de_negocio = EX.business_type
JOIN training_suelen_refatorar_oltp.cidade_revendedor CR
        ON CR.cidade = EX.City
JOIN training_suelen_refatorar_oltp.estado_revendedor ER
        ON ER. provincia_estado = state_province
JOIN training_suelen_refatorar_oltp.regiao_revendedor RR
        ON RR.regiao = EX.region
GROUP BY  EX.ResellerKey, EX.reseller_id, EX.Reseller,T.id,CR.id,ER.id,RR.id,postal_code
ORDER BY  EX.ResellerKey, EX.reseller_id, EX.Reseller,T.id,CR.id,ER.id,RR.id,postal_code;
------------------------------------------------------------------------------


DROP TABLE training_suelen_refatorar_oltp.cidade_revendedor;
CREATE TABLE training_suelen_refatorar_oltp.cidade_revendedor
(
       id INT IDENTITY(1,1) PRIMARY KEY,
       cidade VARCHAR(64)
);

INSERT INTO training_suelen_refatorar_oltp.cidade_revendedor
SELECT 
        City AS cidade
        
FROM training_suelen.reseller_data
GROUP BY  City
ORDER BY  City;
------------------------------------------------------------

DROP TABLE training_suelen_refatorar_oltp.tipo_de_negocio;
CREATE TABLE training_suelen_refatorar_oltp.tipo_de_negocio
(
       id INT IDENTITY(1,1) PRIMARY KEY,
       tipo_de_negocio VARCHAR(64)
);

INSERT INTO training_suelen_refatorar_oltp.tipo_de_negocio
SELECT 
        business_type AS tipo_de_negocio
        
FROM training_suelen.reseller_data
GROUP BY  business_type
ORDER BY  business_type;
----------------------------------------------------------

DROP TABLE training_suelen_refatorar_oltp.estado_revendedor;
CREATE TABLE training_suelen_refatorar_oltp.estado_revendedor
(
       id INT IDENTITY(1,1) PRIMARY KEY,
       provincia_estado VARCHAR(64)
);

INSERT INTO training_suelen_refatorar_oltp.estado_revendedor
SELECT 
        state_province AS provincia_estado
        
FROM training_suelen.reseller_data
GROUP BY  state_province
ORDER BY  state_province;
------------------------------------------------------------
DROP TABLE training_suelen_refatorar_oltp.regiao_revendedor;
CREATE TABLE training_suelen_refatorar_oltp.regiao_revendedor
(
       id INT IDENTITY(1,1) PRIMARY KEY,
       regiao VARCHAR(64)
);

INSERT INTO training_suelen_refatorar_oltp.regiao_revendedor
SELECT 
        region AS regiao
        
FROM training_suelen.reseller_data
GROUP BY  region
ORDER BY  region;
-----------------------------------------------------------

DROP TABLE training_suelen_refatorar_oltp.territorio_de_vendas_regiao;
CREATE TABLE training_suelen_refatorar_oltp.territorio_de_vendas_regiao
(
       id INT IDENTITY(1,1) PRIMARY KEY,
       id_old INT,
       regiao VARCHAR(64),
       id_pais INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.territorio_de_vendas_pais(id),
       id_grupo INT NOT NULL FOREIGN KEY REFERENCES training_suelen_refatorar_oltp.territorio_de_vendas_grupo(id),
);

INSERT INTO training_suelen_refatorar_oltp.territorio_de_vendas_regiao
SELECT 
        EX.SalesTerritoryKey2 AS id_old,
        EX.Region3 AS regiao,
        TP.id AS id_pais,
        TG.id AS id_grupo
        
FROM training_suelen.sales_territory_data EX
JOIN training_suelen_refatorar_oltp.territorio_de_vendas_pais TP
        ON TP.país = EX.Country4
JOIN training_suelen_refatorar_oltp.territorio_de_vendas_grupo TG
        ON TG.grupo = EX.Group5
GROUP BY  EX.SalesTerritoryKey2,EX.Region3,TP.id,TG.id
ORDER BY  EX.SalesTerritoryKey2,EX.Region3,TP.id,TG.id;
----------------------------------------------------------

DROP TABLE training_suelen_refatorar_oltp.territorio_de_vendas_pais;
CREATE TABLE training_suelen_refatorar_oltp.territorio_de_vendas_pais
(
       id INT IDENTITY(1,1) PRIMARY KEY,
       país VARCHAR(64)
);

INSERT INTO training_suelen_refatorar_oltp.territorio_de_vendas_pais
SELECT 
        Country4 AS país
        
FROM training_suelen.sales_territory_data
GROUP BY  Country4
ORDER BY  Country4;
-----------------------------------------------------------------
