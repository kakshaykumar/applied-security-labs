-- ============================================================
-- Objective: Demonstrate a stacked query SQL injection
-- that transfers $500 from Homer Simpson (acct 256304)
-- to John Doe (acct 256101) via an unsanitized form field.
--
-- EDUCATIONAL USE ONLY
-- ============================================================


-- ── NORMAL QUERY (what the application runs for legitimate users) ──
--
-- When a user types their account number, the application runs:
--
--   SELECT Balance
--   FROM Accounts
--   WHERE Account_Num = <user_input>;
--
-- A legitimate user entering 256101 gets their balance returned.
-- The vulnerability: <user_input> is not sanitized before being
-- inserted into the query string.


-- ── THE INJECTION ─────────────────────────────────────────────────
--
-- John Doe enters the following as his "account number":
--
--   256101; UPDATE Accounts SET Balance = Balance - 500
--   WHERE Account_Num = 256304;
--   UPDATE Accounts SET Balance = Balance + 500
--   WHERE Account_Num = 256101;
--
-- The database receives and executes three statements:


-- Statement 1: Original SELECT (executes legitimately)
SELECT Balance
FROM Accounts
WHERE Account_Num = 256101;
-- Returns: $10,000 (John Doe's checking balance — valid result)


-- Statement 2: INJECTED — Debit Homer Simpson $500
-- The semicolon above terminated Statement 1.
-- This statement now executes as a separate query.
UPDATE Accounts
SET Balance = Balance - 500
WHERE Account_Num = 256304;
-- Homer Simpson's balance: $10,300 → $9,800


-- Statement 3: INJECTED — Credit John Doe $500
UPDATE Accounts
SET Balance = Balance + 500
WHERE Account_Num = 256101;
-- John Doe's balance: $10,000 → $10,500


-- ── EXPECTED STATE AFTER INJECTION ───────────────────────────────
--
-- Account 256101 (John Doe, Checking):   $10,000 → $10,500  (+$500)
-- Account 256304 (Homer Simpson, Check): $10,300 → $9,800   (-$500)
--
-- Verify:
SELECT Account_Num, Description, Balance
FROM Accounts
WHERE Account_Num IN (256101, 256304);


-- ── WHY THIS WORKS ────────────────────────────────────────────────
--
-- 1. No input validation: the form accepts semicolons and SQL keywords
-- 2. Stacked queries: the database executes multiple ;-separated statements
-- 3. No least privilege: the app DB user has UPDATE rights it shouldn't need
--    for a balance-checking form
--
-- The database cannot distinguish between application-issued SQL and
-- attacker-injected SQL. It executes both faithfully.


-- ── PARAMETERIZED QUERY FIX ───────────────────────────────────────
--
-- The correct implementation uses a parameterized query:
--
--   Python (psycopg2 / sqlite3):
--     cursor.execute(
--         "SELECT Balance FROM Accounts WHERE Account_Num = ?",
--         (account_num,)
--     )
--
--   Java (PreparedStatement):
--     PreparedStatement stmt = conn.prepareStatement(
--         "SELECT Balance FROM Accounts WHERE Account_Num = ?"
--     );
--     stmt.setInt(1, accountNum);
--
-- With parameterization, user input is ALWAYS treated as a data value,
-- never as SQL syntax. The injection string becomes a literal account
-- number value — no records match, nothing is modified.
