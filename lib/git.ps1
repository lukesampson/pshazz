# Based on Keith Dahlby's GitTabExpansion.ps1 from PoshGit
# https://github.com/dahlbyk/posh-git
# 
# Initial implementation by Jeremy Skinner
# http://www.jeremyskinner.co.uk/2010/03/07/using-git-with-windows-powershell/
$subcommands = @{
    bisect = 'start bad good skip reset visualize replay log run'
    notes = 'edit show'
    reflog = 'expire delete show'
    remote = 'add rename rm set-head show prune update'
    stash = 'list show drop pop apply branch save clear create'
    submodule = 'add status init update summary foreach sync'
    svn = 'init fetch clone rebase dcommit branch tag log blame find-rev set-tree create-ignore show-ignore mkdirs commit-diff info proplist propget show-externals gc reset'
    tfs = 'bootstrap checkin checkintool ct cleanup cleanup-workspaces clone diagnostics fetch help init pull quick-clone rcheckin shelve shelve-list unshelve verify'
    flow = 'init feature release hotfix'
}

$gitflowsubcommands = @{
    feature = 'list start finish publish track diff rebase checkout pull'
    release = 'list start finish publish track'
    hotfix = 'list start finish publish track'
}

function gitCmdOperations($commands, $command, $filter) {
    $commands.$command -split ' ' | where { $_ -like "$filter*" }
}

function gitAliases($filter) {
    git config --get-regexp "^alias.$filter" | % {
        [regex]::match($_, 'alias\.([^\s]+)').groups[1].value
    } | sort
}

function gitCommands($filter, $includeAliases) {
    $cmdList = @()
    $cmdList += git help --all |
        where { $_ -match '^  \S.*' } |
        foreach { $_.Split(' ', [StringSplitOptions]::RemoveEmptyEntries) } |
        where { $_ -like "$filter*" }

    if ($includeAliases) {
        $cmdList += gitAliases $filter
    }
    $cmdList | sort
}

function gitRemotes($filter) {
    git remote | where { $_ -like "$filter*" }
}

function gitBranches($filter, $includeHEAD = $false) {
    $prefix = $null
    if ($filter -match "^(?<from>\S*\.{2,3})(?<to>.*)") {
        $prefix = $matches['from']
        $filter = $matches['to']
    }
    $branches = @(git branch --no-color | foreach { if($_ -match "^\*?\s*(?<ref>.*)") { $matches['ref'] } }) +
                @(git branch --no-color -r | foreach { if($_ -match "^  (?<ref>\S+)(?: -> .+)?") { $matches['ref'] } }) +
                @(if ($includeHEAD) { 'HEAD','FETCH_HEAD','ORIG_HEAD','MERGE_HEAD' })
    $branches |
        where { $_ -ne '(no branch)' -and $_ -like "$filter*" } |
        foreach { $prefix + $_ }
}

function gitRemoteBranches($remote, $ref, $filter) {
    git branch --no-color -r |
        where { $_ -like "  $remote/$filter*" } |
        foreach { $ref + ($_ -replace "  $remote/","") }
}

function gitStashes($filter) {
    (git stash list) -replace ':.*','' |
        where { $_ -like "$filter*" } |
        foreach { "'$_'" }
}

function gitTfsShelvesets($filter) {
    (git tfs shelve-list) |
        where { $_ -like "$filter*" } |
        foreach { "'$_'" }
}

function gitFiles($filter, $files) {
    $files | sort |
        where { $_ -like "$filter*" } |
        foreach { if($_ -like '* *') { "'$_'" } else { $_ } }
}

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

function gitIndex($filter) {
    gitFiles $filter @(gitIndexedFiles)
}

function gitAddFiles($filter) {
    gitFiles $filter @(gitChangedFiles)
}

function gitCheckoutFiles($filter) {
    gitFiles $filter @(gitChangedFiles)
}

function gitDiffFiles($filter, $staged) {
    if ($staged) {
        gitFiles $filter @(gitStagedFiles)
    } else {
        gitFiles $filter @(gitChangedFiles)
    }
}

function gitMergeFiles($filter) {
    gitFiles $filter @(gitUnmergedFiles)
}

function gitDeleted($filter) {
    gitFiles $filter @(gitDeletedFiles)
}

function expandGitAlias($cmd, $rest) {
    if((git config --get-regexp "^alias\.$cmd`$") -match "^alias\.$cmd (?<cmd>[^!].*)`$") {
        return "$($Matches['cmd'])$rest"
    } else {
        return "$cmd$rest"
    }
}