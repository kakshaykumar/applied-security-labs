# Lab 01 — SQL Injection Attack

**Type:** Multi-statement SQL injection (stacked queries)
**Target:** Simulated banking database
**Objective:** Transfer $500 from Homer Simpson's account to John Doe's account via a vulnerable form field

> ⚠️ **Educational context:** This lab was completed as part of a academic course to demonstrate understanding of injection vulnerabilities. The database is a classroom simulation. This is not a template for attacking real systems.

---

## Database Schema

```
Customers
┌─────────────┬───────────────┬──────────────────────────────┐
│ SSN         │ Name          │ Address                      │
├─────────────┼───────────────┼──────────────────────────────┤
│ 123-45-6789 │ John Doe      │ 4400 University Dr, Fairfax  │
│ 987-65-4321 │ Homer Simpson │ 10 First St, Springfield OH  │
└─────────────┴───────────────┴──────────────────────────────┘

Customer ←→ Account (Foreign Key)
┌─────────────┬─────────┐
│ 123-45-6789 │ 256101  │  ← John Doe's Checking
│ 123-45-6789 │ 256202  │  ← John Doe's Savings
│ 987-65-4321 │ 256304  │  ← Homer Simpson's Checking
└─────────────┴─────────┘

Accounts
┌─────────────┬─────────────┬─────────┐
│ Account_Num │ Description │ Balance │
├─────────────┼─────────────┼─────────┤
│ 256101      │ Checking    │ $10,000 │
│ 256202      │ Savings     │ $12,000 │
│ 256304      │ Checking    │ $10,300 │
└─────────────┴─────────────┴─────────┘
```

---

## The Vulnerable Query

The application takes a user-supplied account number and plugs it directly into a SQL query:

```sql
SELECT Balance
FROM Accounts
WHERE Account_Num = <number>;
```

The problem: `<number>` is not sanitized. Whatever the user types becomes part of the executed SQL. A legitimate user types `256101` and gets their balance. A malicious user types something that terminates the original query and appends additional statements.

---

## The Injection

See [`injection-attack.sql`](injection-attack.sql) for the full annotated code.

**Input entered in the account number field:**
```sql
256101; UPDATE Accounts SET Balance = Balance - 500 WHERE Account_Num = 256304; UPDATE Accounts SET Balance = Balance + 500 WHERE Account_Num = 256101;
```

**What the database actually executes:**
```sql
-- Original query (using John Doe's valid account number)
SELECT Balance FROM Accounts WHERE Account_Num = 256101;

-- Injected statement 1: debit Homer Simpson
UPDATE Accounts SET Balance = Balance - 500 WHERE Account_Num = 256304;

-- Injected statement 2: credit John Doe
UPDATE Accounts SET Balance = Balance + 500 WHERE Account_Num = 256101;
```

---

## How It Works — Step by Step

**Step 1 — Account number legitimacy**
John Doe enters his own account number (`256101`) as the starting value. This means the first part of the query executes legitimately and returns his balance. The application won't immediately reject the input as invalid.

**Step 2 — Semicolon as statement terminator**
The `;` terminates the `SELECT` statement. In databases that support stacked queries (multiple statements separated by semicolons in a single execution), everything after the semicolon is treated as a new statement. The original query ends; the attacker's statements begin.

**Step 3 — First UPDATE (debit)**
`UPDATE Accounts SET Balance = Balance - 500 WHERE Account_Num = 256304` targets Homer Simpson's checking account (256304) and subtracts $500. Balance goes from $10,300 to $9,800.

**Step 4 — Second UPDATE (credit)**
`UPDATE Accounts SET Balance = Balance + 500 WHERE Account_Num = 256101` credits John Doe's checking account (256101). Balance goes from $10,000 to $10,500.

Both statements execute in a single round-trip. The database has no way to distinguish between legitimate application queries and injected ones — it just executes valid SQL.

---

## Expected Result

| Account | Owner | Before | After | Change |
|---|---|---|---|---|
| 256101 | John Doe (Checking) | $10,000 | $10,500 | +$500 |
| 256304 | Homer Simpson (Checking) | $10,300 | $9,800 | -$500 |

---

## Why This Attack Works

The fundamental vulnerability is **lack of input validation** — the application trusts user input and passes it directly to the database engine. The database can't tell the difference between input that came from the application logic and input that came from a malicious user.

This is a stacked query injection, which requires the database to support multiple statements in one call. Not all databases support this by default (PostgreSQL and SQL Server do; MySQL has some restrictions). But the more common injection pattern — modifying the `WHERE` clause — doesn't even require stacked queries.

---

## Mitigations

**Parameterized queries (prepared statements)** — the correct fix. Instead of building the query string by concatenation, the query structure is defined separately from the data:

```python
# Vulnerable
query = f"SELECT Balance FROM Accounts WHERE Account_Num = {user_input}"

# Fixed — parameterized
cursor.execute("SELECT Balance FROM Accounts WHERE Account_Num = ?", (user_input,))
```

With parameterization, the user input is treated as a data value — never as SQL syntax. Even if someone enters `256101; UPDATE...`, the entire string is treated as the account number value, the query finds no match, and nothing is modified.

**Additional controls:**
- Database privilege separation — the application's database user should only have SELECT/INSERT/UPDATE on tables it needs, not DDL rights
- Input validation — reject account numbers that contain anything other than digits
- WAF rules — detect and block common injection patterns at the network layer
- Principle of least privilege on database accounts

---

## Related CVEs and Real-World Impact

SQL injection consistently ranks in OWASP's Top 10 application security risks. Notable real-world examples include the Heartland Payment Systems breach (2008, ~134 million cards), the TalkTalk breach (2015, ~157,000 records), and countless smaller incidents. The mechanics are the same as this lab — untrusted input concatenated into a database query.
