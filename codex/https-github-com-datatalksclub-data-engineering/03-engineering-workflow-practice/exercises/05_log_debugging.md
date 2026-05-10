# Exercise 05 - Log Debugging

## Goal

Practice using shell commands to inspect pipeline logs.

## Commands

From `sample-project`:

```bash
tail -n 100 logs/sample_pipeline.log
grep -n "ERROR" logs/sample_pipeline.log
grep -n "run_20260502" logs/sample_pipeline.log
sed -n '8,12p' logs/sample_pipeline.log
bash scripts/inspect_logs.sh
```

On PowerShell:

```powershell
Get-Content logs/sample_pipeline.log -Tail 100
Select-String -Path logs/sample_pipeline.log -Pattern "ERROR"
Select-String -Path logs/sample_pipeline.log -Pattern "run_20260502"
Get-Content logs/sample_pipeline.log | Select-Object -Index 7..11
.\scripts\inspect_logs.ps1
```

If `rg` is available:

```bash
rg "ERROR|WARN|Timeout|failed" logs/
```

## Questions

Answer:

1. Which run failed?
2. Which step failed?
3. What is the first error?
4. Did retry happen?
5. What should the runbook say?

## Expected Answer

- `run_20260502` failed.
- `extract` failed.
- First error is timeout calling upstream orders API.
- Retry happened once.
- Runbook should mention checking upstream availability and retry policy.
