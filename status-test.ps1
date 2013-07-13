# returns an array of files changes, where the file change is
# an array of (x,y,path1,path2). see `git help status` for meanings
function gitStatus {
    git -c color.status=false status --short 2>$null | sls '^(.)(.) (.*?)(?: -> (.*))?$' | % {        
        $_all, $groups = $_.matches.groups; # discard group 0 (complete match)
        ,($groups | % { $_.value })         # ',' forces array of arrays
    }
}

function gitIndexedFiles {
    gitStatus | ? { $_[0] -and ($_[0] -ne '?') } | % { $_[2] }
}

function gitChangedFiles {
    gitStatus | ? { $_[1] -ne ' ' } | % { $_[2] }
}

function gitStagedFiles {
    gitStatus | ? { 'M','A','D','R','C' -contains $_[0] } | % { $_[2] }
}

function gitUnmergedFiles {
    gitStatus | ? { $_[1] -eq 'U' } | % { $_[2] }
}

function gitDeletedFiles {
    gitStatus | ? { $_[1] -eq 'D' } | % { $_[2] }
}

gitStatus | % { "x: $($_[0]), y: $($_[1]), path1: $($_[2]), path2: $($_[3])"}
"---indexed---"
gitIndexedFiles

"---changed---"
gitChangedFiles

"---staged---"
gitStagedFiles

"---unmerged---"
gitUnmergedFiles

"---deleted---"
gitDeletedFiles