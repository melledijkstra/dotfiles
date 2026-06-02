#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Chrome Personal
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 👤
# @raycast.packageName Quick Access

# Documentation:
# @raycast.description Open Chrome browser with personal account
# @raycast.author melle_dijkstra
# @raycast.authorURL https://raycast.com/melle_dijkstra

open -a "Google Chrome" --args --profile-directory="Profile 2"
