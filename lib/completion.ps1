# pshazz tab completion

# Backup previous TabExpansion function
if (Test-Path Function:\TabExpansion) {
    Rename-Item Function:\TabExpansion global:PshazzTabExpansionBackup
}

# Override TabExpansion function
# FIXME: DO NOT override global TabExpansion function
function global:TabExpansion($line, $lastWord) {
    $expression = [regex]::Split($line, '[|;]')[-1].TrimStart()

    foreach($cmd in $global:pshazz.completions.keys) {
        if ($expression -match "^$cmd\s+(?<fragment>.*)") {
            return & $global:pshazz.completions[$cmd] $matches['fragment']
        }
    }

    # Fall back on existing tab expansion
    if (Test-Path Function:\PshazzTabExpansionBackup) {
        PshazzTabExpansionBackup $line $lastWord
    }
}
