#!/bin/bash

# 代理文件配置
PROXY_URL="https://proxypool.us/v2?key=js_keji&extract=vn"
VN_PROXY_FILE="vnproxy.txt"

SSWC_PROXY="https://proxyapi.sswc.cfd/api.php?key=0tc2cjm85ol"
SSWC_PROXY_FILE="proxy.txt"

SSWC_CN_PROXY="https://proxyapi.sswc.cfd/api.php?key=0tc2cjm85ol&geo=cn"
CN_PROXY_FILE="cnproxy.txt"

SSWC_US_PROXY="https://proxyapi.sswc.cfd/api.php?key=0tc2cjm85ol&geo=us"
US_PROXY_FILE="usproxy.txt"

baidunow_goods="https://proxy.baidunow.icu/dlc/proxy?key=qqq123&type=goods"
baidunow_cn="https://proxy.baidunow.icu/dlc/proxy?key=qqq123&type=cn"

keji_HTTP_PROXY="https://vip.qiucg.com/proxy.txt?key=7EO5IZ8O"
keji_GOODS_PROXY="https://vip.qiucg.com/proxy.txt?key=7EO5IZ8O"
keji_GOODS_PROXY2="https://proxypool.us/api.php?key=fQy9Korcv9mEUl4tYj&extract=goods"
keji_CN_PROXY="https://proxypool.us/api.php?key=fQy9Korcv9mEUl4tYj&extract=cn"

keji_CNsimi_PROXY="https://proxypool.us/api.php?key=fQy9Korcv9mEUl4tYj&extract=cn"
keji_CNsimi_PROXY2="https://proxypool.us/api.php?key=fQy9Korcv9mEUl4tYj&extract=cn"
CNSIMI_PROXY_FILE="cnsimi.txt"

initialize_files() {
    echo "Clearing all proxy files..."
    > "$VN_PROXY_FILE"
    > "$SSWC_PROXY_FILE"
    > "$CN_PROXY_FILE"
    > "$US_PROXY_FILE"
    > "$CNSIMI_PROXY_FILE"
    echo "All proxy files cleared."
}

update_proxy_append_split() {
    local url=$1
    local file=$2
    echo "Fetching and processing proxies from $url..."

    while true; do
        curl -s "$url" -o "temp_proxy.txt"
        if [ $? -eq 0 ]; then
            echo "Fetched new proxies from $url."
            break
        else
            echo "Failed to fetch proxies from $url. Retrying..."
            break
        fi
    done

    # 将代理按换行符拆分，去重，并打乱顺序
    tr ' ' '\n' < temp_proxy.txt | sort -u | shuf > "temp_sorted_proxy.txt"

    # 处理已有文件：合并、去重、打乱
    if [ -f "$file" ]; then
        cat "$file" "temp_sorted_proxy.txt" | sort -u | shuf >> "$file.tmp" && mv "$file.tmp" "$file"
    else
        mv "temp_sorted_proxy.txt" "$file"
    fi

    echo "Updated $file with new proxies (deduplicated and shuffled)."
    rm -f "temp_proxy.txt" "temp_sorted_proxy.txt"
}

update_proxy_append_split2() {
    local url=$1
    local file=$2
    echo "Fetching and processing proxies from $url..."

    while true; do
        curl -s "$url" -o "temp_proxy.txt"
        if [ $? -eq 0 ]; then
            echo "Fetched new proxies from $url."
            sleep 1
            break
        else
            echo "Failed to fetch proxies from $url. Retrying..."
            break
        fi
    done

    # 按空格切割并去重
    tr ' ' '\n' < temp_proxy.txt > "temp_sorted_proxy.txt"

    # 去重现有文件中的代理
    if [ -f "$file" ]; then
        cat "$file" "temp_sorted_proxy.txt" > "$file.tmp" && mv "$file.tmp" "$file"
    else
        # 如果文件不存在，则直接使用新的代理
        mv "temp_sorted_proxy.txt" "$file"
    fi

    echo "Updated $file with new proxies (added to the beginning and deduplicated)."
    rm -f "temp_proxy.txt" "temp_sorted_proxy.txt"
}

update_proxy_append() {
    local url=$1
    local file=$2
    echo "Updating $file by appending new proxies..."
    
    while true; do
        curl -s "$url" -o "temp_proxy.txt"
        if [ $? -eq 0 ]; then
            echo "Fetched new proxies from $url."
            break
        else
            echo "Failed to fetch proxies from $url. Retrying..."
            break
        fi
    done

    cat temp_proxy.txt >> "$file"
    sort -u "$file" -o "$file"
    echo "Updated $file with new proxies (appended and deduplicated)."
    rm -f "temp_proxy.txt"
}

update_proxy_replace() {
    local url=$1
    local file=$2
    echo "Updating $file by replacing its content..."
    
    while true; do
        curl -s "$url" -o "$file"
        if [ $? -eq 0 ]; then
            echo "Updated $file with new proxies from $url."
            break
        else
            echo "Failed to update $file from $url. Retrying..."
            break
        fi
    done
}

update_proxy_replace2() {
    local url=$1
    local file=$2
    echo "Updating $file by replacing its content..."

    while true; do
        curl -s "$url" -o "temp_proxy.txt"
        if [ $? -eq 0 ]; then
            echo "Fetched new proxies from $url."
            break
        else
            echo "Failed to fetch proxies from $url. Retrying..."
            break
        fi
    done

    # 只打乱顺序
    shuf temp_proxy.txt > "$file"

    echo "Updated $file with new proxies (shuffled)."
    rm -f "temp_proxy.txt"
}

# 主逻辑
schedule_tasks() {
    COUNTER=0

    while true; do
        # 每5分钟更新 proxy.txt 和 cnproxy.txt，追加并分割去重模式
        if [ $((COUNTER % 20)) -eq 0 ]; then
            update_proxy_replace "$SSWC_CN_PROXY" "$CN_PROXY_FILE"
            update_proxy_replace "$SSWC_US_PROXY" "$US_PROXY_FILE"
            update_proxy_replace "$keji_GOODS_PROXY" "$SSWC_PROXY_FILE"
            
            update_proxy_append_split "$keji_HTTP_PROXY" "$SSWC_PROXY_FILE"
            update_proxy_append_split "$baidunow_goods" "$SSWC_PROXY_FILE"
            update_proxy_append_split "$baidunow_cn" "$CN_PROXY_FILE"
            update_proxy_append_split "$keji_GOODS_PROXY2" "$SSWC_PROXY_FILE"
            update_proxy_append_split "$SSWC_PROXY" "$SSWC_PROXY_FILE"
            update_proxy_append_split "$keji_CN_PROXY" "$CN_PROXY_FILE"
        fi

        echo "-- Waiting for the next update... --"
        sleep 15
        COUNTER=$((COUNTER + 1))
    done
}

initialize_files
schedule_tasks
