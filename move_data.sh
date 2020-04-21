#!/bin/bash

# 数据迁移

TABLES="
src_HIS_ZY_MASTER_INFO       
src_HIS_ZY_settlement        
src_HIS_ZY_CHARGE_DETAIL     
src_his_MZ_settlement        
src_his_MZ_CHARGE_DETAIL     
src_HIS_MZ_master_info       
src_his_MZ_CHARGE_Class   
src_his_MZ_prescription   
src_his_MZ_case_info      
src_HIS_ZY_CHARGE_Class       
src_HIS_ZY_ORDER              
src_HIS_TEST                  
src_HIS_TEST_result           
src_HIS_DRUG_INBOUND          
src_HIS_DRUG_INBOUND_detail   
src_HIS_DRUG_OUTBOUND         
src_HIS_DRUG_OUTBOUND_detail  
src_HIS_DRUG_INVENTORY        
src_HIS_DRUG_INVENTORY_detail 
src_HIS_diag                  
src_HIS_PACS_info             
src_HIS_PACS_report           
SRC_XNH_MZ_settlement        
SRC_XNH_MZ_CHARGE_DETAIL
SRC_XNH_MZ_MASTER_INFO
SRC_XNH_ZY_MASTER_INFO
SRC_XNH_ZY_CHARGE_DETAIL
SRC_XNH_ZY_settlement
SRC_XNH_FAM_INFO
SRC_XNH_FAM_INSURE
SRC_XNH_PERSONAL_INFO
SRC_XNH_PERSONAL_INSURE
src_xnh_organization
src_xnh_dict
SRC_XNH_DIAGGROUP
"

HDFS="/apps/hive/warehouse/medical.db"

for table in $TABLES; do
    if [[ "$table" =~ "#" || "$table"x == ""x  ]]; then
        continue
    else
        table=`echo $table | tr 'A-Z' 'a-z'`
        echo $table
        rm -rf medical_data/$table &&
        hadoop dfs -copyToLocal $HDFS/$table medical_data &&
        cd medical_data &&
        rm -f $table.zip &&
        zip -r $table.zip $table &&
        cd ..
    fi
done

echo done.

#########################################################################################
#!/bin/bash

# xftp下载到本地，然后上传到服务器

TABLES="
src_xnh_personal_info
src_xnh_personal_insure
src_xnh_fam_info
src_xnh_fam_insure
src_xnh_organization
"

# for file in $TABLES; do
for file in `ls | grep zip`; do
    table=${file%.*}
    unzip -o $table.zip &&
    hadoop dfs -rm -r /user/hive/warehouse/medical.db/$table/*
    hadoop dfs -copyFromLocal $table /user/hive/warehouse/medical.db
    # hive -e "msck repair table medical.$table"
    echo "$table done."
done

echo "all done."

# hadoop dfs -copyToLocal /apps/hive/warehouse/medical.db/ medical_data
# zip -r medical_data.zip medical_data

# hadoop dfs -copyFromLocal /home/work/data_fy_src /user/hive/warehouse/medical.db/
# unzip -o medical_data.zip

# hive -e "MSCK REPAIR TABLE medical.src_his_drug"
