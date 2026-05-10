# Secret Incident Response

## Situation

A `.env` file containing production credentials was committed.

## Immediate Actions

1. Revoke or rotate exposed credentials.
2. Remove `.env` from tracking.
3. Add `.env` to `.gitignore`.
4. Search repo for other secrets.
5. Write incident note.

## Commands

```bash
git rm --cached .env
printf "\\n.env\\n.env.*\\n!.env.example\\n" >> .gitignore
git add .gitignore .env.example
git commit -m "Stop tracking local environment secrets"
```

## Important

If the secret reached a remote repository, assume it is compromised. Removing it in a later commit is not enough.

