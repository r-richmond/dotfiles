$env.config.keybindings ++= [{
	name: fzf_history
	modifier: control
	keycode: char_r
	mode: [emacs vi_normal vi_insert]
	event: {
		send: executehostcommand
		cmd: "_nu-fzf-history"
	}
}]
