# SQL Injection Lab

This lab demonstrates how string-concatenated SQL can be abused and how parameterized queries prevent exploitation.

## Attack mechanics

A vulnerable login query often looks like:

```sql
SELECT id, username
FROM users
WHERE username = '<input_username>'
  AND password = '<input_password>';
```

If an attacker submits `' OR '1'='1' --` as input, they can alter query logic and bypass authentication.

## Step-by-step

1. Identify dynamic SQL built with raw user input.
2. Submit payloads that break out of quoted strings.
3. Use boolean manipulation (for example, `OR 1=1`) to force true conditions.
4. Observe unauthorized access.
5. Replace concatenation with placeholders and bound parameters.

## OWASP context

This maps directly to the OWASP Top 10 category **A03:2021 – Injection**.
Mitigation includes parameterized queries, least-privilege DB users, input validation, and centralized error handling.
