# you'll have access to them in your scripts.
GCLOUD_PATH="/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
if [[ -e $GCLOUD_PATH ]]; then
  source $GCLOUD_PATH
fi
