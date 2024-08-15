-- 01 user defined function full name

CREATE OR REPLACE FUNCTION fn_full_name(first_name VARCHAR, last_name VARCHAR)
RETURNS VARCHAR
AS
$$
	DECLARE full_name VARCHAR;
	BEGIN
		SELECT INITCAP(CONCAT(first_name, ' ', last_name)) INTO full_name;
		RETURN full_name;
	END;
$$
LANGUAGE plpgsql;

-- 02 User defined function future value

CREATE OR REPLACE FUNCTION fn_calculate_future_value(initial_sum DECIMAL, interest_rate DECIMAL, num_of_years INT)
RETURNS DECIMAL
AS
$$
	BEGIN
		RETURN TRUNC(initial_sum * POWER(1 + interest_rate, num_of_years), 4);
	END;
$$
LANGUAGE plpgsql;


SELECT fn_calculate_future_value (1000, 0.1, 5);

-- 03 Function is word comprised

CREATE OR REPLACE FUNCTION fn_is_word_comprised(set_of_letters VARCHAR(50), word VARCHAR(50))
RETURNS BOOLEAN
AS
$$
BEGIN
	RETURN (SELECT TRIM(LOWER(word), LOWER(set_of_letters))) = '';
END;
$$
LANGUAGE plpgsql;

SELECT fn_is_word_comprised('ois tmiah%f', 'Sofia');

-- 04 Game Over

CREATE OR REPLACE FUNCTION fn_is_game_over(is_game_over BOOLEAN)
RETURNS TABLE (
	"name" VARCHAR(50),
	game_type_id INT,
	is_finished BOOLEAN
)
AS
$$
BEGIN
	RETURN QUERY
	SELECT
		g."name",
		g.game_type_id,
		g.is_finished
	FROM
		games AS g
	WHERE g.is_finished = is_game_over;
END;
$$
LANGUAGE plpgsql;


SELECT * FROM fn_is_game_over(TRUE);

-- 05 Difficulty level

CREATE OR REPLACE FUNCTION fn_difficulty_level("level" INT)
RETURNS VARCHAR(50)
AS
$$
DECLARE
	diff_level VARCHAR(50);
BEGIN
	IF "level" <= 40 THEN
		diff_level := 'Normal Difficulty';
	ELSEIF "level" BETWEEN 41 AND 60 THEN
		diff_level := 'Nightmare Difficulty';
	ELSE 
		diff_level := 'Hell Difficulty';
	END IF;
	
	RETURN diff_level;
END;
$$
LANGUAGE plpgsql;

SELECT
	user_id,
	"level",
	cash,
	fn_difficulty_level("level")
FROM
	users_games
ORDER BY
	user_id;

-- 06 Cash in User Games Odd Rows
CREATE OR REPLACE FUNCTION fn_cash_in_users_games(game_name VARCHAR(50))
RETURNS DECIMAL
AS
$$
DECLARE
	total_price DECIMAL;
BEGIN
	SELECT
		SUM(a.cash) INTO total_price
	FROM (
		SELECT
			g.name,
			ug.cash,
			ROW_NUMBER() OVER (PARTITION BY g.name ORDER BY ug.cash DESC) AS odd_even
		FROM
			games AS g
		JOIN
			users_games AS ug
		ON 
			g.id = ug.game_id
		WHERE
			g.name = game_name) a
	WHERE a.odd_even % 2 = 1;
	RETURN total_price::DECIMAL(10, 2);
END;
$$
LANGUAGE plpgsql;

SELECT * FROM fn_cash_in_users_games('Delphinium Pacific Giant');
-- 07 Retriving account holders
CREATE OR REPLACE PROCEDURE sp_retrieving_holders_with_balance_higher_than(searched_balance NUMERIC)
AS
$$
DECLARE
	i RECORD;
BEGIN
	FOR i IN (SELECT
		CONCAT(ah.first_name, ' ', ah.last_name) AS full_name,
		SUM(a.balance) AS balance
	FROM
		accounts AS a
	JOIN
		account_holders AS ah
	ON
		ah.id = a.account_holder_id
	GROUP BY CONCAT(ah.first_name, ' ', ah.last_name)
	HAVING SUM(a.balance) > searched_balance
	ORDER BY full_name) LOOP
	
	RAISE NOTICE 'NOTICE: % - %', i.full_name, i.balance;
	END LOOP;	
