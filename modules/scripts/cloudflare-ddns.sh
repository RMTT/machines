#!/usr/bin/env bash

# CHANGE THESE
auth_key=$(<"$CLOUDFLARE_TOKEN")
zone_identifier=$(<"$CLOUDFLARE_ZONE_ID")

IFS=' ' read -r -a record_names < "$CLOUDFLARE_DDNS_DOMAINS"
record_type="AAAA"             #A or AAAA,ipv4 或 ipv6解析

ip_index="local"            #use "internet" or "local",使用本地方式还是网络方式获取地址
eth_card=$INTERFACE             #使用本地方式获取ip绑定的网卡，默认为eth0，仅本地方式有效,the default ethernet card is eth0

tmpdir="/tmp/cloudflare-ddns/"

if [ ! -e "$tmpdir" ]; then
    mkdir "$tmpdir"
fi

ip_file="${tmpdir}/ip.txt"            #保存地址信息,save ip information in the ip.txt
id_suffix=".ids"

if [ $record_type = "AAAA" ];then
    if [ $ip_index = "internet" ];then
        ip=$(curl -6 ip.sb)
    elif [ $ip_index = "local" ];then
    	ip=$(ip -6 addr show  $eth_card | grep inet6 | grep -v '::1'|grep -v 'fe80' | grep -v 'fd86' | cut -f2 | awk '{ print $2}' | head -1 | cut -d '/' -f1)
    else 
        echo "Error IP index, please input the right type"
        exit 0
    fi
elif [ $record_type = "A" ];then
    if [ $ip_index = "internet" ];then
        ip=$(curl -4 ip.sb)
    elif [ $ip_index = "local" ];then
        if [ "$user" = "root" ];then
            ip=$(ifconfig $eth_card | grep 'inet'| grep -v '127.0.0.1' | grep -v 'inet6'|cut -f2 | awk '{ print $2}')
        else
            ip=$(/sbin/ifconfig $eth_card | grep 'inet'| grep -v '127.0.0.1' | grep -v 'inet6'|cut -f2 | awk '{ print $2}')
        fi
    else 
        echo "Error IP index, please input the right type"
        exit 0
    fi
else
    echo "Error DNS type"
    exit 0
fi

# SCRIPT START
echo "Start update"

#判断ip是否发生变化,check the ip had been changed?
if [ -f $ip_file ]; then
    old_ip=$(cat $ip_file)
    if [ $ip == $old_ip ]; then
	echo "IP has not changed"
        exit 0
    fi
fi

#获取域名和授权 get the domain and authentic
for record_name in ${record_names[@]}; do
    id_file="$tmpdir""$record_name""$id_suffix"
    echo "update: " $record_name
    if [ -f $id_file ] && [ $(wc -l $id_file | cut -d " " -f 1) == 2 ]; then
        record_identifier=$(tail -1 $id_file)
    else
        record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=${record_type}&name=$record_name" \
            -H "Authorization: Bearer $auth_key" \
    	-H "Content-Type: application/json"  | grep -Po '(?<="id":")[^"]*')
    fi

    # 如果没有记录就创建
    if [ -z "$record_identifier" ]; then
	update=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records" \
    	    -H "Authorization: Bearer $auth_key" \
    	    -H "Content-Type: application/json" \
	    --data "{\"type\":\"$record_type\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}")
	record_identifier=$(echo $update | grep -Po '(?<="id":")[^"]*')
    else
	#更新DNS记录 update the dns
    	update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
    	    -H "Authorization: Bearer $auth_key" \
    	    -H "Content-Type: application/json" \
    	    --data "{\"type\":\"$record_type\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}")
    fi
    echo "$record_identifier" >> $id_file
    #反馈更新情况 gave the feedback about the update statues
    if [[ $update == *"\"success\":true"* ]]; then
        message="IP of $record_name changed to: $ip"
        echo "$ip" > $ip_file
        echo "$message"
    else
        message="API UPDATE FAILED. DUMPING RESULTS:\n$update"
        echo "$message"
        exit 1
    fi
done
