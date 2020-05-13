#!/bin/bash

# 全局默认配置
HIVE_DB="medical"
STD_DB="medical_gbdp"

# ${db}是由arguments.sh传进来的参数变量

# 基层his共用一套编码，基层his映射不能使用orgid关联，需指定卫生院的统一标识，主要是下面的表的关联会用到
# ods_mapping_dept
# ods_mapping_diag
# oda_mapping_item
# ods_mapping_dict
# BASIC_HIS_ORGID="阜南县乡镇HIS"

# PROJECT_AREA_ID="341225"
# PROJECT_AREA="阜南县"


if [ x"${db}" == x"medical" ]; then
    HIVE_DB="medical"
    DATA_FOLDER="funan"
    BASIC_HIS_ORGID="阜南县乡镇HIS"
    PROJECT_AREA_ID="341225"
    PROJECT_AREA="阜南县"
elif [ x"${db}" == x"medical_gaomi" ]; then
    HIVE_DB="medical_gaomi"
    DATA_FOLDER="gaomi"
    BASIC_HIS_ORGID="乡镇HIS"
    PROJECT_AREA_ID=""
    PROJECT_AREA=""
else
    echo "Error Message: db输入错误，还没有该db的配置信息！"
    exit 1
fi
