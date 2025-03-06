-- Visualizzare tutte le tabelle nel database
SHOW TABLES;
-- Visualizzare i contenuti delle tabelle
select
	*
from
	cliente;
    
select
	*
from
	conto;
    
select
	*
from
	tipo_conto;
    
select
	*
from
	tipo_transazione;
    
select
	*
from
	transazioni;

-- Mostra la struttura di ogni tabella
DESCRIBE cliente;
DESCRIBE conto;
DESCRIBE tipo_conto;
DESCRIBE tipo_transazione;
DESCRIBE transazioni;

-- 1. Calcolare l'età del cliente e ottenere le informazioni di base
WITH cliente_base AS (
    SELECT 
        id_cliente,
        nome,
        cognome,
        YEAR(CURDATE()) - YEAR(data_nascita) AS eta
    FROM cliente
),

-- 2. Numero totale di conti per cliente
numero_conti AS (
    SELECT 
        id_cliente,
        COUNT(id_conto) AS numero_conti
    FROM conto
    GROUP BY id_cliente
),

-- 3. Numero di conti per tipologia di conto
numero_conti_per_tipo AS (
    SELECT 
        c.id_cliente,
        tc.id_tipo_conto,
        COUNT(c.id_conto) AS numero_conti_per_tipo
    FROM conto c
    JOIN tipo_conto tc ON c.id_tipo_conto = tc.id_tipo_conto
    GROUP BY c.id_cliente, tc.id_tipo_conto
),

-- 4. Numero di transazioni in uscita per cliente
numero_transazioni_uscita AS (
    SELECT 
        c.id_cliente,
        COUNT(t.id_tipo_trans) AS numero_transazioni_uscita
    FROM transazioni t
    JOIN conto c ON t.id_conto = c.id_conto
    JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
    WHERE tt.segno = '-'
    GROUP BY c.id_cliente
),

-- 5. Numero di transazioni in entrata per cliente
numero_transazioni_entrata AS (
    SELECT 
        c.id_cliente,
        COUNT(t.id_tipo_trans) AS numero_transazioni_entrata
    FROM transazioni t
    JOIN conto c ON t.id_conto = c.id_conto
    JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
    WHERE tt.segno = '+'
    GROUP BY c.id_cliente
),

-- 6. Importo totale transato in uscita per cliente
importo_totale_uscita AS (
    SELECT 
        c.id_cliente,
        SUM(t.importo) AS importo_totale_uscita
    FROM transazioni t
    JOIN conto c ON t.id_conto = c.id_conto
    JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
    WHERE tt.segno = '-'
    GROUP BY c.id_cliente
),

-- 7. Importo totale transato in entrata per cliente
importo_totale_entrata AS (
    SELECT 
        c.id_cliente,
        SUM(t.importo) AS importo_totale_entrata
    FROM transazioni t
    JOIN conto c ON t.id_conto = c.id_conto
    JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
    WHERE tt.segno = '+'
    GROUP BY c.id_cliente
),

-- 8. Numero di transazioni in uscita per tipologia di conto
numero_transazioni_uscita_per_tipo AS (
    SELECT 
        c.id_cliente,
        tc.id_tipo_conto,
        COUNT(t.id_tipo_trans) AS numero_transazioni_uscita_per_tipo
    FROM transazioni t
    JOIN conto c ON t.id_conto = c.id_conto
    JOIN tipo_conto tc ON c.id_tipo_conto = tc.id_tipo_conto
    JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
    WHERE tt.segno = '-'
    GROUP BY c.id_cliente, tc.id_tipo_conto
),

-- 9. Numero di transazioni in entrata per tipologia di conto
numero_transazioni_entrata_per_tipo AS (
    SELECT 
        c.id_cliente,
        tc.id_tipo_conto,
        COUNT(t.id_tipo_trans) AS numero_transazioni_entrata_per_tipo
    FROM transazioni t
    JOIN conto c ON t.id_conto = c.id_conto
    JOIN tipo_conto tc ON c.id_tipo_conto = tc.id_tipo_conto
    JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
    WHERE tt.segno = '+'
    GROUP BY c.id_cliente, tc.id_tipo_conto
),

