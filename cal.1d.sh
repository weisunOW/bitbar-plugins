#!/usr/bin/env bash

echo "📅"
echo "---"

cal -h -y | while IFS= read -r i; do echo "$i | trim=false font=courier color=black"; done
echo "---"
echo "Refresh | refresh=true"
