# Exercise 03 - Secret Incident

## Goal

Practice detecting and responding to a committed secret.

## Steps

Copy the broken secret into the sample project:

```bash
cd sample-project
cp ../broken/committed_secret.env .env
git status
```

Do not commit it. Inspect why it is dangerous:

```bash
cat .env
git status --short
```

Confirm `.gitignore` protects it:

```bash
git check-ignore -v .env
```

## If It Was Already Committed

Practice the safe response:

```bash
git rm --cached .env
git add .gitignore .env.example
git commit -m "Stop tracking local environment file"
```

Then write an incident note:

```text
Secret exposed:
Impact:
Immediate action:
Rotation required:
Prevention:
```

## Expected Learning

Deleting the file in a later commit is not enough if the secret reached a remote repository. Rotate the secret.

