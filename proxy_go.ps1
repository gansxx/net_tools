[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
#  在需要转移到其他主机上时，需注意vps_mange.py,jhdx.txt的路径
# 检查是否已经初始化了 Git 仓库
cd $PSScriptRoot/subscription
if (-not (Test-Path -Path '.git')) {
    Write-Host 'Git is initializing in the current directory...'
    git init --initial-branch=main
}
# 获取当前远程仓库列表
$remotes = git remote
# 检查是否存在名为 net_tool 的远程仓库

if ($remotes -contains 'subscription') {
    $ref = git ls-remote --heads subscription main
    if ($ref) {
        # 远程已有该分支 -> 执行拉取
        Write-Host "Remote branch main found. Pulling..."
        git fetch subscription
        git merge -X theirs subscription/main
    }
    else {
        # 远程为空或无该分支 -> 跳过或给出提示
        Write-Host "Remote branch main does NOT exist. Skip pulling."
        # 如需首次推送，可在此调用：
        # git push -u $remote $branch
    } 
}else {
    # 提示用户输入远程仓库的 URL
    $remoteUrl = Read-Host 'please input remote url,you can follow jihulab.md to know how to get it'
    if ([string]::IsNullOrWhiteSpace($remoteUrl)) {
        Write-Host 'please input invalid  url,exit'
        exit 1
    }
    # 添加远程仓库
    git remote add subscription $remoteUrl
    if ($?) {
        git fetch subscription
        if (-not (git switch -C main subscription/main 2> $null)) {
            Write-Host 'Failed to switch branch. Please check the repository setup.'
        }
    }else {
        Write-Host 'fail to add remote repository, please check the url and try again'
        exit 1
    }
}

$ip= $(python $PSScriptRoot\vps_manage.py -c)
ssh-keygen -R $ip
# 定义远程命令
$remoteCommand = 'export TERM=xterm;bash <(wget -qO- https://raw.githubusercontent.com/gansxx/net_tools/main/sb.sh)'
# 定义轮询参数
$maxAttempts = 10  # 最大尝试次数
$interval = 8     # 每次尝试的间隔时间（秒）
# 轮询查询SSH连接是否成功
$attempt = 0
# 设置 TERM 环境变量
$env:TERM = "xterm"
while ($attempt -lt $maxAttempts) {
    $attempt++
    Write-Host 'Attempt ${attempt}: Executing remote command...'
    ssh -o StrictHostKeyChecking=no root@$ip $remoteCommand 2>&1

    # 检查SSH命令是否成功执行
    if ($?) {
        Write-Host 'SSH connection successful.'
        break
    } else {
        Write-Host 'SSH connection failed. Retrying in $interval seconds...'
        Start-Sleep -Seconds $interval
    }
}

# 如果达到最大尝试次数仍未成功，输出失败信息
if ($attempt -ge $maxAttempts) {
    Write-Host 'Failed to establish SSH connection after $maxAttempts attempts.'
    exit 1
}
scp -o StrictHostKeyChecking=no root@${ip}:/etc/s-box/jhdy.txt $PSScriptRoot/subscription


#将本地git仓库的内容上传到远程服务器
git add jhdy.txt
git commit -m 'update jhdy.txt from remote server'
git push --set-upstream subscription main
