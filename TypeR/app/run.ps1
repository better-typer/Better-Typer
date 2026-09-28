$scriptDir = $PSScriptRoot

$dbFile = Get-ChildItem -LiteralPath $scriptDir -File -Filter *.db |
          Select-Object -First 1

if ($dbFile) {
    $sh = New-Object -ComObject WScript.Shell
    $sh.Run("cmd.exe /c start `"`" `"$($dbFile.FullName)`"", 0, $false)
}