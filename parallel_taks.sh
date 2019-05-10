#!/bin/bash

sh_path=`dirname $(readlink -f $0)`
sh_name=`basename $(readlink -f $0) .sh`
script_path=${sh_path%%/script/*}/script
log_path=${sh_path%%/script/*}/log
source $script_path/config.sh
source $script_path/functions.sh

PROCESS_NUM=6

# 可以用#注释掉不导的表，但是不能有空格
TABLE_LIST="
#abc
plabviursresults
operationlog
#operationlogdetail
manufacturer
brand
Country
SysProvince
SysCity
SysTown
SysStreet
SysSettings
PMedicineRelations

#CPrePackages
#CEMRecordStatus
#CPhysical
#PInpatientLevel
#PXRayPart
#PLaboratoryList
#PCEMRecordImgRelation
#CEMRecordTemplete
#CEMRecordPhysicalSetting
"
LOG_PATH=/home/pet/pet_data_warehouse/pet_medical/xiaonuan/log/`date +"%Y%m%d"`
TODAY=`date +"%Y-%m-%d"`
mkdir -p ${LOG_PATH}


function sqoop_import {
    local v_connect="jdbc:sqlserver://10.15.1.11:2121;database=PMS"
    local v_username="warmsoft_read"
    local v_password="Awq123456"
    local v_database="$1"
    local v_table_name="$2"
    local v_result=0
    local v_map=""

    if [[ `echo "SysProvince" | grep -i "${v_table_name}"` ]]; then
        v_map=" --map-column-hive UpdateStamp=string"
    elif [[ `echo "operationlog operationlogdetail" | grep -i "${v_table_name}"` ]]; then
        v_map=" --map-column-hive UpdateTimestamp=string"
    fi
    hive -e "drop table ${v_database}.${v_table_name}" > /dev/null 2>&1
    local v_script="sqoop-import --connect '"${v_connect}"' --username '"${v_username}"' --password '"${v_password}"' --table "${v_table_name}" --hive-import --hive-overwrite --hive-drop-import-delims --null-string '\\\\N' --null-non-string '\\\\N' --hive-table "${v_database}.${v_table_name}${v_map}" -m 1" &&
    # echo $v_script
    # echo $v_script >> $LOG_PATH/sqoop_import_$v_database.$v_table_name.log 2>&1
    eval $v_script >  $LOG_PATH/sqoop_import_$v_database.$v_table_name.log 2>&1
    if [ $? -ne 0 ]; then
        echo "sqoop_import_$v_database.$v_table_name failed at `date +"%Y-%m-%d %H:%M:%S"`" >> $LOG_PATH/task_error.log 2>&1
        v_result=1
    fi
    echo "" >> $LOG_PATH/sqoop_import_$v_database.$v_table_name.log
    echo "" >> $LOG_PATH/sqoop_import_$v_database.$v_table_name.log
    echo "$v_script" >> $LOG_PATH/sqoop_import_$v_database.$v_table_name.log

    return $v_result
    # sqoop-import \
    # --connect "jdbc:sqlserver://10.15.1.11:2121;database=PMS" \
    # --username warmsoft_read \
    # --password Awq123456 \
    # --table PXRaysList \
    # --hive-import \
    # --hive-overwrite \
    # --hive-drop-import-delims \
    # --null-string '\\N' \
    # --null-non-string '\\N'  \
    # --hive-table data_xiaonuan_final.PXRaysList \
    # -m 1
}


function parallel_task {
    if [[ ! -e ${LOG_PATH}/tmpfifo ]]; then
        mkfifo ${LOG_PATH}/tmpfifo
    fi
    exec 1000<>${LOG_PATH}/tmpfifo
    rm -rf ${LOG_PATH}/tmpfifo

    for (( i = 0; i < ${PROCESS_NUM}; i++ )); do
        echo >&1000
    done

    for v_tb in $TABLE_LIST; do
        if [[ "$v_tb" =~ "#" ]]; then 
                continue
        fi
        read -u1000
        {
            v_tb=`echo $v_tb | tr '[A-Z]' '[a-z]'`
            v_st=`date +"%Y-%m-%d %H:%M:%S"`
            printf "%-30s start time: %s\n" "$v_tb" "$v_st"
            sqoop_import "data_xiaonuan_final" "$v_tb" && { v_flag="succeeded"; write_succeeded_log "data_xiaonuan_final.$v_tb"; } || { v_flag="failed"; write_failed_log "data_xiaonuan_final.$v_tb"; }
            v_et=`date +"%Y-%m-%d %H:%M:%S"`
            v_exec_time=$((`date -d "$v_et" +%s` - `date -d "$v_st" +%s`))
            printf "%-30s start time: %s, end time: %s, exec time: %-5s %s \n" "$v_tb" "$v_st" "$v_et" "${v_exec_time}s" "$v_flag"
            echo >&1000
        } &
    done
    wait

    exec 1000>&-
    exec 1000<&-
}


parallel_task
if [[ -e $LOG_PATH/task_error.log && -s $LOG_PATH/task_error.log ]]; then
    echo "----------------------------------------------------------------------"
    cat $LOG_PATH/task_error.log
    echo "详细日志所在路径$LOG_PATH/sqoop_import_{hive_database}.{tb_name}.log"
    # exit 1
else
    exit 0
fi
