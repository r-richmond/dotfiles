$env.config.history = {
	file_format: sqlite
	max_size: 5000000
	sync_on_enter: true
	isolation: false
	ignore_space_prefixed: true
}

$env.NU_ENHANCED_HISTORY = ($nu.default-config-dir | path join history-enhanced.jsonl)

def _nu-git-history-context [cwd: string] {
	let root_result = (^git -C $cwd rev-parse --show-toplevel | complete)
	let root = (if $root_result.exit_code == 0 { $root_result.stdout | str trim } else { "" })
	let branch = (if ($root | is-empty) {
		""
	} else {
		let branch_result = (^git -C $cwd rev-parse --abbrev-ref HEAD | complete)
		if $branch_result.exit_code == 0 { $branch_result.stdout | str trim } else { "" }
	})

	{
		repo: (if ($root | is-empty) { "" } else { $root | path basename })
		branch: (if $branch == "HEAD" { "" } else { $branch })
	}
}

def _nu-format-history-duration [duration_ms: number] {
	let total = ($duration_ms | math round | into int)
	let minutes = ($total // 60000)
	let seconds = (($total mod 60000) // 1000)
	let millis = ($total mod 1000)
	let padded_millis = ($millis | fill --alignment right --character 0 --width 3)

	if $minutes > 0 {
		let padded_seconds = ($seconds | fill --alignment right --character 0 --width 2)
		$"($minutes):($padded_seconds).($padded_millis)"
	} else {
		$"($seconds).($padded_millis)s"
	}
}

def _nu-display-history-path [path: string] {
	let home = $env.HOME

	if ($path | is-empty) {
		"-"
	} else if $path == $home {
		"~"
	} else if ($path | str starts-with $"($home)/") {
		$path | str replace $home "~"
	} else {
		$path
	}
}

def _nu-history-column [value: any width: int] {
	let text = ($value | default "" | into string)
	let truncated = (if ($text | str length) > $width {
		let end = ($width - 2)
		$"($text | str substring 0..$end)~"
	} else {
		$text
	})

	$truncated | fill --alignment left --width $width
}

def _nu-enhanced-history-last-command [history_file: string] {
	if not ($history_file | path exists) {
		return ""
	}

	try {
		open --raw $history_file
		| from json --objects
		| last
		| get command
	} catch {
		""
	}
}

def _nu-enhanced-history-records [] {
	let history_file = $env.NU_ENHANCED_HISTORY

	if not ($history_file | path exists) {
		return []
	}

	let records = (
		open --raw $history_file
		| from json --objects
		| reverse
	)

	$records | each {|row|
		let timestamp = ($row.timestamp | into datetime | format date "%Y-%m-%d %H:%M:%S%.3f")
		let duration = (_nu-format-history-duration ($row.duration_ms | into float))
		let row_cwd = ($row | get -o cwd | default "")
		let row_repo = ($row | get -o git_repo | default "")
		let row_branch = ($row | get -o git_branch | default "")
		let cwd = (_nu-display-history-path $row_cwd)
		let repo = (if ($row_repo | is-empty) { "-" } else { $row_repo })
		let branch = (if ($row_branch | is-empty) { "-" } else { $row_branch })

		{
			timestamp: $timestamp
			duration: $duration
			duration_ms: ($row.duration_ms | into float)
			command: $row.command
			cwd: $cwd
			git_repo: $repo
			git_branch: $branch
		}
	}
}

def _nu-enhanced-history-rows [] {
	_nu-enhanced-history-records
	| each {|row|
		let display = ([
			(_nu-history-column $row.timestamp 23)
			(_nu-history-column $row.duration 10)
			(_nu-history-column $row.cwd 36)
			(_nu-history-column $row.git_repo 18)
			(_nu-history-column $row.git_branch 22)
			$row.command
		] | str join "  ")

		[$display $row.command] | str join (char tab)
	}
}

def --env _nu-fzf-history [] {
	let header = ([
		(_nu-history-column timestamp 23)
		(_nu-history-column duration 10)
		(_nu-history-column cwd 36)
		(_nu-history-column repo 18)
		(_nu-history-column branch 22)
		command
	] | str join "  ")
	let result = (
		_nu-enhanced-history-rows
		| str join (char nl)
		| ^fzf --delimiter (char tab) --with-nth "1" --nth "2..,.." --scheme history --prompt "nu history> " --header $header --bind "ctrl-r:toggle-sort" --query (commandline)
		| complete
	)

	let selected = ($result.stdout | str trim --right)

	if $result.exit_code == 0 and not ($selected | is-empty) {
		let command = (($selected | split row (char tab)) | get 1)
		commandline edit --replace $command
		commandline set-cursor --end
	}
}

$env.config.hooks.pre_execution = ($env.config.hooks.pre_execution | append {||
	let command = (commandline)

	if not ($command | str trim | is-empty) and not ($command | str starts-with "_nu-fzf-history") {
		let cwd = (pwd)
		let git = (_nu-git-history-context $cwd)

		$env.NU_ENHANCED_HISTORY_CURRENT = {
			command: $command
			cwd: $cwd
			git_repo: $git.repo
			git_branch: $git.branch
			started_at: (date now)
		}
	}
})

$env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt | append {||
	let current = ($env | get -o NU_ENHANCED_HISTORY_CURRENT)

	if $current != null {
		if not ($current.command | str starts-with " ") {
			let finished_at = (date now)
			let duration_ms = (($finished_at - $current.started_at) / 1ms)
			let history_file = $env.NU_ENHANCED_HISTORY

			mkdir ($history_file | path dirname)

			let row = {
				timestamp: $current.started_at
				duration_ms: $duration_ms
				command: ($current.command | str replace --all (char tab) " " | str replace --all (char nl) " ")
				cwd: $current.cwd
				git_repo: $current.git_repo
				git_branch: $current.git_branch
			}

			if (_nu-enhanced-history-last-command $history_file) != $row.command {
				$"($row | to json --raw)\n" | save --append $history_file
			}
		}

		hide-env NU_ENHANCED_HISTORY_CURRENT
	}
})
