# veeam-agent-free-centos
Schedule Veeam Agent for Linux Free for backup to remote SMB storage, with email notifications and OpenVPN support
Keep in mind it was created as quick and dirty solution so no clean bash code there. It does it's job though

# Installation

## 1. Packages & script files
```bash
# Veeam
rpm -ivh #veeam-release-el7-1.0.5-1.x86_64.rpm
yum -y install veeam

# Packages depend on mount type, example is SMB:
yum -y install samba-client samba-common cifs-utils;
yum -y install openvpn;
yum -y install msmtp ca-certificates; chmod 600 /opt/scripts/veeam-centos/msmtp.conf;

# Install script files
mkdir -p /opt/scripts; cd /opt/scripts
git clone
chmod u+x ./veeam-agent-free-centos/*.sh
```

## 2. Configuration
1. Set user variables in job-config.sh
2. Comment out vpn.sh/kesl.sh from veeam-centos.sh if not needed. Lines are marked with `# Option:`

### Hints on script logic
- Lan access = just mount folder
- VPN access = connect to vpn, mount folder, do backup, disconnect everything
- ATTENTION: VEEAM on centos 7.x works only with shares mounted with systemd .mount
- ATTENTION: CIFS on centos 6.x seems to not work with SMB >v1.0

## 3. Configure Veeam via console UI
  - Before configuration - mount your share with ./mount.sh start
  - Task name "full"
  - Choose backup source
  - Choose local repo, set path to /mnt/veeamrepo
  - Choose encrypt or not

## 4. While share still mounted it is convenient to do an initial run manually to see if there is any errors
`veeamconfig job start --name "full"`

## 5. Add to /etc/crontab at your convenience
`echo "0 21 * * * root /opt/scripts/veeam-agent-free-centos/veeam-centos.sh" >> /etc/crontab`

----

# Extra info on topic of Veeam Agent for Linux Free (2018)
## Восстановление файлов
https://www.veeam.com/blog/how-to-restore-linux-files-volumes.html

## Файлы - veeam FLR
1. veeam
2. Выбрать  R  Recover Files
3. Замаунтить все партиции бэкапа. NTFS маунтит так что зайти можно только под рутом

## Разделы
- Системный и загрузочный восстанавливаются из veeam recovery media
- Второй физический диск системы (sdb) флешка почему-то не видит

## Создаем загрузочную флешку
- Распаковать содержимое iso (качается с сайта) на флешку (fat подойдет) и пометить ее как bootable

## Зафорсить фулл бэкап
`veeamconfig job start --name <job_name> --activefull`
## Посмотреть логи
`veeamconfig session log --id`
