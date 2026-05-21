const config_dir = ($nu.config-path | path dirname)
const history_config = ($config_dir | path join history.nu)
const hotkeys_config = ($config_dir | path join hotkeys.nu)
const prompt_config = ($config_dir | path join prompt.nu)

source $history_config
source $hotkeys_config
source $prompt_config
