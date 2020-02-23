# About

关于 docker.sh 的详细讲解，请关注微信公众号 KernelNewbies：

![微信搜一搜 KernelNewbies](kernelnewbies.jpg)

# Run

```
# 制作镜像
sudo debootstrap --arch amd64 xenial ./ubuntu1604

# 运行容器
sudo ./docker.sh -c run -m 100M -C dreamland -I ubuntu1604 -V data1 -P /bin/bash
sudo ./docker.sh -c run -m 100M -C dreamland -I ubuntu1604 -V data1 -P "cat /etc/issue"
```
