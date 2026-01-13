-- Karny Bank Database Schema (SQLite)
-- All monetary values stored in agorot (Israeli cents: 1 ILS = 100 agorot)
-- All dates in ISO 8601 format (YYYY-MM-DD)

-- ============================================================================
-- ACCOUNTS TABLE
-- ============================================================================
CREATE TABLE accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    date_of_birth DATE NOT NULL,
    current_balance INTEGER NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (current_balance >= 0)
);

-- Example data:
-- INSERT INTO accounts (name, date_of_birth) VALUES
-- ('Maayan', '2011-08-16'),
-- ('Tomer', '2014-04-28'),
-- ('Or', '2016-01-21');

-- ============================================================================
-- TRANSACTIONS TABLE
-- Primary record of all account activity
-- ============================================================================
CREATE TABLE transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id INTEGER NOT NULL,
    type TEXT NOT NULL CHECK (type IN (
        'ALLOWANCE',
        'INTEREST',
        'BONUS',
        'MANUAL_DEPOSIT',
        'MANUAL_WITHDRAWAL'
    )),
    amount INTEGER NOT NULL,
    posted_date DATE NOT NULL,
    transaction_datetime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    balance_after INTEGER NOT NULL,
    notes TEXT,
    is_manual BOOLEAN NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE RESTRICT,
    CHECK (amount > 0),
    CHECK (balance_after >= 0)
);

-- Indexes for common queries
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_posted_date ON transactions(posted_date);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_account_posted ON transactions(account_id, posted_date);

-- ============================================================================
-- TRANSACTIONS AUDIT TABLE
-- Records all modifications to transactions for transparency
-- ============================================================================
CREATE TABLE transactions_audit (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    transaction_id INTEGER NOT NULL,
    changed_by TEXT NOT NULL DEFAULT 'parent',
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    previous_amount INTEGER NOT NULL,
    new_amount INTEGER NOT NULL,
    change_reason TEXT,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
);

CREATE INDEX idx_audit_transaction_id ON transactions_audit(transaction_id);
CREATE INDEX idx_audit_changed_at ON transactions_audit(changed_at);

-- ============================================================================
-- CONFIGURATION TABLE
-- Global settings for the app
-- ============================================================================
CREATE TABLE configuration (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Example data (values stored as strings, convert in application):
-- INSERT INTO configuration (key, value) VALUES
-- ('annual_interest_rate', '2.8'),
-- ('quarterly_bonus_rate', '1.2'),
-- ('weekly_allowance_day', '0');  -- 0=Sunday, 1=Monday, etc. (ISO 8601)

CREATE INDEX idx_configuration_updated_at ON configuration(updated_at);

-- ============================================================================
-- APP STATE TABLE
-- Tracks automation job execution to prevent duplicates
-- ============================================================================
CREATE TABLE app_state (
    key TEXT PRIMARY KEY,
    last_executed DATE,
    last_executed_datetime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Example keys:
-- 'last_allowance_check' - Last date allowance was processed
-- 'last_interest_applied' - Last date interest was applied
-- 'last_bonus_check_q1' - Last date Q1 bonus was checked
-- 'last_bonus_check_q2' - Last date Q2 bonus was checked
-- 'last_bonus_check_q3' - Last date Q3 bonus was checked
-- 'last_bonus_check_q4' - Last date Q4 bonus was checked

-- ============================================================================
-- VIEWS FOR REPORTING
-- ============================================================================

-- Quarterly withdrawal tracking (for bonus eligibility)
CREATE VIEW v_quarterly_withdrawals AS
SELECT
    account_id,
    strftime('%Y', posted_date) AS year,
    CASE
        WHEN strftime('%m', posted_date) IN ('01', '02', '03') THEN 'Q1'
        WHEN strftime('%m', posted_date) IN ('04', '05', '06') THEN 'Q2'
        WHEN strftime('%m', posted_date) IN ('07', '08', '09') THEN 'Q3'
        WHEN strftime('%m', posted_date) IN ('10', '11', '12') THEN 'Q4'
    END AS quarter,
    COUNT(*) AS withdrawal_count,
    SUM(amount) AS total_withdrawn
FROM transactions
WHERE type IN ('MANUAL_WITHDRAWAL')
GROUP BY account_id, year, quarter;

-- Account transaction summary
CREATE VIEW v_account_summary AS
SELECT
    a.id,
    a.name,
    a.date_of_birth,
    a.current_balance,
    (SELECT posted_date FROM transactions
     WHERE account_id = a.id AND type IN ('MANUAL_DEPOSIT', 'ALLOWANCE', 'INTEREST', 'BONUS')
     ORDER BY posted_date DESC LIMIT 1) AS last_deposit_date,
    (SELECT amount FROM transactions
     WHERE account_id = a.id AND type IN ('MANUAL_DEPOSIT', 'ALLOWANCE', 'INTEREST', 'BONUS')
     ORDER BY posted_date DESC LIMIT 1) AS last_deposit_amount,
    (SELECT posted_date FROM transactions
     WHERE account_id = a.id AND type = 'MANUAL_WITHDRAWAL'
     ORDER BY posted_date DESC LIMIT 1) AS last_withdrawal_date,
    (SELECT amount FROM transactions
     WHERE account_id = a.id AND type = 'MANUAL_WITHDRAWAL'
     ORDER BY posted_date DESC LIMIT 1) AS last_withdrawal_amount
FROM accounts a;

-- ============================================================================
-- STORED TRIGGERS (if using advanced SQLite features)
-- ============================================================================

-- Automatically update updated_at on configuration change
CREATE TRIGGER trg_configuration_updated
AFTER UPDATE ON configuration
FOR EACH ROW
BEGIN
    UPDATE configuration SET updated_at = CURRENT_TIMESTAMP
    WHERE key = NEW.key;
END;

-- Automatically update app_state timestamp
CREATE TRIGGER trg_app_state_updated
AFTER UPDATE ON app_state
FOR EACH ROW
BEGIN
    UPDATE app_state SET last_executed_datetime = CURRENT_TIMESTAMP
    WHERE key = NEW.key;
END;
