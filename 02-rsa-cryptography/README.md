# Lab 02 — RSA Public/Private Key Cryptography

**Algorithm:** RSA-2048
**Tool:** OpenSSL
**Files included:** `public.pem`, `private.pem`, `data.txt.enc`

---

## What's in This Directory

| File | Description |
|---|---|
| `public.pem` | 2048-bit RSA public key (safe to share) |
| `private.pem` | RSA private key — corresponds to `public.pem` |
| `data.txt.enc` | A message encrypted with `public.pem` |

These are real keys generated for this lab exercise — not placeholders or screenshots. You can run the decryption command below and verify the output yourself.

---

## Verifying the Decryption

```bash
# Decrypt data.txt.enc using the private key
openssl pkeyutl -decrypt -inkey private.pem -in data.txt.enc

# Expected output:
# Hello Professor
```

If you have OpenSSL installed, this works as-is with the files in this repo.

---

## How It Works

### Key Generation

A 2048-bit RSA keypair was generated using OpenSSL:

```bash
# Generate a 2048-bit RSA private key
openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:2048

# Extract the corresponding public key
openssl rsa -pubout -in private.pem -out public.pem
```

The private key contains both halves of the keypair (the private exponent `d` and the public modulus `n`). The public key contains only the public exponent `e` and modulus `n`. The security of RSA rests on the computational difficulty of factoring `n` back into its two large prime factors `p` and `q`.

### Encryption (using the public key)

```bash
# Encrypt a message with the public key
echo "Hello Professor" | openssl pkeyutl -encrypt -pubin -inkey public.pem -out data.txt.enc
```

Anyone with the public key can encrypt a message. The encrypted output (`data.txt.enc`) is 256 bytes for a 2048-bit key — that's the RSA block size. The plaintext "Hello Professor" is padded and encrypted using the public key.

### Decryption (using the private key)

```bash
# Decrypt the encrypted file with the private key
openssl pkeyutl -decrypt -inkey private.pem -in data.txt.enc
```

Only the holder of the private key can decrypt. This is the asymmetric property that makes RSA useful: encryption is public, decryption is private. The mathematical relationship between the keys means that what one locks, only the other can unlock — but you cannot derive the private key from the public key in any reasonable timeframe.

---

## Why Asymmetric Cryptography Matters

The fundamental problem that asymmetric cryptography solves is **key distribution**. With symmetric encryption (like AES), both parties need to share the same secret key — but how do you securely share that key in the first place if you don't already have a secure channel?

Asymmetric cryptography sidesteps this:
1. You generate a keypair and publish your public key freely
2. Anyone who wants to send you a secret message encrypts it with your public key
3. Only you, with your private key, can decrypt it
4. The public key reveals nothing about the private key

This is the mechanism underlying TLS (captured in Lab 02), PGP email encryption, SSH authentication, and code signing. Every time you see HTTPS in a browser, RSA (or its elliptic curve equivalent) is handling the key exchange that makes the encrypted session possible.

---

## Key Management Notes

In a real deployment:

- **Never commit private keys to a public repository** — this lab repo includes them specifically to demonstrate the exercise and because these keys were generated solely for this educational purpose. In production, private keys live in a secrets manager (HashiCorp Vault, AWS KMS, etc.), a hardware security module (HSM), or at minimum an encrypted keystore with strict access controls.
- **Key rotation** — RSA keys should be rotated periodically. Long-lived keys accumulate exposure risk.
- **Key size** — 2048-bit RSA is currently the minimum acceptable size. NIST recommends migrating to 3072-bit or 4096-bit, or transitioning to elliptic curve alternatives (ECDSA, Ed25519) which provide equivalent security with much shorter keys.
- **Post-quantum consideration** — RSA's security rests on the hardness of integer factorization. Shor's algorithm running on a sufficiently capable quantum computer could break RSA. NIST's Post-Quantum Cryptography standardization process (finalized in 2024) provides quantum-resistant alternatives for long-term sensitive data.

---

## Inspecting the Keys

You can inspect the key structure with OpenSSL:

```bash
# View public key details
openssl rsa -pubin -in public.pem -text -noout

# View private key details (modulus, exponents, primes)
openssl rsa -in private.pem -text -noout

# Verify the keys are a matched pair (modulus should match)
openssl rsa -pubin -in public.pem -modulus -noout | md5
openssl rsa -in private.pem -modulus -noout | md5
# Both should return the same MD5 hash
```
