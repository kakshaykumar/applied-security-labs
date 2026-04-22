# Applied Security Labs

---

## Overview

Two applied security labs from my Cybersecurity Fundamentals course — one offensive, one cryptographic. Both involve working with real artifacts: actual SQL injection code and a real RSA keypair with an encrypted file.

The SQL injection lab demonstrates how a multi-statement injection attack works against a vulnerable database — specifically, how an attacker could manipulate financial records by exploiting missing input validation. The RSA lab involves generating a real 2048-bit keypair, encrypting a message with the public key, and decrypting it with the private key.

These connect directly to two areas I'm building depth in: offensive security techniques (relevant to my OSCP prep) and applied cryptography.

---

## Labs

| # | Lab | Key Artifact | Skill |
|---|---|---|---|
| 01 | [SQL Injection Attack](01-sql-injection/) | `injection-attack.sql` | Offensive security, SQL, input validation |
| 02 | [RSA Public/Private Key](02-rsa-cryptography/) | `public.pem`, `private.pem`, `data.txt.enc` | Asymmetric cryptography, OpenSSL, key management |

---

## Lab 01 — SQL Injection Attack

Given a simplified banking database schema with two customers — John Doe and Homer Simpson — the task was to craft a SQL injection attack that would allow John Doe to steal $500 from Homer Simpson's account by exploiting a vulnerable form field.

The injection uses a semicolon to break out of the original `SELECT` query and append two `UPDATE` statements — one debiting Homer Simpson's account, one crediting John Doe's. The attack succeeds because the application accepts raw user input directly into the SQL query without any sanitization.

```sql
256101; UPDATE Accounts SET Balance = Balance - 500 WHERE Account_Num = 256304;
UPDATE Accounts SET Balance = Balance + 500 WHERE Account_Num = 256101;
```

The lab also covers why this works and how parameterized queries prevent it.

→ [Full attack code and analysis](01-sql-injection/injection-attack.sql)
→ [Detailed write-up](01-sql-injection/README.md)

---

## Lab 02 — RSA Public/Private Key Cryptography

Generated a 2048-bit RSA keypair, used the public key to encrypt a message, then decrypted it with the private key. The actual key files and encrypted output are included in this repo — not placeholders, not screenshots. You can verify the decryption yourself.

```bash
# Decrypt the included encrypted file with the private key
openssl pkeyutl -decrypt -inkey private.pem -in data.txt.enc
# Output: Hello Professor
```

The lab covers how asymmetric encryption works, the relationship between key pairs, and why you can share the public key freely while keeping the private key protected.

→ [Full cryptography write-up](02-rsa-cryptography/README.md)
→ [public.pem](02-rsa-cryptography/public.pem) | [private.pem](02-rsa-cryptography/private.pem) | [data.txt.enc](02-rsa-cryptography/data.txt.enc)

---

## Skills Demonstrated

- SQL injection mechanics — multi-statement injection, query termination, UPDATE chaining
- Understanding of input validation as a defense against injection attacks
- Parameterized queries and prepared statements as mitigations
- RSA asymmetric key generation and key pair relationships
- Public key encryption and private key decryption workflow
- Practical OpenSSL usage for key operations
- Applied understanding of why asymmetric cryptography enables secure key exchange
