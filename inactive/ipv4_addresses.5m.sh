#!/usr/bin/env bash

en0=`ipconfig getifaddr en0`
en6=`ipconfig getifaddr en6`

echo "Wi-Fi: $en0"
echo "Ethernet: $en6"
echo "---"
echo "Refresh | refresh=true"
