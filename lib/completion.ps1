# tab completion
$global:completions = @{ } # hash of commands to completion functions
if(gcm git-completion) {
    $global:completions.git = (gcm git-completion).definition
}
#if(test-path function:\tabexpansion) {
#    $baseTabExpansion = gc function:\tabexpansion
#}
function global:tabExpansion($line, $lastWord) {
    $expression = [regex]::split($line, '[|;]')[-1].trimstart()

    foreach($cmd in $global:completions.keys) {
        if($expression -match "^$cmd\s*(?<fragment>.*)") {
            return & $global:completions[$cmd] $matches['fragment']
        }
    }

    #if($baseTabExpansion) { & baseTabExpansion $line $lastWord }
}
