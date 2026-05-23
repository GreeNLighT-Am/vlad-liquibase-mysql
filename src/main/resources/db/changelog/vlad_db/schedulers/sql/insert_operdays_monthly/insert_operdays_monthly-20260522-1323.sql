CREATE EVENT IF NOT EXISTS insert_operdays_monthly_evt
    ON SCHEDULE EVERY 1 MONTH
        STARTS DATE_FORMAT(CURDATE(), '%Y-%m-27 07:00:00')
    ON COMPLETION PRESERVE
    ENABLE
    COMMENT 'Запуск генерации опердней 27-го числа каждого месяца в 07:00'
    DO
    BEGIN
        DECLARE result_text TEXT;
        SELECT insert_operdays() INTO result_text;
    END;;