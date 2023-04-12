#!/bin/bash
set -e
set -x

# hide token for git clone
export GIT_ASKPASS=$HOME/.git-askpass
echo 'echo $GIT_TOKEN' > $HOME/.git-askpass
chmod 755 $HOME/.git-askpass

# clone the dbt git repository
git clone https://token@github.com/${GIT_REPO} .

# replace the files of the repo by the files of the container
cp /opt/program/profiles.yml ./profiles.yml

# eval the profiles.yml to replace with ENV VARS
eval "cat <<EOF
$(<profiles.yml)
EOF
" 2> /dev/null >profiles.yml

cat profiles.yml

dbt deps --profiles-dir .

exec "$@"