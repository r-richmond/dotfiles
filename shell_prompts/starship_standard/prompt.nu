const starship_config = path self starship.toml

$env.STARSHIP_CONFIG = $starship_config
$env.STARSHIP_SHELL = "nu"
$env.STARSHIP_SESSION_KEY = (random chars -l 16)
$env.PROMPT_MULTILINE_INDICATOR = (^starship prompt --continuation)
$env.PROMPT_INDICATOR = ""

def _starship-format-cmd-duration [duration_ms: any] {
	let total = ($duration_ms | into int)

	if $total < 1000 {
		$"($total)ms"
	} else if $total < 10000 {
		let seconds = ($total // 1000)
		let millis = ($total mod 1000)
		let padded_millis = ($millis | fill --alignment right --character 0 --width 3)
		$"($seconds).($padded_millis)s"
	} else if $total < 60000 {
		let seconds = ($total // 1000)
		$"($seconds)s"
	} else {
		let minutes = ($total // 60000)
		let seconds = (($total mod 60000) // 1000)
		let padded_seconds = ($seconds | fill --alignment right --character 0 --width 2)
		$"($minutes):($padded_seconds)"
	}
}

$env.PROMPT_COMMAND = {||
	let raw_cmd_duration = ($env.CMD_DURATION_MS? | default 0)
	let cmd_duration = if $raw_cmd_duration == "0823" { 0 } else { $raw_cmd_duration }
	let last_exit_code = ($env.LAST_EXIT_CODE? | default 0)
	$env.STARSHIP_COMMAND_DURATION = (_starship-format-cmd-duration $cmd_duration)

	(
		^starship prompt
			--cmd-duration $cmd_duration
			$"--status=($last_exit_code)"
			--terminal-width (term size).columns
			...(if (which "job list" | where type == built-in | is-not-empty) { ["--jobs" (job list | length)] } else { [] })
	)
}

$env.config = ($env.config? | default {} | merge {
	render_right_prompt_on_last_line: true
})

$env.PROMPT_COMMAND_RIGHT = {||
	let raw_cmd_duration = ($env.CMD_DURATION_MS? | default 0)
	let cmd_duration = if $raw_cmd_duration == "0823" { 0 } else { $raw_cmd_duration }
	let last_exit_code = ($env.LAST_EXIT_CODE? | default 0)

	(
		^starship prompt
			--right
			--cmd-duration $cmd_duration
			$"--status=($last_exit_code)"
			--terminal-width (term size).columns
			...(if (which "job list" | where type == built-in | is-not-empty) { ["--jobs" (job list | length)] } else { [] })
	)
}