# RSA Cryptography Lab

This lab contains a real RSA key pair and an encrypted file.

## How it works

1. Generate a 2048-bit RSA private key.
2. Derive the matching public key.
3. Encrypt data with the public key.
4. Decrypt with the private key.

## Key management

- `private.pem` must be protected (restricted access, never committed in production systems).
- `public.pem` can be shared for encryption/signature verification.
- Rotate keys and maintain key provenance in real environments.

## Post-quantum note

RSA is widely deployed today, but large-scale quantum computers could break RSA via Shor's algorithm.
Organizations should track NIST post-quantum migration guidance and plan hybrid or PQC transitions.

## Verification command

```bash
openssl pkeyutl -decrypt -inkey private.pem -in data.txt.enc
```

Expected output: `Hello Professor`
