# OpenStack Kilo

Lab cài đặt OpenStack Kilo bằng SaltStack

# Mục lục

[1. Thông tin lab](#thongtinlab)

[1.1. Chuẩn bị trên VMware Workstation](#chuanbitrenvmware)

[1.2. Mô hình triển khai trong môi trường VMware Workstation] (#mohinhtrienkhai)

[2. Thiết lập ban đầu] (#2)

[2.1. Máy chủ Salt Master] (#2.1)

[2.2. Các máy chủ OpenStack] (#2.2)

[3. Thực hiện] (#3)

[3.1. Kết nối Master - Minion] (#3.1)

[3.2. Tải mã nguồn] (#3.2)

[3.3. Cài đặt] (#3.3)

[4. Hướng dẫn thiết lập network trước khi tạo máy ảo] (#4)

[4.1. Tạo file image mẫu] (#4.1)

[4.2. Tạo external network] (#4.2)

[5. Tạo máy ảo] (#5)

[Tham khảo] (#6)


<a name="thongtinlab"></a>
### 1. Thông tin lab

<a name="chuanbitrenvmware"></a>
#### 1.1. Chuẩn bị trên VMware Workstation
<b> Cấu hình các vmnet trong vmware workdstation như hình dưới. (Đảm bảo các dải thiết lập đúng với từng vmnet)</b>
- VMNET0 - Chế độ bridge (mặc định). Nhận cùng dải IP card mạng trong laptop, 192.168.1.0/24
- VMNET2 - Chế độ VMNET 2. Đặt dải IP 10.10.10.0/24
- VMNET3 - Chế độ VMNET 3. Đặt dải IP 10.10.20.0/24
Vào tab "Edit" ==> Virtual Network Editor.
![Alt text](http://i.imgur.com/qQkp9EE.png)

<a name="mohinhtrienkhai"></a>
#### 1.2. Mô hình triển khai trong môi trường VMware Workstation
Mô hình 3 node cài đặt OpenStack bên trong một máy LAPTOP

![Alt text](http://i.imgur.com/C17y5mC.png)


Trong đó:
- Salt Master: Ubuntu Server 14.04
- Các node của OpenStack: Ubuntu Server 14.04


<a name="2"></a>
### 2. Thiết lập ban đầu

<a name="2.1"></a>
####2.1. Máy chủ Salt Master

Máy chủ này cài đặt gói `salt-master` có nhiệm vụ cài đặt và quản lý cấu hình các máy chủ OpenStack.
Thực hiện các lệnh sau:

```sh
apt-get update
apt-get install python-software-properties -y
add-apt-repository ppa:saltstack/salt -y
apt-get update
apt-get install salt-master -y
```

`vi /etc/salt/master`

```sh
# saltmaster sẽ listen trên tất cả các IP
interface: 0.0.0.0

```

<a name="2.2"></a>
####2.2. Các máy chủ OpenStack

SSH vào từng node và thực hiện các công việc sau:
 - Cài đặt IP cho tất cả các card mạng (nếu có thể hãy đặt giống như mô hình xây dựng hệ thống). Nếu không muốn sửa file cấu hình và đặt IP tĩnh thì có thể sử dụng lệnh `dhclient` để xin cấp IP cho card mạng. Ví dụ `dhclient eth0`
 - Sử dụng lệnh `landscape-sysinfo` để kiểm tra IP của các card mạng đã có hay chưa. Với node Controller cần 2 card, Network và Compute mỗi node cần 3 card

Các máy chủ này cài đặt gói `salt-minion` để thực thi các lệnh được cấu hình tại Master
Để cài đặt salt-minion thực hiện các lệnh sau trên các node: Controller, Network, Compute1, Compute2

```sh
apt-get update
apt-get install python-software-properties -y
add-apt-repository ppa:saltstack/salt -y
apt-get update
apt-get install salt-minion -y
```
Trên từng máy thực hiện các hành động sau:

- Cấu hình minion trỏ về IP của master

`vi /etc/salt/minion`

`master: 192.168.1.60`

- Cấu hình id của các minion, với mỗi node controller, network, compute đặt id tương tự

**Lưu ý:** bạn phải đặt `id` đúng với các máy chủ OpenStack như bảng dưới đây:

| Máy chủ OpenStack | minion_id  |
|-------------------|------------|
|controller         | controller |
|network            | network    |
|compute1           | compute1   |
|compute2           | compute2   |

Ví dụ như với node controller của OpenStack thực hiện như sau:

`vi /etc/salt/minion_id`

`controller`

Làm tương tự với các node network, compute

- Restart salt-minion
`service salt-minion restart`


<a name="3"></a>
### 3. Thực hiện

<a name="3.1"></a>
####3.1. Kết nối Master - Minion

Tại `salt master` thực hiện việc chấp nhận các kết nối từ minion đến thực hiện lệnh `salt-key -A` và chọn `y` để chấp nhận tất cả.

Dùng `salt-key -L` để liệt kê các danh sách minion xem đã đủ các máy chủ OpenStack chưa.

<a name="3.2"></a>
####3.2. Tải mã nguồn

Sau đó tải bộ file cấu hình mẫu về bằng các lệnh sau:

```sh
apt-get install -y git
cd ~
git clone https://github.com/hocchudong/OpenStack-Kilo-SaltStack.git
cp -R OpenStack-Kilo-SaltStack/salt/ /srv/
cp -R OpenStack-Kilo-SaltStack/pillar /srv/
```

Sau khi tải mã nguồn về, bạn có thể chỉnh sửa lại IP, Password của các máy chủ OpenStack bằng cách sửa các file `/srv/pillar/config.sls` tại các mục:
 - ipaddr
 - password
 - dbpassword

**Lưu ý:** Hãy cẩn thận khi thay đổi IP của các máy chủ OpenStack, không thực hiện hành động này nếu không cần thiết!

<a name="3.3"></a>
####3.3. Cài đặt

#####Thực thi cài đặt IP cho các minion theo mô hình

`salt '*' state.sls ipconfig`

Sau khi thực hiện câu lệnh trên thì cả 3 máy chủ sẽ tự động restart. Kết quả trả về sẽ như hình dưới.
![Alt text](http://i.imgur.com/tfYFmTj.png)

Thực hiện lệnh `salt '*' test.ping` để test xem các minion đã kết nối lại hay chưa. Nếu tất cả các minion trả lại giá trị `True` như bên dưới ta có thể thực hiện bước tiếp theo. Nếu không hãy đợi cho Master và Minion kết nối lại và thực hiện kiểm tra lại.

```sh
root@ubuntu:~# salt '*' test.ping
compute1:
    True
network:
    True
compute2:
    True
controller:
    True
```

#####Thực hiện việc cài đặt OPS

`salt '*' state.highstate`

Sau khi câu lệnh trên thực hiện xong, ta khởi động lại các máy chủ bằng lệnh:
`salt '*' cmd.run reboot`

Cài đặt thành công, mở trình duyệt tại địa chỉ http://192.168.1.61 và đăng nhập bằng tài khoản `admin` password `Welcome123` để sử dụng OpenStack.

####**Chú ý:**

- Trong một số trường hợp có thể phải reboot lại các node trước khi sử dụng.
- Tại thời điểm thực hiện cài đặt hệ thống này nhiều khi sources.list mặc định của Ubuntu bị lỗi Hash sum mismatch khiến cho các gói cài đặt không đúng phiên bản của OpenStack. Để kiểm tra điều này bạn hãy thực hiện câu lệnh sau trên node Controller trước khi thực hiện cài đặt trên Salt Master:
`apt-get update –y`

Nếu gặp lỗi Hash sum mismatch thì bạn hãy thực hiện việc thay sources.list khác bằng các lệnh như sau trên tất cả các node OpenStack trước khi chạy state trên Salt Master:

```sh
cd /etc/apt/
wget https://raw.githubusercontent.com/hocchudong/ghichep/master/sources.list2
mv sources.list sources.list.bka
mv sources.list2 sources.list
cd
```

<a name="4"></a>
###4. Hướng dẫn thiết lập network trước khi tạo máy ảo


<a name="4.1"></a>
####4.1. Tạo file image mẫu

Thực hiện SSH vào node Controller và thực hiện các lệnh sau:

```sh
source openrc
mkdir images
cd images/
wget https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img
glance image-create --name "cirros-0.3.3-x86_64" --disk-format qcow2 --container-format bare --is-public True --progress < cirros-0.3.0-x86_64-disk.img
cd  
rm -r images
```

<a name="4.2"></a>
####4.2. Tạo external network

#####Tại node Controller

```sh
source openrc
neutron net-create ext-net --router:external \
--provider:physical_network external --provider:network_type flat
```

##### Tạo subnet cho external network
```
neutron subnet-create ext-net 192.168.1.0/24 --name ext-subnet \
  --allocation-pool start=192.168.1.101,end=192.168.1.200 \
  --disable-dhcp --gateway 192.168.1.1
```

##### Tạo network cho từng tenant
```
neutron net-create demo-net
```
##### Tạo subnet cho tenant network
```
neutron subnet-create demo-net 172.16.1.0/24 \
--name demo-subnet --gateway 172.16.1.1 --dns-nameserver 8.8.8.8
```

##### Tạo router cho tenant
```
neutron router-create demo-router
```

##### Gán router cho subnet của tenant
```
neutron router-interface-add demo-router demo-subnet
```

##### Thiết lập gateway cho router
```
neutron router-gateway-set demo-router ext-net
```

<a name="5"></a>
###5. Tạo máy ảo
#### Tạo máy ảo
- Chọn tab tạo máy ảo
![Tab launch VM](/images/create-vm1.png)

#### Khai báo tên, cấu hình, số lượng, hệ điều hành
- Khai báo tên, flavor, số lượng máy ảo, OS của máy ảo
![Tab launch VM](/images/create-vm2.png)

#### Lựa chọn network và launch máy ảo

![Tab launch VM](/images/create-vm3.png)


<a name="6"></a>
###Tham khảo:

https://github.com/d0m0reg00dthing/openstack-salstack

https://github.com/vietstacker/openstack-kilo-multinode-U14.04-v1/
