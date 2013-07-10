# tab completion
$completions = @{ } # hash of commands to completion functions
if(gcm git-completion) {
    $completions.git = git-completion
}
if(test-path function:\tabexpansion) {
    $baseTabExpansion = gc function:\tabexpansion
}
function global:tabExpansion($line, $lastWord) {
    $expression = [regex]::split($line, '[|;]')[-1].trimstart()

    foreach($cmd in $completions.keys) {
        if($expression -match "^$cmd\s*(?<fragment>") {
            return & $completions[$cmd] $matches['fragment']
        }
    }

    if($baseTabExpansion) { & baseTabExpansion $line $lastWord }
}
