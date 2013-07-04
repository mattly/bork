operation=$1
script=$2
scriptName=$(substring "/$script" '.*/\(.*\)')
scriptDir=$(substring "$script" '\(.*\)/.*')

include $scriptName
