DROP FUNCTION IF EXISTS get_sudno_info(INT);

CREATE OR REPLACE FUNCTION get_sudno_info(sudno_id INT)
RETURNS TEXT AS $$
DECLARE
    result TEXT;
    sudno_exists BOOLEAN;
    last_loading RECORD;
BEGIN
    SELECT EXISTS(SELECT 1 FROM sudno WHERE identifikator = sudno_id) INTO sudno_exists;
    
    IF NOT sudno_exists THEN
        RETURN 'Судно с идентификатором ' || sudno_id || ' не существует.';
    ELSE
        SELECT 
            s.nazvanie AS sudno_nazvanie,
            s.port_pripiski AS port_pripiski,
            p.data AS data_pogruzki,
            mp.prichal AS mesto_pogruzki,
            p.stoimost AS stoimost_pogruzki
        INTO last_loading
        FROM pogruzka p
        INNER JOIN sudno s ON s.identifikator = p.sudno
        INNER JOIN mesta_pogruzki mp ON mp.identifikator = p.mesto_pogruzki
        WHERE p.sudno = sudno_id
        ORDER BY p.nomer_vedomosti DESC
        LIMIT 1;
        
        IF last_loading IS NULL THEN
            RETURN 'Судно "' || sudno_id || '" существует, но еще ни разу не грузилось.';
        ELSE
            result := 'Судно: ' || last_loading.sudno_nazvanie || 
                      ', Порт приписки: ' || last_loading.port_pripiski || 
                      ', Дата последней погрузки: ' || last_loading.data_pogruzki || 
                      ', Место погрузки: ' || last_loading.mesto_pogruzki || 
                      ', Стоимость погрузки: ' || last_loading.stoimost_pogruzki || ' руб.';
            RETURN result;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;


SELECT get_sudno_info(1); -- существует и грузилось
SELECT get_sudno_info(2); -- существует и грузилось
SELECT get_sudno_info(6); -- существует и не грузилось
SELECT get_sudno_info(999); -- не существует