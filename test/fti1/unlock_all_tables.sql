-- Stored Procedure: unlock_all_tables
-- This procedure iterates over all tables in the given schema and issues UNLOCK TABLES for each (though UNLOCK TABLES is global, not per-table).
DELIMITER //
CREATE PROCEDURE unlock_all_tables(IN in_schema VARCHAR(64))
BEGIN
    -- UNLOCK TABLES in MySQL releases all table locks held by the current session, not per-table.
    -- For completeness, we iterate, but only one UNLOCK TABLES is needed per session.
    DECLARE done INT DEFAULT FALSE;
    DECLARE tab VARCHAR(64);
    DECLARE cur CURSOR FOR
        SELECT table_name FROM information_schema.tables WHERE table_schema = in_schema AND table_type = 'BASE TABLE';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO tab;
        IF done THEN
            LEAVE read_loop;
        END IF;
        -- No per-table UNLOCK, so just call UNLOCK TABLES once
    END LOOP;
    CLOSE cur;
    UNLOCK TABLES;
END//
DELIMITER ;

-- Usage:
-- CALL unlock_all_tables('your_schema_name');
