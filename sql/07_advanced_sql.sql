-- =========================================================
-- 1. TRANSACCIÓN EXPLÍCITA
-- Objetivo: insertar una fila de prueba en fct_stock
-- y confirmar la transacción
-- =========================================================
BEGIN TRANSACTION;

INSERT INTO fct_stock (store_id, product_id, quantity)
VALUES (1, 1, 999);

COMMIT;

-- =========================================================
-- 2. TRIGGER DE CALIDAD DE DATOS
-- Objetivo: impedir descuentos inválidos en fct_sales
-- =========================================================
DROP TRIGGER IF EXISTS trg_validate_discount;

CREATE TRIGGER trg_validate_discount
BEFORE INSERT ON fct_sales
FOR EACH ROW
WHEN NEW.discount < 0 OR NEW.discount > 1
BEGIN
    SELECT RAISE(FAIL, 'Invalid discount: must be between 0 and 1');
END;