# tab completion
$global:completions = @{ } # hash of commands to completion functions

try { $git = gcm git -ea stop } catch {}

if($git) {
    $global:completions.git = resolve-path "$psscriptroot\..\libexec\git-complete.ps1"
}

function global:tabExpansion($line, $lastWord) {
    $expression = [regex]::split($line, '[|;]')[-1].trimstart()

    foreach($cmd in $global:completions.keys) {
        if($expression -match "^$cmd\s*(?<fragment>.*)") {
            return & $global:completions[$cmd] $matches['fragment']
        }
    }
}