-- 10. Importo transato in uscita per tipologia di conto
importo_uscita_per_tipo AS (
    SELECT 
        c.id_cliente,
        tc.id_tipo_conto,
        SUM(t.importo) AS importo_uscita_per_tipo
    FROM transazioni t
    JOIN conto c ON t.id_conto = c.id_conto
    JOIN tipo_conto tc ON c.id_tipo_conto = tc.id_tipo_conto
    JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
    WHERE tt.segno = '-'
    GROUP BY c.id_cliente, tc.id_tipo_conto
),

-- 11. Importo transato in entrata per tipologia di conto
importo_entrata_per_tipo AS (
    SELECT 
        c.id_cliente,
        tc.id_tipo_conto,
        SUM(t.importo) AS importo_entrata_per_tipo
    FROM transazioni t
    JOIN conto c ON t.id_conto = c.id_conto
    JOIN tipo_conto tc ON c.id_tipo_conto = tc.id_tipo_conto
    JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
    WHERE tt.segno = '+'
    GROUP BY c.id_cliente, tc.id_tipo_conto
)

-- 12. Creare la tabella finale con tutte le aggregazioni
SELECT 
    cb.id_cliente,
    cb.nome,
    cb.cognome,
    cb.eta,
    COALESCE(nc.numero_conti, 0) AS numero_conti,
    COALESCE(ntu.numero_transazioni_uscita, 0) AS numero_transazioni_uscita,
    COALESCE(nte.numero_transazioni_entrata, 0) AS numero_transazioni_entrata,
    COALESCE(iu.importo_totale_uscita, 0) AS importo_totale_uscita,
    COALESCE(ie.importo_totale_entrata, 0) AS importo_totale_entrata,
    
    -- Per ogni tipologia di conto, numero conti, transazioni e importi
    COALESCE(nctp.numero_conti_per_tipo, 0) AS numero_conti_per_tipo_base,
    COALESCE(nctp1.numero_conti_per_tipo, 0) AS numero_conti_per_tipo_business,
    COALESCE(nctp2.numero_conti_per_tipo, 0) AS numero_conti_per_tipo_privati,
    COALESCE(nctp3.numero_conti_per_tipo, 0) AS numero_conti_per_tipo_famiglie,
    
    COALESCE(ntut.numero_transazioni_uscita_per_tipo, 0) AS transazioni_uscita_base,
    COALESCE(ntut1.numero_transazioni_uscita_per_tipo, 0) AS transazioni_uscita_business,
    COALESCE(ntut2.numero_transazioni_uscita_per_tipo, 0) AS transazioni_uscita_privati,
    COALESCE(ntut3.numero_transazioni_uscita_per_tipo, 0) AS transazioni_uscita_famiglie,
    
    COALESCE(ntet.numero_transazioni_entrata_per_tipo, 0) AS transazioni_entrata_base,
    COALESCE(ntet1.numero_transazioni_entrata_per_tipo, 0) AS transazioni_entrata_business,
    COALESCE(ntet2.numero_transazioni_entrata_per_tipo, 0) AS transazioni_entrata_privati,
    COALESCE(ntet3.numero_transazioni_entrata_per_tipo, 0) AS transazioni_entrata_famiglie,
    
    COALESCE(iut.importo_uscita_per_tipo, 0) AS importo_uscita_base,
    COALESCE(iut1.importo_uscita_per_tipo, 0) AS importo_uscita_business,
    COALESCE(iut2.importo_uscita_per_tipo, 0) AS importo_uscita_privati,
    COALESCE(iut3.importo_uscita_per_tipo, 0) AS importo_uscita_famiglie,
    
    COALESCE(iet.importo_entrata_per_tipo, 0) AS importo_entrata_base,
    COALESCE(iet1.importo_entrata_per_tipo, 0) AS importo_entrata_business,
    COALESCE(iet2.importo_entrata_per_tipo, 0) AS importo_entrata_privati,
    COALESCE(iet3.importo_entrata_per_tipo, 0) AS importo_entrata_famiglie

FROM cliente_base cb

-- Join con numero di conti
LEFT JOIN numero_conti nc ON cb.id_cliente = nc.id_cliente

