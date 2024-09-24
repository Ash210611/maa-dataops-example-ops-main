#!/bin/bash
echo ${SOLUTION_BRANCH}
git clone -b ${SOLUTION_BRANCH} "https://${GIT_USER}:${GIT_TOKEN}@github.sys.cigna.com/cigna/${SOLUTION_REPO}.git"
mv ${SOLUTION_REPO} git_repo
ls -l