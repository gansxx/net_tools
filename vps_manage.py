import os
import requests
import json
from loguru import logger
import argparse
import time
import pandas as pd
from pathlib import Path

headers = {
    'Authorization': 'Bearer ' + os.getenv('VULTR_API_KEY', ''),
    'Content-Type': 'application/json',
}
# 获取当前脚本的绝对路径
script_path = Path(__file__).resolve()

# 获取当前脚本所在的目录
script_dir = script_path.parent
# 构建目标文件的路径（假设 server_detail.json 在脚本所在目录下）
file_path = f"{script_dir}\server_detail.json"
logger.info(f"读取配置文件: {file_path}")
df=pd.read_json(file_path).to_dict(orient='records')
region=df[0]['region']
plan=df[0]['plan']
label=df[0]['label']
os_id=df[0]['os_id']

#ToDo:添加从本地json文件中读取参数的代码，并增加选择区域的功能
def create_new_instance(region=region, plan=plan, label=label, os_id=os_id):
    """
    创建新的Vultr实例
    """
    #region对应地址，lax代表洛杉矶,ewr代表纽约,sgp代表新加坡
    #region可以通过https://api.vultr.com/v2/regions获取
    #plan对应地址，vc2-1c-1gb代表1核1G内存
    #label代表实例名称
    #os_id代表操作系统ID，可以通过https://api.vultr.com/v2/os获取

    json_data = {
        'region': region,
        'plan': plan,
        'label': label,
        'os_id': os_id,
        'user_data': 'QmFzZTY0IEV4YW1wbGUgRGF0YQ==',
        'backups': 'disabled',
        'script_id':'e154aeac-0221-45ef-98a3-59ec10c04c3f',
        'sshkey_id':['d0907ba7-2c7c-41cd-b7ab-60192b3d8c14'],
    }

    response = requests.post('https://api.vultr.com/v2/instances', headers=headers, json=json_data)
    text=response.text
    json_data = json.loads(text)
    try:
        instance_id= json_data['instance']['id']
        return instance_id
    except KeyError:
        logger.error(f"创建实例失败: {json_data}")

def reboot_instance(instance_ids):
    url="https://api.vultr.com/v2/instances/reboot"
    json_data={
        "instance_ids" : instance_ids
    }
    response = requests.post(url, headers=headers, json=json_data)
    if response.status_code == 204:
        logger.info(f"Instance {instance_ids} 开始重启.")
    else:
        logger.warning(f"Failed to reboot instance {instance_ids}. Status code: {response.status_code}")

def get_info(url):
    """
    获取Vultr API的响应信息
    """
    response = requests.get(url, headers=headers)
    text = response.text
    json_data = json.loads(text)
    return json_data

def get_instance_ip(instance_id):
    #获取特定实例的IP地址
    url=f"https://api.vultr.com/v2/instances/{instance_id}/ipv4" 
    json_data=get_info(url)
    if 'ipv4s' not in json_data or not json_data['ipv4s']:
        raise ValueError(f"Instance {instance_id} has no IPv4 addresses assigned.")
    return json_data['ipv4s'][0]['ip'] 

def list_instances():
    """
    列出所有Vultr实例
    """
    url = "https://api.vultr.com/v2/instances"
    json_data = get_info(url)
    return json_data

def get_instance_info(instance_id):
    url=f"https://api.vultr.com/v2/instances/{instance_id}"
    json_data = get_info(url)
    return json_data

def delete_instance():
    json_data = list_instances()
    if json_data['instances']:
        for instance in json_data['instances']:
            instance_id = instance['id']
            url = f"https://api.vultr.com/v2/instances/{instance_id}"
            #发送delete请求
            response = requests.delete(url, headers=headers)
            if response.status_code == 204:
                logger.info(f"Instance {instance_id} 成功删除.")
            else:
                logger.warning(f"Failed to delete instance {instance_id}. Status code: {response.status_code}")
def main():
    #查看当前是否已经存在实例
    json_data = list_instances()
    if json_data['instances']:
        logger.info("当前已有实例，测试实例可用状况")
        raise ValueError("当前已有实例，请先删除实例或使用其他参数创建新实例")
    else:
        logger.info("当前没有实例，创建新的实例")
        instance_id = create_new_instance()
        logger.info(f"新创建的实例ID: {instance_id}")
        if not instance_id:
            logger.error("实例创建失败，无法获取实例ID")
            return None
        logger.info("实例正在启动中，请稍等...")
        start_time = time.time()
    while True:
        info = get_instance_info(instance_id)
        status = info['instance']['server_status']
        if status == 'ok':
            logger.info(f"Instance {instance_id} 启动成功")
            ipv4= get_instance_ip(instance_id)
            logger.info(f"新创建的实例ID: {instance_id}, IP地址: {ipv4}")
            return ipv4

        if time.time() - start_time > 300:  # 超时设置为5分钟
            logger.error(f"Instance {instance_id} 启动超时")
            raise TimeoutError(f"Instance {instance_id} 启动超时")
        time.sleep(10)
        

if __name__ == "__main__":
    #ToDo: 添加命令行参数解析
    parser = argparse.ArgumentParser(description="Vultr Instance Management")
    parser.add_argument('-c','--create', action='store_true', help='Create a new instance')
    parser.add_argument('-d','--delete', action='store_true', help='Delete existing instances')
    args = parser.parse_args()
    if args.create:
        ipv4=main()
        #传输ip地址到命令行
        time.sleep(30)
        print(ipv4)
    elif args.delete:
        delete_instance()
    else:
        main()
    