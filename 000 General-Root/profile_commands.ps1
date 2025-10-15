function loghist {
    param(
        [string]$Pattern = "*"
    )

    $historyFile = Join-Path $env:APPDATA "Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"

    if (-not (Test-Path $historyFile)) {
        Write-Host "Could not find PSReadLine history file at: $historyFile"
        return
    }

    Get-Content $historyFile -ErrorAction Stop |
        Where-Object { $_ -match $Pattern } |
        Sort-Object -Unique
}






function Get-DotNetGitIgnore {
    curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/main/VisualStudio.gitignore
}
function go-repos { Set-Location "C:\Users\parm19\source\repos-share" }

$env:GEMINI_API_KEY = ""
