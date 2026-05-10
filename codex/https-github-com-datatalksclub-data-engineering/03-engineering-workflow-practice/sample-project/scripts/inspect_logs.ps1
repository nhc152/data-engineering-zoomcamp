param(
    [string]$LogFile = "logs/sample_pipeline.log"
)

Write-Host "Log file: $LogFile"
Write-Host ""
Write-Host "Recent errors:"
Select-String -Path $LogFile -Pattern "ERROR" | ForEach-Object {
    "{0}:{1}" -f $_.LineNumber, $_.Line
}

Write-Host ""
Write-Host "Rows by log level:"
Get-Content $LogFile | ForEach-Object {
    $parts = $_ -split '\s+'
    if ($parts.Length -ge 2) {
        $parts[1]
    }
} | Group-Object | Sort-Object Name | ForEach-Object {
    "{0,5} {1}" -f $_.Count, $_.Name
}

