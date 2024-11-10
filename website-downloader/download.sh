#!/usr/bin/env bash

# @param $1 - URL of the website
download(){
  wget -E -H -k -K -p "$1"
}

main(){
  regex='(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]'

  read -rp "Enter the URL of the website you wish to download (e.g., http://example.com): " url

  clear

  if [[ $url =~ $regex ]]; then
      echo "Valid URL. Downloading..."
      download "$url"
  else
      echo "Invalid URL. Please enter a valid URL and try again."
      exit 1
  fi
}

main "$@"
exit 0