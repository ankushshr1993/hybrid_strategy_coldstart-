#!/usr/bin/bash -vx

if [ $# -ne 3 ] 
then
    echo -e "Enter below details with space separated values\nType_of_function no_of_invocations type_of_invoctions type_of_platform"
    exit 1
else
    Type_of_function=$1
    Type_of_invoctions=$2
    No_of_invocations=$3
    case $Type_of_function in
        "hellopy" | "primepy" | "matrixpy" | "colorpy" | "cnnpy" | "hellojs" | "primejs" | "matrixjs" | "colorjs" | "cnnjs" | "hellojava" | "primejava" | "matrixjava" | "colorjava" | "cnnjava" ) ;;
        *)  echo "Invalid function name"
            echo "Valid list:"
            echo "hellopy"
            echo "primepy"
            echo "matrixpy"
            echo "colorpy"
            echo "cnnpy"
            echo "hellojs"
            echo "primejs"
            echo "matrixjs"
            echo "colorjs"
            echo "cnnjs"
            echo "hellojava"
            echo "primejava"
            echo "matrixjava"
            echo "colorjava"
            echo "cnnjava"
            exit 2
            ;;
    esac
fi
worker_node_connection='ankush_sharma_job_gmail_com@worker-node'
master_node_connection='ankush_sharma_job_gmail_com@master-node'
export project_path="${HOME}/scripts/functions/"
timestamp=$(date '+%m%d%H%M')
data_path="${project_path}/data_${Type_of_invoctions}_${No_of_invocations}_${Type_of_function}_${timestamp}"
docker_stats_py='docker_stats.sh'
docker_event_py='docker_events.py'
hybrid_strategy_py='hybrid_strategy.py'
openwhisk_py="load_generator_${Type_of_function}.py"
openwhisk_load_generator_output="load_generator_${Type_of_function}.output"
openfaas_py='load_generator_openfaas.py'
visualization_py='visualization.py'
loaddata_csv='loaddata.csv'
data='data.csv'
docker_stats_json='docker_stats.json'
echo "Type_of_function: $1";
echo "Type_of_invoctions: $2";
echo "No_of_invocations: $3";

cd ${project_path}
#echo -e "Enter below details with space separated values\nType_of_function no_of_invocations type_of_invoctions type_of_platform"
#read Type_of_function no_of_invocations type_of_invoctions type_of_platform
#echo "${Type_of_function} ${no_of_invocations} ${type_of_invoctions} ${type_of_platform}"

mkdir -p ${data_path}

#scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${docker_event_py}" "${hybrid_strategy_py}" ${worker_node_connection}:
ssh -o StrictHostKeyChecking=no "${worker_node_connection}" "
        cd ${project_path} && sudo rm -f data.csv nohup.out docker_stats.json
        nohup ./${docker_stats_py} >/dev/null 2>&1 &
        nohup sudo python3 ${docker_event_py} > docker_event.log 2>&1 &
"
#ssh -o StrictHostKeyChecking=no "${worker_node_connection}" "
#    cd ${project_path}
#    nohup sudo python3 ${docker_event_py} >/dev/null 2>&1 &
#" &


#if [[ "${type_of_platform}" == "openwhisk" ]] 
#then
  cd ${project_path} &&  python3 "${openwhisk_py}"  ${Type_of_function} ${Type_of_invoctions} ${No_of_invocations} | tee  ${data_path}/${openwhisk_load_generator_output}
#elif [[ "${type_of_platform}" == "openfaas" ]]
#then
#    python3 "${openfaas_py}"
#else
#    echo "[ERROR] Please choose platform as either Openwhisk or Openfaas"
#fi

sleep 15

if [ -f "${loaddata_csv}" ]
then

    ssh -o StrictHostKeyChecking=no "${worker_node_connection}" " 
                cd ${project_path} && sudo python3 ${hybrid_strategy_py}
        sleep 5
    " 
    #ssh -o StrictHostKeyChecking=no "${worker_node_connection}" '
    #pid=`ps -ef |grep docker_events | grep -v grep`; pro_id=`echo $pid | cut -d" " -f2`;echo $pro_id
    #pid_stat=`ps -ef |grep docker_stats | grep -v grep`; pro_stat_id=`echo $pid_stat | cut -d" " -f2`;echo $pro_stat_id
    #sudo kill -9 $pro_id $pro_stat_id
    #'
    ssh -x -o StrictHostKeyChecking=no -tt "${worker_node_connection}" -P "
        pid=\$(ps -ef |grep -e docker' 'events -e docker' 'stats -e docker_event |grep -v grep |cut -d' ' -f7)
        echo \$pid
        sudo kill -9 \$pid
        "
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${worker_node_connection}:${project_path}/${data} ${data_path}
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${worker_node_connection}:${project_path}/${docker_stats_json} ${data_path}
else
    echo "${loaddata_csv} doesnt exist on master node . Please check"
fi


cd ${project_path} && mv ${loaddata_csv} ${data_path}
#cd ${project_path} && python3 ${visualization_py}
