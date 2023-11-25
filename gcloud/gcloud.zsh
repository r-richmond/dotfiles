# installed by brew cask install google-cloud-sdk
GCLOUD_PATH="/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
if [[ -e $GCLOUD_PATH ]]; then
  source $GCLOUD_PATH
fi
# installed directly from google
GCLOUD_PATH="/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
if [[ -e $GCLOUD_PATH ]]; then
  source $GCLOUD_PATH
fi
