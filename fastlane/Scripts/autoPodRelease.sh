#!/bin/bash

# 校验是否安装fastlane 没有直接安装
FASTLANE_INSTALL=$(which fastlane)

if [ ! -n "$FASTLANE_INSTALL" ] 
then
	echo "💥 Error:🔧 请安装 fastlane 🔧"
	gem install fastlane -n /usr/local/bin
else
	echo  "已安装fastlane且路径是:${FASTLANE_INSTALL}"
fi


tagVersion=$1
tagMessage=$2


echo "....切换到fastlane的同级目录..."
# 获取脚本所在的目录  Scripts 
ScriptDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" 

#获取脚本所在的父目录 fastlane
KParentPath=`echo $(dirname $ScriptDIR)`

# 项目根目录 
WORKSPACE=`echo $(dirname $KParentPath)`
cd ${WORKSPACE}

#pwd  #显示当前目录
#ls -l

podSecPath=`find ./ -name '*.podspec' -print`

echo "podspec的路径是:$podSecPath"

#echo ${podSecPath##*/} 
projectNameTemp=`echo ${podSecPath##*/}` #私有组件文件名
projectName=`echo ${projectNameTemp%%.*}` #文件名.type 取文件名
echo "podsecs是$projectName"
#
repoName="RCSpecs" #私有pod库名,根据需要修改

echo "....一键发布私有库..."
if [ ! $tagMessage ];then
#	echo "tagMessage为空"
#	fastlane JHUpdatePodTool project:"${projectName}" version:"${tagVersion}"  repo:"${repoName}"  tagMsg:"${tagMessage}"

	fastlane release_pod project:"${projectName}" version:"${tagVersion}"  # repo:"${repoName}" 
else
#	echo "tagMessage是:${tagMessage}"
#	fastlane JHUpdatePodTool project:"${projectName}" version:"${tagVersion}" tagMsg:"${tagMessage}" repo:"${repoName}" 
	fastlane release_pod project:"${projectName}" version:"${tagVersion}" tagMsg:"${tagMessage}" #repo:"${repoName}" 
fi
