#!/bin/bash

CHART_REPO_NAME="helm-chart"

if [ -d $CHART_REPO_NAME ]; then
    echo "Removing existing chart repo."
    rm -rf $CHART_REPO_NAME
fi

git clone -b ${version} ${repository}

exit 0