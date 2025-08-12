#  在需要转移到其他主机上时，需注意vps_mange.py,jhdx.txt的路径
$ip= $(python $PSScriptRoot\vps_manage.py -c)
ssh-keygen -R $ip
# 定义远程命令
$remoteCommand = "export TERM=xterm;bash <(wget -qO- https://raw.githubusercontent.com/gansxx/net_tools/main/sb.sh)"
# 定义轮询参数
$maxAttempts = 10  # 最大尝试次数
$interval = 8     # 每次尝试的间隔时间（秒）
# 轮询查询SSH连接是否成功
$attempt = 0
# 设置 TERM 环境变量
$env:TERM = "xterm"
while ($attempt -lt $maxAttempts) {
    $attempt++
    Write-Host "Attempt ${attempt}: Executing remote command..."
    ssh -o StrictHostKeyChecking=no root@$IP $remoteCommand 2>&1

    # 检查SSH命令是否成功执行
    if ($?) {
        Write-Host "SSH connection successful. 远程命令执行成功."
        break
    } else {
        Write-Host "SSH connection failed. Retrying in $interval seconds..."
        Start-Sleep -Seconds $interval
    }
}

# 如果达到最大尝试次数仍未成功，输出失败信息
if ($attempt -ge $maxAttempts) {
    Write-Host "Failed to establish SSH connection after $maxAttempts attempts."
    exit 1
}
scp -o StrictHostKeyChecking=no root@${ip}:/etc/s-box/jhdy.txt $PSScriptRoot
echo "已将远程服务器的jhdy.txt文件下载到本地NET_TOOLS目录下"

#将本地git仓库的内容上传到远程服务器
#这里的git仓库路经已经提前配置好origin，后面应该根据需要调整
cd $PSScriptRoot

# 检查是否已经初始化了 Git 仓库
if (-not (Test-Path -Path ".git")) {
    Write-Host "Git 仓库尚未初始化，正在初始化..."
    git init
}
# 获取当前远程仓库列表
$remotes = git remote
# 检查是否存在名为 net_tool 的远程仓库
if ($remotes -contains "subsciption") {
    Write-Host "远程仓库 'net_tool' 已存在，跳过添加。"
} else {
    # 提示用户输入远程仓库的 URL
    $remoteUrl = Read-Host "请输入远程仓库的 URL,远程仓库的地址构建可以参考jihulab.md"
    
    # 添加远程仓库
    git remote add subsciption $remoteUrl
    if ($?) {
        Write-Host "远程仓库 'net_tool' 添加成功。"
    } else {
        Write-Host "添加远程仓库失败，请检查输入的 URL 是否正确。"
        exit 1
    }
}
git add jhdy.txt
git commit -m "update jhdy.txt"
git push --set-upstream net_tool main
