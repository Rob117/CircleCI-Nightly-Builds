#!/bin/bash

# First check out the branch you want to work code magic on. This is our base.
git checkout 'master'
# Force our branch to be in alignment with remote.
git reset --hard origin/master
# Make sure the commit is made with the correct credentials
git config --global user.email "<Your email here>"
git config --global user.name "circle-ci"
# Check to see if our work branch exists - $? command will return 0 if branch exists
# of course, this branch name could be anything you like, it's just important that it is unique to this script.
git rev-parse --verify circle_ci/make_apples
# If we have no branch, make one. Else, switch to it.
if ! [ 0 == $? ]; then
  git checkout -b 'circle_ci/make_apples'
else
  git checkout 'circle_ci/make_apples'
fi

# Run your custom code here. We'll just make a file for ease of use.
# This code can be anything you want to do, bundle update, nginx ip configs, etc.
touch apples.txt

# If we have changes, make a PR for those changes
if [[ `git status --porcelain` ]]; then
  # Ensure that our branch is correct. The last thing you want is to force push into the wrong branch
  if [ `git rev-parse --abbrev-ref HEAD` == 'circle_ci/make_apples' ]; then
    git add 'apples.txt'
    git commit -m 'My commit message here'
    # -f Necessary to possibly overwrite any existing remote branch code and force this to be correct
    # -u sets upstream for circleci
    git push -f -u origin circle_ci/make_apples
    # Head = Code to merge, base = branch to merge into
    # $GITHUB_ACCESS_TOKEN is an environment variable we set on CircleCI, but you must set it on your local machine if you want to test there as well
    # Example Github url: https://api.github.com/repos/Rob117/circletest/pulls?access_token=$GITHUB_ACCESS_TOKEN
    curl -H "Content-Type: application/json" -X POST -d '{"title":"Title Of Pull Request Here","body":"Body of pull request here", "head": "circle_ci/make_apples", "base":"master"}' https://api.github.com/repos/<Organization or User Name>/<Project Name>/pulls?access_token=$GITHUB_ACCESS_TOKEN
  fi
fi
