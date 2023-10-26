#!/bin/bash
# CSV 파일 이름 및 헤더 작성
csv_file="mem_log.csv"
echo "Iteration,Start Time,End Time,Anomaly Start Time,Anomaly End Time" > $csv_file

# 총 실행 시간 (초)
total_time=1300

normal="sysbench --db-driver=pgsql --pgsql-user=postgres --pgsql-port=5434 --pgsql-password=postgres --pgsql-db=oltpbench --table_size=800000 --tables=150 --threads=16 --time=$total_time --report-interval=10 oltp_read_write run"


# 10번의 실험 반복
for i in $(seq 1 20)
do
    # Random한 시간 설정 (300에서 700 사이의 랜덤한 값)
    random_time=$((300 + $RANDOM % 400))
    # 현재 시간 기록
    start_time=$(date +"%Y-%m-%d %H:%M:%S")

    # Random한 시간만큼 "normal" 명령어 실행
    echo "[$start_time] Running normal for $random_time seconds: $normal"
    $normal > output.log 2>&1 &

    sleep $random_time

    # 현재 시간 다시 기록
    anomaly_start_time=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$anomaly_start_time] Started mem load"
    # Anomaly duration의 시간동안 Anomaly 발생
    anomaly_duration=$((i * 20))
    stress-ng --vm 8 --vm-bytes 2G --timeout ${anomaly_duration}s


    # 현재 시간 다시 기록
    anomaly_end_time=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$anomaly_end_time] Finished mem load"
    wait
    end_time=$(date +"%Y-%m-%d %H:%M:%S")

    # CSV 파일에 로그 추가
    echo "$i,$start_time,$end_time,$anomaly_start_time,$anomaly_end_time" >> $csv_file

done
