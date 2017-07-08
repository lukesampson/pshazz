try { Get-Command git -ea stop > $null } catch { return }

function pshazz:git:init {
	$git = $global:pshazz.theme.git

	$dirty = $git.prompt_dirty

	$unstaged = $git.prompt_unstaged
	$staged = $git.prompt_staged
	$stash = $git.prompt_stash
	$untracked = $git.prompt_untracked

	$push = $git.prompt_remote_push
	$pull = $git.prompt_remote_pull
	$same = $git.prompt_remote_same

	# defaults
	if(!$dirty) { $dirty = "*" }

	if(!$unstaged)  { $unstaged  = "*" }
	if(!$staged)    { $staged    = "+" }
	if(!$stash)     { $stash     = "$" }
	if(!$untracked) { $untracked = "%" }

	if(!$push) { $push = ">" }
	if(!$pull) { $pull = "<" }
	if(!$same) { $same = "=" }

	$global:pshazz.git = @{
		prompt_dirty       = $dirty;
		prompt_unstaged    = $unstaged;
		prompt_staged      = $staged;
		prompt_stash       = $stash;
		prompt_untracked   = $untracked;
		prompt_remote_push = $push;
		prompt_remote_pull = $pull;
		prompt_remote_same = $same;
		prompt_lbracket    = $git.prompt_lbracket;
		prompt_rbracket    = $git.prompt_rbracket;
	}

	$global:pshazz.completions.git = resolve-path "$psscriptroot\..\libexec\git-complete.ps1"
}

# Based on posh-git
function global:pshazz:git:git_branch($git_dir) {
	$r = ''; $b = ''; $c = ''
	if (Test-Path $git_dir\rebase-merge\interactive) {
		$r = '|REBASE-i'
		$b = "$(Get-Content $git_dir\rebase-merge\head-name)"
	} elseif (Test-Path $git_dir\rebase-merge) {
		$r = '|REBASE-m'
		$b = "$(Get-Content $git_dir\rebase-merge\head-name)"
	} else {
		if (Test-Path $git_dir\rebase-apply) {
			if (Test-Path $git_dir\rebase-apply\rebasing) {
				$r = '|REBASE'
			} elseif (Test-Path $git_dir\rebase-apply\applying) {
				$r = '|AM'
			} else {
				$r = '|AM/REBASE'
			}
		} elseif (Test-Path $git_dir\MERGE_HEAD) {
			$r = '|MERGING'
		} elseif (Test-Path $git_dir\CHERRY_PICK_HEAD) {
			$r = '|CHERRY-PICKING'
		} elseif (Test-Path $git_dir\BISECT_LOG) {
			$r = '|BISECTING'
		}

		try { $b = git symbolic-ref HEAD } catch { }
		if (-not $b) {
			try { $b = git rev-parse --short HEAD } catch { }
		}
	}

	if ('true' -eq $(git rev-parse --is-inside-git-dir 2>$null)) {
		if ('true' -eq $(git rev-parse --is-bare-repository 2>$null)) {
			$c = 'BARE:'
		} else {
			$b = 'GIT_DIR!'
		}
	}

	return "$c$($b -replace 'refs/heads/','')$r"
}

function global:pshazz:git:prompt {
	$vars = $global:pshazz.prompt_vars

	$git_root = pshazz_local_or_parent_path .git

	if ($git_root) {

		$vars.yes_git = ([char]0xe0b0);
		$vars.git_local_state = ""
		$vars.git_remote_state = ""

		$vars.is_git = $true

		$vars.git_lbracket = $global:pshazz.git.prompt_lbracket
		$vars.git_rbracket = $global:pshazz.git.prompt_rbracket

		$vars.git_branch =  pshazz:git:git_branch (Join-Path $git_root ".git")

		try { $status = git status --porcelain } catch { }
		try { $stash = git rev-parse --verify --quiet refs/stash } catch { }

		$unstaged = 0;
		$staged = 0;
		$untracked = 0;

		if($status) {
			$vars.git_dirty = $global:pshazz.git.prompt_dirty

			$status | ForEach-Object {
				$item_array = $_.Split(" ")

				if ($_.Substring(0, 2) -eq "??") {
					$untracked++;
				}

				if ($item_array[0].length -ne 0 -And $item_array[0][0] -ne "?") {
					$staged++;
				}

				if ($item_array[0].length -ne 1 -And $_[1] -ne "?") {
					$unstaged++;
				}
			}
		}

		if ($unstaged) {
			$vars.git_local_state += $global:pshazz.git.prompt_unstaged;
			$vars.git_unstaged     = $global:pshazz.git.prompt_unstaged;
		}

		if ($staged) {
			$vars.git_local_state += $global:pshazz.git.prompt_staged;
			$vars.git_staged       = $global:pshazz.git.prompt_staged;
		}

		if ($stash) {
			$vars.git_local_state += $global:pshazz.git.prompt_stash;
			$vars.git_stash        = $global:pshazz.git.prompt_stash;
		}

		if ($untracked) {
			$vars.git_local_state += $global:pshazz.git.prompt_untracked;
			$vars.git_untracked    = $global:pshazz.git.prompt_untracked;
		}

		# upstream state
		try { $tracking = cmd /c "git rev-parse --abbrev-ref @{u}" } catch { }

		if ($tracking -And $tracking -ne "@{u}") {
			try { $remote = cmd /c "git rev-list --count --left-right $tracking...HEAD" } catch { }

			if($remote) {
				$remote_array = @($remote.split());

				if ($remote_array.length -eq 2) {

					if ($remote_array[1] -ne 0) {
						$vars.git_remote_state += $global:pshazz.git.prompt_remote_push;
					}

					if ($remote_array[0] -ne 0) {
						$vars.git_remote_state += $global:pshazz.git.prompt_remote_pull;
					}

					if ($remote_array[0] -eq 0 -And $remote_array[1] -eq 0) {
						$vars.git_remote_state += $global:pshazz.git.prompt_remote_same;
					}
				}
			}
		}

	} else {
		$vars.no_git = ([char]0xe0b0);
	}
}
