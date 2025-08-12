# net_tools

## 项目简介

本项目用于远程管理 VPS 的启动与销毁，并在 VPS 上自动部署代理服务（如 sing-box/hysteria2），同时自动更新订阅文件到 GitLab/Jihulab 仓库，方便客户端订阅。




## Windows 环境配置要求

在 Windows 环境下使用本项目，需满足以下基础配置：

- 已安装 PowerShell 5.1 及以上版本
- 已安装 OpenSSH 工具（包含 ssh.exe 和 scp.exe，可通过 Windows 设置 > 应用 > 可选功能 > 添加 OpenSSH 客户端）
- 已安装 Python 3.8 及以上版本，并配置好环境变量
- 安装 Git 工具（用于本地仓库管理和推送订阅文件）

如未安装 OpenSSH，可参考微软官方文档：https://docs.microsoft.com/zh-cn/windows-server/administration/openssh/openssh_install_firstuse

如未安装 Python，可前往 https://www.python.org/downloads/ 下载并安装。

安装依赖包示例：
```powershell
pip install pandas loguru
```

---

---

## 主要功能

- 一键创建/销毁 Vultr VPS 实例
- 自动部署代理服务（支持 hysteria2 等协议）
- 自动生成订阅文件并推送到 GitLab/Jihulab
- 支持 Windows 下 PowerShell 脚本远程管理
- 支持多区域、套餐、标签自定义

---

## 文件说明

- `vps_manage.py`：Vultr VPS 实例管理脚本，支持创建/销毁实例，参数从 `server_detail.json` 读取
- `server_detail.json`：VPS 配置参数（区域、套餐、标签、系统等）
- `proxy_go.ps1`：Windows PowerShell 脚本，远程连接 VPS 并自动部署代理服务，下载订阅文件到本地，并推送到远程仓库
- `server_doom.ps1`：销毁 VPS 实例的 PowerShell 脚本
- `sb.sh`：VPS 上自动化部署 sing-box/hysteria2 代理服务的 Shell 脚本
- `jihulab.md`：Jihulab（GitLab）订阅配置教程

---

## 快速开始

### 1. 配置 VPS 参数
编辑 `server_detail.json`，设置你需要的区域、套餐、标签、系统等参数。

### 2. 启动 VPS 并部署代理
在 Windows PowerShell 中执行：
```powershell
proxy_go.ps1
```
脚本会自动连接远程 VPS，部署代理服务，并下载订阅文件到本地。

### 3. 销毁 VPS
在 Windows PowerShell 中执行：
```powershell
server_doom.ps1
```

### 4. GitLab/Jihulab 订阅配置
参考 `jihulab.md`，配置远程仓库地址和订阅地址，将订阅文件推送到你的 GitLab/Jihulab 项目。

---

## 订阅地址示例
```
https://gitlab.com/api/v4/projects/用户名%2F项目名/repository/files/jhdy.txt/raw?ref=main&private_token=项目token
```

---

## 注意事项
- 需提前配置好 Vultr API Key 环境变量
- 需在 Jihulab/GitLab 上创建项目并获取 Access Token
- PowerShell 脚本仅适用于 Windows 环境

---

## 协议支持
- hysteria2（推荐，国内可用性较好）
- sing-box（多协议支持）

---

## 参考
- [Jihulab订阅配置教程](jihulab.md)
- [Vultr API文档](https://www.vultr.com/api/)

---

## Docker 一键部署（待完成）

后续将支持通过 Dockerfile 一键部署本项目，包含自动化环境配置与服务启动。

计划内容：
- 提供标准 Dockerfile

敬请期待，欢迎提交相关建议或 PR。

如有问题请提交 Issue 或联系作者。