-- Join con numero transazioni e importi
LEFT JOIN numero_transazioni_uscita ntu ON cb.id_cliente = ntu.id_cliente
LEFT JOIN numero_transazioni_entrata nte ON cb.id_cliente = nte.id_cliente
LEFT JOIN importo_totale_uscita iu ON cb.id_cliente = iu.id_cliente
LEFT JOIN importo_totale_entrata ie ON cb.id_cliente = ie.id_cliente

-- Join per i conti per tipologia di conto
LEFT JOIN numero_conti_per_tipo nctp ON cb.id_cliente = nctp.id_cliente AND nctp.id_tipo_conto = 1 -- Base
LEFT JOIN numero_conti_per_tipo nctp1 ON cb.id_cliente = nctp1.id_cliente AND nctp1.id_tipo_conto = 2 -- Business
LEFT JOIN numero_conti_per_tipo nctp2 ON cb.id_cliente = nctp2.id_cliente AND nctp2.id_tipo_conto = 3 -- Privati
LEFT JOIN numero_conti_per_tipo nctp3 ON cb.id_cliente = nctp3.id_cliente AND nctp3.id_tipo_conto = 4 -- Famiglie

-- Join per le transazioni in uscita per tipologia di conto
LEFT JOIN numero_transazioni_uscita_per_tipo ntut ON cb.id_cliente = ntut.id_cliente AND ntut.id_tipo_conto = 1 -- Base
LEFT JOIN numero_transazioni_uscita_per_tipo ntut1 ON cb.id_cliente = ntut1.id_cliente AND ntut1.id_tipo_conto = 2 -- Business
LEFT JOIN numero_transazioni_uscita_per_tipo ntut2 ON cb.id_cliente = ntut2.id_cliente AND ntut2.id_tipo_conto = 3 -- Privati
LEFT JOIN numero_transazioni_uscita_per_tipo ntut3 ON cb.id_cliente = ntut3.id_cliente AND ntut3.id_tipo_conto = 4 -- Famiglie

-- Join per le transazioni in entrata per tipologia di conto
LEFT JOIN numero_transazioni_entrata_per_tipo ntet ON cb.id_cliente = ntet.id_cliente AND ntet.id_tipo_conto = 1 -- Base
LEFT JOIN numero_transazioni_entrata_per_tipo ntet1 ON cb.id_cliente = ntet1.id_cliente AND ntet1.id_tipo_conto = 2 -- Business
LEFT JOIN numero_transazioni_entrata_per_tipo ntet2 ON cb.id_cliente = ntet2.id_cliente AND ntet2.id_tipo_conto = 3 -- Privati
LEFT JOIN numero_transazioni_entrata_per_tipo ntet3 ON cb.id_cliente = ntet3.id_cliente AND ntet3.id_tipo_conto = 4 -- Famiglie

-- Join per gli importi usciti per tipologia di conto
LEFT JOIN importo_uscita_per_tipo iut ON cb.id_cliente = iut.id_cliente AND iut.id_tipo_conto = 1 -- Base
LEFT JOIN importo_uscita_per_tipo iut1 ON cb.id_cliente = iut1.id_cliente AND iut1.id_tipo_conto = 2 -- Business
LEFT JOIN importo_uscita_per_tipo iut2 ON cb.id_cliente = iut2.id_cliente AND iut2.id_tipo_conto = 3 -- Privati
LEFT JOIN importo_uscita_per_tipo iut3 ON cb.id_cliente = iut3.id_cliente AND iut3.id_tipo_conto = 4 -- Famiglie

-- Join per gli importi entrati per tipologia di conto
LEFT JOIN importo_entrata_per_tipo iet ON cb.id_cliente = iet.id_cliente AND iet.id_tipo_conto = 1 -- Base
LEFT JOIN importo_entrata_per_tipo iet1 ON cb.id_cliente = iet1.id_cliente AND iet1.id_tipo_conto = 2 -- Business
LEFT JOIN importo_entrata_per_tipo iet2 ON cb.id_cliente = iet2.id_cliente AND iet2.id_tipo_conto = 3 -- Privati
LEFT JOIN importo_entrata_per_tipo iet3 ON cb.id_cliente = iet3.id_cliente AND iet3.id_tipo_conto = 4 -- Famiglie;
