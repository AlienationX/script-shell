#!/bin/bash

echo "参数："$@

function usage {
    echo ""
    echo "选项："
    echo "  -D, --db                     数据库名：[medical, medical_gaomi, tmp_check, .......]"
    echo "  -d, --dttype                 时间类型：[day, week, month, year]"
    echo "  -s, --startdate              开始日期：例如 2019-01-01"
    echo "  -e, --enddate                结束日期：例如 2019-01-02"
    echo "  -i, --init                   是否初始化：1为是，默认为0"
    echo "  -h, --help                   这个简短的用法指南"
    echo "  -l, --longoptions <长选项>   # 要识别的长选项"
    echo "  -n, --name <程序名>          # 将错误报告给的程序名"
    echo "  -o, --options <选项字符串>   # 要识别的短选项"
    echo "  -q, --quiet                  # 禁止 getopt(3) 的错误报告"
    echo "  -Q, --quiet-output           # 无正常输出"
    echo "  -V, --version                # 输出版本信息"
}

#-o或--options选项后面是可接受的短选项，如ab:c::，表示可接受的短选项为-a -b -c，
#其中-a选项不接参数，-b选项后必须接参数，-c选项的参数为可选的
#-l或--long选项后面是可接受的长选项，用逗号分开，冒号的意义同短选项。
#-n选项后接选项解析错误时提示的脚本名字

ARGS=`getopt -o D:d:s:e:i --long db:,dttype:,startdate:,enddate:,init -n "$0" -- "$@"`
if [ $? != 0 ]; then
    usage
    exit 1
fi

# echo ARGS=[$ARGS]
# 将规范化后的命令行参数分配至位置参数（$1,$2,...)
eval set -- "${ARGS}"
# echo formatted parameters=[$@]


db=""
dtType=""
startDate=""
endDate=""
init="0"


while true
do
    case "$1" in
        -D|--db) 
            db=$2
            shift 2
            ;;
        -d|--dttype)
            dtType=$2
            shift 2
            ;;
        -s|--startdate)
            startDate=$2
            shift 2
            ;;
        -e|--enddate)
            endData=$2
            shift 2
            ;;
        -i|--init)
            init="1"
            shift
            ;;
        -q|--quit)
            case "$2" in
                "")
                    echo "Option quit, no argument";
                    shift 2  
                    ;;
                *)
                    echo "Option quit, argument $2";
                    shift 2;
                    ;;
            esac
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Parameters error!"
            usage
            exit 1
            ;;
    esac
done

if [[ x"$db" == x"" ]]; then
    echo "Error Message: must specify the database (-D)"
    usage
    exit 1
fi

if [[ x"$dtType" == x"" ]]; then
    dtType="all"
fi

echo "  db=$db"
echo "  dtType=$dtType"
echo "  startDate=$startDate"
echo "  endDate=$endDate"
echo "  init=$init"
