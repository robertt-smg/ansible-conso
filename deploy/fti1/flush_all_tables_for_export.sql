-- Stored Procedure: flush_all_tables_for_export_combined
-- This procedure collects all tables in the given schema and issues a single FLUSH TABLES <table1>,<table2>,... FOR EXPORT statement.
DELIMITER //
CREATE PROCEDURE flush_all_tables_for_export_combined(IN in_schema VARCHAR(64))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE tab VARCHAR(64);
    DECLARE table_list TEXT DEFAULT '';
    DECLARE cur CURSOR FOR
        SELECT table_name FROM information_schema.tables WHERE table_schema = in_schema AND table_type = 'BASE TABLE';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO tab;
        IF done THEN
            LEAVE read_loop;
        END IF;
        IF table_list = '' THEN
            SET table_list = CONCAT('`', in_schema, '`.`', tab, '`');
        ELSE
            SET table_list = CONCAT(table_list, ',`', in_schema, '`.`', tab, '`');
        END IF;
    END LOOP;
    CLOSE cur;
    IF table_list != '' THEN
        SET @sql := CONCAT('FLUSH TABLES ', table_list, ' FOR EXPORT');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//
DELIMITER ;

-- Usage:
-- CALL flush_all_tables_for_export_combined('your_schema_name');