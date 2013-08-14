
# returns (branch, dirty)
function global:pshazz_git_prompt_info {
	try { $ref = git symbolic-ref HEAD } catch { }
	if($ref) {
		$ref -replace '^refs/heads/', '' # branch name
		try { $status = git status --porcelain } catch { }
		if($status) {
			$global:pshazz.git.prompt_dirty
		}
	}
}

function global:pshazz_dir {
	if($pwd -like $home) { return '~' }

	$dir = split-path $pwd -leaf
	if($dir -imatch '[a-z]:\\') { return '\' }
	return $dir
}

function global:pshazz_write_prompt($prompt, $vars) {
	$vars.keys | % { set-variable $_ $vars[$_] }
	function eval($str) {
		$executionContext.invokeCommand.expandString($str)
	}

	$fg_default = $host.ui.rawui.foregroundcolor
	$bg_default = $host.ui.rawui.backgroundcolor

	$prompt | % { # write each element of the prompt
		$fg = $_[0]; $bg = $_[1]
		if(!$fg) { $fg = $fg_default }
		if(!$bg) { $bg = $bg_default }
		write-host (eval $_[2]) -nonewline -f $fg -b $bg
	}
}

function global:prompt {
	$saved_lastexitcode = $lastexitcode

	$global:pshazz.prompt_vars = @{
		dir = pshazz_dir
	}

	$git_branch, $git_dirty = @(pshazz_git_prompt_info)
	$global:pshazz.prompt_vars.git_branch = $git_branch
	$global:pshazz.prompt_vars.git_dirty = $git_dirty
	
	pshazz_write_prompt $global:pshazz.theme.prompt $global:pshazz.prompt_vars

	$global:lastexitcode = $saved_lastexitcode
	" "
}
