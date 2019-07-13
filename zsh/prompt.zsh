# See .antigenrc for powerlevel9k config

POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='steelblue'
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='blue'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir  # current directory
  vcs  # git status
)

POWERLEVEL9K_DATE_FORMAT="%D"
POWERLEVEL9K_DATE_BACKGROUND='deepskyblue3'
POWERLEVEL9K_TIME_BACKGROUND='deepskyblue3'
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status                  # exit code of the last command
  command_execution_time  # duration of the last command
  background_jobs         # presence of background jobs
  kubecontext             # The current context of your kubectl configuration.
  virtualenv              # python virtual environment (https://docs.python.org/3/library/venv.html)
  context                 # user@host
  date                    # current date
  time_joined             # current time
)

POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
