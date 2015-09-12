try { gcm git -ea stop > $null } catch { return }

function pshazz:git:init {
	$git = $global:pshazz.theme.git

	$dirty = $git.prompt_dirty

	if(!$dirty) { $dirty = "*" } # default

	$global:pshazz.git = @{
		prompt_dirty    = $dirty;
		prompt_lbracket = $git.prompt_lbracket;
		prompt_rbracket = $git.prompt_rbracket;
	}

	$global:pshazz.completions.git = resolve-path "$psscriptroot\..\libexec\git-complete.ps1"
}

function global:pshazz:git:prompt {
	$vars = $global:pshazz.prompt_vars

	try { $ref = git symbolic-ref HEAD } catch { }
	if($ref) {
		$vars.git_lbracket = $global:pshazz.git.prompt_lbracket
		$vars.git_rbracket = $global:pshazz.git.prompt_rbracket
		$vars.yes_git = ([char]0xe0b0);

		$vars.git_branch = $ref -replace '^refs/heads/', '' # branch name
		try { $status = git status --porcelain } catch { }
		if($status) {
			$vars.git_dirty = $global:pshazz.git.prompt_dirty;

			try { $lines = git diff HEAD --shortstat } catch { }
			if($lines) {
				try { $individual_lines = $lines.Split("{,}") } catch { }
				if($individual_lines) {
					if($individual_lines.Count.Equals(2)) {
						if($individual_lines[1] -match 'insertions') {
							$insertions = $individual_lines[1].Trim().Split("{ }");
							$vars.git_insertions = "+" + $insertions[0];
						} else {
							if($individual_lines[1] -match 'deletions') {
								$deletions = $individual_lines[1].Trim().Split("{ }");
								$vars.git_deletions = "-" + $deletions[0]
							}
						} 
					} else {
						if($individual_lines.Count.Equals(3)) {
							$insertions = $individual_lines[1].Trim().Split("{ }");
							$vars.git_insertions = "+" + $insertions[0];
							$deletions = $individual_lines[2].Trim().Split("{ }");
							$vars.git_deletions = "-" + $deletions[0]
						}
					}
				}
			}
		}
	} else {
		$vars.no_git = ([char]0xe0b0);
	}
}