END;
$$
LANGUAGE plpgsql;

CALL sp_retrieving_holders_with_balance_higher_than(20000);

-- 08 Deposit Money
CREATE OR REPLACE PROCEDURE sp_deposit_money(account_id INT, money_amount NUMERIC(10, 4))
AS
$$
BEGIN
	UPDATE 
		accounts
	SET 
		balance = balance + money_amount
	WHERE
		"id" = account_id;
	COMMIT;
END;
$$
LANGUAGE plpgsql;


SELECT * FROM accounts WHERE id = 1;
CALL sp_deposit_money(1, 200)

-- 09 Withdraw Money
CREATE OR REPLACE PROCEDURE sp_withdraw_money(account_id INT, money_amount NUMERIC(20, 4))
AS
$$
DECLARE
	current_balance NUMERIC(20,4);
BEGIN
	-- UPDATE 
	-- 	accounts
	-- SET 
	-- 	balance = balance - money_amount
	-- WHERE
	--	"id" = account_id;
	SELECT 
		balance INTO current_balance
	FROM 
		accounts
	WHERE "id" = account_id;

	IF current_balance - money_amount < 0 THEN
		RAISE NOTICE 'NOTICE: Insufficient balance to withdraw %', money_amount;
	ELSE
		UPDATE 
			accounts
		SET 
			balance = balance - money_amount
		WHERE
			"id" = account_id;
		COMMIT;
	END IF;
END;
$$
LANGUAGE plpgsql;


SELECT * FROM accounts WHERE id = 6;
CALL sp_withdraw_money(6, 5437.0000)

-- 10 Money Transfer
CREATE OR REPLACE PROCEDURE sp_transfer_money(sender_id INT, receiver_id INT, amount NUMERIC(4))
AS
$$
DECLARE
	current_balance NUMERIC;
BEGIN
	CALL sp_withdraw_money(sender_id, amount);
	CALL sp_deposit_money(receiver_id, amount);

	SELECT balance INTO current_balance FROM accounts WHERE "id" = sender_id;

	IF current_balance < 0 THEN
		ROLLBACK;
	END IF;
END;
$$
LANGUAGE plpgsql;
-- 11 Delete Procedure
DROP PROCEDURE sp_retrieving_holders_with_balance_higher_than;
-- 12 Log Accounts Trigger
CREATE TABLE IF NOT EXISTS logs(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	account_id INT,
	old_sum NUMERIC(20, 4),
	new_sum NUMERIC(20, 4)
);

CREATE FUNCTION trigger_fn_insert_new_entry_into_logs()
RETURNS TRIGGER
AS
$$
BEGIN
	INSERT INTO logs(account_id, old_sum, new_sum)
		VALUES
		(
			OLD."id",
			OLD.balance,
			NEW.balance
		);
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_account_balance_change
AFTER UPDATE OF
	balance
ON
	accounts
FOR EACH ROW
WHEN
	(old.balance <> new.balance)
EXECUTE FUNCTION trigger_fn_insert_new_entry_into_logs();

-- 13 Notification Email on balance change
CREATE TABLE IF NOT EXISTS notification_emails(
	"id" SERIAL,
	recepient_id INT, 
	subject VARCHAR(255),
	body TEXT
);

CREATE OR REPLACE FUNCTION trigger_fn_send_email_on_balance_change()
RETURNS TRIGGER
AS
$$
BEGIN
	INSERT INTO notification_emails(
		recepient_id,
		subject,
		body
	)
	VALUES
		(
			NEW.account_id,
			'Balance change for account: ' || NEW.account_id,
			'On '|| DATE(now()) ||' your balance was changed from ' || OLD.new_sum || ' to ' || NEW.new_sum || '.'
		);
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_send_email_on_balance_change
AFTER UPDATE
	ON logs
FOR EACH ROW
WHEN
	(OLD.new_sum <> NEW.new_sum)
EXECUTE FUNCTION trigger_fn_send_email_on_balance_change();
