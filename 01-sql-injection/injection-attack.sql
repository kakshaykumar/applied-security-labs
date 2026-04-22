-- SQL Injection demonstration with mitigation

-- ==========================================================
-- 1) Vulnerable pattern: dynamic SQL created via concatenation
-- ==========================================================

-- Application pseudo-construction (unsafe):
-- sql = "SELECT id, username FROM users WHERE username = '" || user_input ||
--       "' AND password = '" || pass_input || "';"

-- Example attacker payload:
-- user_input = admin' --
-- pass_input = irrelevant

-- Resulting query executed by DB (unsafe):
SELECT id, username
FROM users
WHERE username = 'admin' -- '
  AND password = 'irrelevant';

-- The trailing password check is commented out, enabling bypass.

-- Another classic payload in password field:
-- pass_input = ' OR '1'='1' --

-- Resulting query (unsafe):
SELECT id, username
FROM users
WHERE username = 'admin'
  AND password = '' OR '1'='1' -- ';

-- Logic now evaluates true for all rows, often authenticating attacker.


-- ==========================================================
-- 2) Secure pattern: parameterized query / prepared statement
-- ==========================================================

-- PostgreSQL-style parameter binding (safe):
PREPARE secure_login(text, text) AS
SELECT id, username
FROM users
WHERE username = $1
  AND password = crypt($2, password);

-- Execution with attacker input remains data, not SQL syntax:
EXECUTE secure_login('admin'' --', 'irrelevant');
EXECUTE secure_login('admin', ''' OR ''1''=''1'' --');

-- Both inputs are treated as literal values, preventing injection.

-- Additional mitigation notes:
-- - Use least-privilege DB credentials.
-- - Store password hashes (never plaintext passwords).
-- - Log and monitor repeated failed login attempts.
