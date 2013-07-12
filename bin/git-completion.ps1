# Based on Keith Dahlby's GitTabExpansion.ps1 from PoshGit
# https://github.com/dahlbyk/posh-git
# 
# Initial implementation by Jeremy Skinner
# http://www.jeremyskinner.co.uk/2010/03/07/using-git-with-windows-powershell/
param($fragment) # everything after ^git\s*

. "$psscriptroot\..\lib\git.ps1"

if($fragment -match "^(?<cmd>\S+)(?<args> .*)$") {
    $fragment = expandGitAlias $Matches['cmd'] $Matches['args']
}

switch -regex ($fragment) {

    # Handles git <cmd> <op>
    "^(?<cmd>$($subcommands.Keys -join '|'))\s+(?<op>\S*)$" {
        gitCmdOperations $subcommands $matches['cmd'] $matches['op']
    }

    # Handles git flow <cmd> <op>
    "^flow (?<cmd>$($gitflowsubcommands.Keys -join '|'))\s+(?<op>\S*)$" {
        gitCmdOperations $gitflowsubcommands $matches['cmd'] $matches['op']
    }

    # Handles git remote (rename|rm|set-head|set-branches|set-url|show|prune) <stash>
    "^remote.* (?:rename|rm|set-head|set-branches|set-url|show|prune).* (?<remote>\S*)$" {
        gitRemotes $matches['remote']
    }

    # Handles git stash (show|apply|drop|pop|branch) <stash>
    "^stash (?:show|apply|drop|pop|branch).* (?<stash>\S*)$" {
        gitStashes $matches['stash']
    }

    # Handles git bisect (bad|good|reset|skip) <ref>
    "^bisect (?:bad|good|reset|skip).* (?<ref>\S*)$" {
        gitBranches $matches['ref'] $true
    }

    # Handles git tfs unshelve <shelveset>
    "^tfs +unshelve.* (?<shelveset>\S*)$" {
        gitTfsShelvesets $matches['shelveset']
    }

    # Handles git branch -d|-D|-m|-M <branch name>
    # Handles git branch <branch name> <start-point>
    "^branch.* (?<branch>\S*)$" {
        gitBranches $matches['branch']
    }

    # Handles git <cmd> (commands & aliases)
    "^(?<cmd>\S*)$" {
        gitCommands $matches['cmd'] $true
    }

    # Handles git help <cmd> (commands only)
    "^help (?<cmd>\S*)$" {
        gitCommands $matches['cmd'] $false
    }

    # Handles git push remote <ref>:<branch>
    "^push.* (?<remote>\S+) (?<ref>[^\s\:]*\:)(?<branch>\S*)$" {
        gitRemoteBranches $matches['remote'] $matches['ref'] $matches['branch']
    }

    # Handles git push remote <branch>
    # Handles git pull remote <branch>
    "^(?:push|pull).* (?:\S+) (?<branch>[^\s\:]*)$" {
        gitBranches $matches['branch']
    }

    # Handles git pull <remote>
    # Handles git push <remote>
    # Handles git fetch <remote>
    "^(?:push|pull|fetch).* (?<remote>\S*)$" {
        gitRemotes $matches['remote']
    }

    # Handles git reset HEAD <path>
    # Handles git reset HEAD -- <path>
    "^reset.* HEAD(?:\s+--)? (?<path>\S*)$" {
        gitIndex $matches['path']
    }

    # Handles git <cmd> <ref>
    "^commit.*-C\s+(?<ref>\S*)$" {
        gitBranches $matches['ref'] $true
    }

    # Handles git add <path>
    "^add.* (?<files>\S*)$" {
        gitAddFiles $matches['files']
    }

    # Handles git checkout -- <path>
    "^checkout.* -- (?<files>\S*)$" {
        gitCheckoutFiles $matches['files']
    }

    # Handles git rm <path>
    "^rm.* (?<index>\S*)$" {
        gitDeleted $matches['index']
    }

    # Handles git diff/difftool <path>
    "^(?:diff|difftool)(?:.* (?<staged>(?:--cached|--staged))|.*) (?<files>\S*)$" {
        gitDiffFiles $matches['files'] $matches['staged']
    }

    # Handles git merge/mergetool <path>
    "^(?:merge|mergetool).* (?<files>\S*)$" {
        gitMergeFiles $matches['files']
    }

    # Handles git <cmd> <ref>
    "^(?:checkout|cherry|cherry-pick|diff|difftool|log|merge|rebase|reflog\s+show|reset|revert|show).* (?<ref>\S*)$" {
        gitBranches $matches['ref'] $true
    }
}