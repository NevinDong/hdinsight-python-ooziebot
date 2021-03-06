if [ $# != 2 ]; then
    echo "Usage: deployShell <WASB_PATH> <SHELL_SCRIPT_NAME>"
    return -1
fi

wasbPath=$1
relativePath=$2
fileName=${relativePath##*/}

hostName=`hostname -f`
urlString="export OOZIE_URL=http://"
ooziePort=":11000/oozie"
oozieExportString=$urlString$hostName$ooziePort
eval $oozieExportString

python ../src/workflows/ShellScriptWorkflow.py
python ../src/workflows/ShellScriptJob.py $wasbPath $fileName

hdfs dfs -test -d wasb:///$wasbPath

if [ $? == 0 ] ; then
    echo "Directory already exists in wasb"
    return -1
fi

hdfs dfs -mkdir wasb:///$wasbPath
hdfs dfs -put ../target/shellScriptSample/workflow.xml wasb:///$wasbPath
hdfs dfs -put $relativePath wasb:///$wasbPath
#oozie job -config ../target/shellScriptSample/job.properties -run
