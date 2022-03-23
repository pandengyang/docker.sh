# About

docker.sh 是用 Shell 写的一个简易的 docker，支持以下功能：

* uts namespace
* mount namespace
* pid namespace
* memory 资源限制
* 联合加载
* 卷目录

关于 docker.sh 的详细讲解，请关注微信公众号 ScratchLab：

![微信搜一搜 ScratchLab](scratchlab.jpg)

# Run

```
# 制作镜像
sudo debootstrap --arch amd64 xenial ./ubuntu1604

# 运行容器
sudo ./docker.sh -c run -m 100M -C dreamland -I ubuntu1604 -V data1 -P /bin/bash
sudo ./docker.sh -c run -m 100M -C dreamland -I ubuntu1604 -V data1 -P "cat /etc/issue"
```
