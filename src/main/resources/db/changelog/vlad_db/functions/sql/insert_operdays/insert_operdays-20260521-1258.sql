DROP FUNCTION IF EXISTS insert_operdays;;

CREATE FUNCTION insert_operdays()
    RETURNS TEXT
    NOT DETERMINISTIC
    MODIFIES SQL DATA
    READS SQL DATA
BEGIN
    DECLARE loop_date DATE;
    DECLARE current_date_time DATETIME;
    DECLARE current_date_value DATE;
    DECLARE current_day_value INT;
    DECLARE current_time_value TIME;
    DECLARE days_added INT DEFAULT 0;
    DECLARE start_date DATE;
    DECLARE end_date DATE;

    SET current_date_time = NOW();
    SET current_date_value = DATE(current_date_time);
    SET current_day_value = DAY(current_date_time);
    SET current_time_value = TIME(current_date_time);

    IF (current_day_value = 27 AND current_time_value < '07:00')
        OR current_day_value < 27 THEN
        SET start_date = current_date_value;
        SET end_date = LAST_DAY(current_date_value);
    ELSEIF NOT EXISTS (SELECT 1 FROM operational_day) THEN
        SET start_date = current_date_value;
        SET end_date = LAST_DAY(DATE_ADD(current_date_value, INTERVAL 1 MONTH));
    ELSE
        SET start_date = DATE_ADD(DATE_FORMAT(current_date_value, '%Y-%m-01'), INTERVAL 1 MONTH);
        SET end_date = LAST_DAY(DATE_ADD(current_date_value, INTERVAL 1 MONTH));
    END IF;

    SET loop_date = start_date;
    WHILE loop_date <= end_date
        DO
            IF NOT EXISTS (SELECT 1 FROM operational_day WHERE date = loop_date) THEN
                INSERT INTO operational_day (date, state_id)
                VALUES (loop_date, 1);
                SET days_added = days_added + 1;
            END IF;
            SET loop_date = DATE_ADD(loop_date, INTERVAL 1 DAY);
        END WHILE;

    IF days_added = 0 THEN
        RETURN 'Нет новых операционных дней для добавления.';
    ELSE
        RETURN CONCAT('Добавлено ', days_added, ' операционных дней за период с ',
                      start_date, ' по ', end_date, '.');
    END IF;
END;;