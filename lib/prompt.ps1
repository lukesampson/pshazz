function git_prompt_info {
    $ref = git symbolic-ref HEAD
    if($ref) {
        $ref = $ref -replace '^refs/heads/', ''
        write-host " ($ref)" -f red -nonewline
    }
}

function prompt {
    write-host "$(split-path $pwd -leaf)" -f cyan -nonewline
    git_prompt_info
    write-host ' $' -nonewline
    " "
}