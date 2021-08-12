@echo on

SET CHART_REPO_NAME=helm-chart

if EXIST %CHART_REPO_NAME% (
    echo "Removing existing $CHART_REPO_NAME% repo."
    rd $CHART_REPO_NAME%
)

git clone -b ${version} ${repository}

exit