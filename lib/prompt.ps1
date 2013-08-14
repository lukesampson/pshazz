
# returns (branch, dirty)
function global:pshazz_git_prompt_info {
	try { $ref = git symbolic-ref HEAD } catch { }
	if($ref) {
		$ref -replace '^refs/heads/', '' # branch name
		try { $status = git status --porcelain } catch { }
		if($status) {
			$env:pshazz_prompt_git_dirty
		}
	}
}

function global:pshazz_dir {
	if($pwd -like $home) { return '~' }

	$dir = split-path $pwd -leaf
	if($dir -imatch '[a-z]:\\') { return '\' }
	return $dir
}

function format($str, $hash) {
	$hash.keys | % { set-variable $_ $hash[$_] }
	$executionContext.invokeCommand.expandString($str)
}

function global:pshazz_write_prompt($prompt, $vars) {
	#write-host $prompt
	$prompt | % {
		write-host $_[2] -nonewline
	}
}

function global:prompt {
	$saved_lastexitcode = $lastexitcode

	$dir = pshazz_dir
	$git_branch, $git_dirty = @(pshazz_git_prompt_info)

	# cheat
	$prompt = @(
		@("cyan",  "", '$dir '),
		@("red",   "", '$git_branch$git_dirty '),
		@("green", "", '`$')
	)
	pshazz_write_prompt $prompt @{
		dir = $dir;
		git_branch = $git_branch;
		git_dirty = $git_dirty
	}

	$global:lastexitcode = $saved_lastexitcode
	" "
}
