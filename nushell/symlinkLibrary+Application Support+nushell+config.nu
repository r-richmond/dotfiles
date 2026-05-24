const config_dir = ($nu.config-path | path dirname)
const dotfiles_dir = ($config_dir | path dirname)
const history_config = ($config_dir | path join history.nu)
const hotkeys_config = ($config_dir | path join hotkeys.nu)
const prompt_config = ($dotfiles_dir | path join shell_prompts starship_standard prompt.nu)

source $history_config
source $hotkeys_config
source $prompt_config

# General settings
$env.config.show_banner = false
