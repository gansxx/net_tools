# <center>v2rayN订阅配置</center>
# 1.注册jihulab账号
- 由于github在大陆境内访问并不便利，因此推荐把订阅文件托管到jihulab(gitlab国内的运营商)，接下来也以jihulab为示范展开。

# 2.在jihulab上创建私有的项目
- 点击new project,==以用户的名义创建项目不要以组别的形式创建项目==
![alt text](pictures/jihulab.png)

# 3.点击进入创建好的self_net项目，创建项目token
- 在Project左侧菜单栏中拉到最下方，点击Access tokens，创建Acess tokens

![alt text](pictures/image-2.png)

# 4.在powershell中执行脚本proxy_go.ps1
- 不要用cmd执行ps1脚本，该脚本用于windows环境下的powershell
```powershell
proxy_Go
```
- 第一次执行该脚本时，会要求你配置远程仓库地址
## 远程仓库地址配置
- 按照下文的示例将==用户名，项目名==替换为你自己的即是你远程仓库的地址(==远程仓库地址不等于订阅地址==)
```text
git@jihulab.com:用户名/项目名.git
```

# 5.订阅地址配置
- 将下方中的订阅地址中中文的部分==用户名,项目名,项目token==替换为对应的即可
```txt
https://gitlab.com/api/v4/projects/用户名%2F项目名/repository/files/jhdy.txt/raw?ref=main&private_token=项目token
```
- 该订阅地址导入的文件用于v2rayN客户端的订阅导入

# 6.将订阅地址导入v2rayN
- 点击加号将订阅地址输入可选地址url中即可，别名随便取一个自己喜欢的就好
- 再在订阅分组中
![alt text](pictures/v2rayn.png)

# 7.启用代理
-
## 补充
- 我在深圳使自己用下来，只有Hysteria2协议是能够正常使用的大家也可以根据自己的情况测试