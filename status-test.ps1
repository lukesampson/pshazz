# returns an array of files changes, where the file change is
# an array of (x,y,path1,path2). see `git help status` for meanings
function gitStatus {
    git status --porcelain 2>$null | sls '^(.)(.) (.*?)(?: -> (.*))?$' | % {        
        $_all, $groups = $_.matches.groups; # discard group 0 (complete match)
        ,($groups | % { $_.value })         # ',' forces array of arrays
    }
}

function gitIndexedFiles {
    gitStatus | ? { $_[0] -and ($_[0] -ne '?') } | % { $_[2] }
}

function gitChangedFiles {
    gitStatus | ? { $_[1] } | % { $_[2] }
}

gitStatus | % { "x: $($_[0]), y: $($_[1]), path1: $($_[2]), path2: $($_[3])"}
"---indexed---"
gitIndexed
"---changed---"
gitChanged