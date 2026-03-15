# Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING='UTF-8'

# alias pip=/opt/homebrew/bin/pip3;


# Airflow specific stuff
if [ -f "/Users/$USER/PycharmProjects/airflow/dev/breeze/autocomplete/breeze-complete-zsh.sh" ]; then
  # START: Added by Updated Airflow Breeze autocomplete setup
  source "/Users/$USER/PycharmProjects/airflow/dev/breeze/autocomplete/breeze-complete-zsh.sh"
  # END: Added by Updated Airflow Breeze autocomplete setup
fi

