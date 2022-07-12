# GOAD (Game Of Active Directory) - version 2

![goad.png](./docs/img/GOAD.png)

## Description
GOAD is a pentest active directory LAB project.
The purpose of this lab is to give pentesters a vulnerable Active directory environement ready to use to practice usual attack techniques.

## warning
This lab is extremly vulnerable, do not reuse receipe to build your environement and do not deploy this environment on internet (this is a recommendation, use it as your own risk)
This repository is for pentest practice only.

## licences
This lab use free windows VM only (180 days). After that delay enter a licence on each server or rebuild all the lab (may be it's time for an update ;))

## Installation
### Requirements
So far the lab has only been tested on a linux machine, but it should work as well on macOS. Ansible has some problems with Windows hosts so I don't know about that.

For the setup to work properly you need to install:

#### Virtualbox

- **virtualbox** actually the vms are provided to be run on virtualbox so you need a working virtualbox environement on your computer

#### Vagrant
- **vagrant** from their official site [vagrant](https://www.vagrantup.com/downloads). The version you can install through your favourite package manager (apt, yum, ...) is probably not the latest one.
- Install vagrant plugin vbguest: `vagrant plugin install vagrant-vbguest` (not needed anymore)

#### Ansible
- *Create a python >= 3.8 virtualenv*

```bash
sudo apt install python3.8-venv
cd ansible
python3.8 -m virtualenv .venv
source .venv/bin/activate
```

- Install ansible and pywinrm in the .venv
  - **ansible** following the extensive guide on their website [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
  - **Tested with ansible-core (2.12)**
  - **pywinrm** be sure you got the pywinrm package installed

```
python3 -m pip install --upgrade pip
python3 -m pip install ansible-core==2.12.6
python3 -m pip install pywinrm
```

- Install all the ansible-galaxy requirements
  - **ansible windows**
  - **ansible community.windows**
  - **ansible chocolatey** (not needed anymore)
  - **ansible community.general**
```
ansible-galaxy install -r requirements.yml
```

> Vagrant and virtualbox are used to provide the virtual machines and Ansible is use to automate the configuration and vulnerabilites setup.

### V2 breaking changes
- If you previously install the v1 do not try to update as a lot of things have changed. Just drop your old lab and build the new one (you will not regret it)
- Chocolatey is no more used and basic tools like git or notepad++ are no more installed by default (as chocolatey regulary crash the install due to hiting rate on multiples builds)
- ELK is no more installed by default to save ressources but you still can install it separately (see the blueteam/elk part)
- Dragonstone vm as disapear and there is no more DC replication in the lab to save resources
- Wintefell is now a domain controler for the subdomain dev of the labb.local domain

### Space use
- the lab take environ 77GB (but you have to get the space for the vms vagrant images windows server 2016 (22GB) / windows server 2019 (14GB) / ubuntu 18.04 (502M))
- the total space needed for the lab is ~115 GB (and more if you take snapshots)

### Start / Setup
The default domain will be **labb.local**, on the subnet 192.168.56.1/24 and each machine has only been allocated with 1CPU and 1024MB of memory. If you want to change some of these performance settings you can modify the Vagrantfile.

To have the lab up and running this is the commands you should do:

- VMs creation

```bash
git clone git@github.com:Orange-Cyberdefense/GOAD.git
cd GOAD/
vagrant up # this will create the vms
```

- VMs provisionning
  - in one command just play :

```bash
ansible-playbook main.yml # this will configure the vms in order to play ansible when the vms are ready
```

- Or you can run playbooks one by one (mostely for debug or if you get trouble during install)
  - The main.yml playbook is build in multiples parts. each parts can be re-run independently but the play order must be keep in cas you want to play one by one :

```
ansible-playbook build.yml        # Install stuff and prepare vm
ansible-playbook ad-servers.yml   # create main domains, child domain and enroll servers
ansible-playbook ad-trusts.yml    # create the trust relationships
ansible-playbook ad-data.yml      # import the ad datas : users/groups...
ansible-playbook servers.yml      # Install IIS and MSSQL
ansible-playbook ad-relations.yml # set the rights and the group domains relations
ansible-playbook adcs.yml         # Install ADCS on prod
ansible-playbook ad-acl.yml       # set the ACE/ACL
ansible-playbook security.yml     # Configure some securities (adjust av enable/disable)
ansible-playbook vulns.yml        # Configure some vulnerabilities
```

- when you finish playing you could do :

```bash
vagrant halt # will stop all the vm
```

- to just relaunch the lab (no need to replay ansible as you already do that in the first place)

```bash
vagrant up   # will start the lab
```

- if you got some errors see the troobleshooting section at the end of the document, but in most case if you get errors during install, don't think and just replay the main playbook (most of the errors which could came up are due to windows latency during installation, wait few minutes and replay the main.yml playbook)
```
ansible-playbook main.yml
```

## LAB Content - labb.local / dev.labb.local / prod.local

![v2_overview.png](./docs/img/v2_overview.png)

### Servers
This lab is actually composed of five virtual machines:
- **dc01** : DC01  running on Windows Server 2019 (with windefender enabled by default)
- **dc02**   : DC02  running on Windows Server 2019 (with windefender enabled by default)
- **srv02**  : SRV02 running on Windows Server 2019 (with windefender **disabled** by default)
- **dc03**      : DC03  running on Windows Server 2016 (with windefender enabled by default)
- **srv03**      : SRV03 running on Windows Server 2016 (with windefender enabled by default)

#### domain : dev.labb.local
- **dc02**     : DC01
- **srv02**    : SRV02 : MSSQL / IIS

#### domain : labb.local
- **dc01**   : DC02
- **castelrock**     : SRV01 (disabled due to resources reasons)

#### domain : prod.local
- **srv03**        : DC03
- **meeren**         : SRV03 : MSSQL / ADCS


The lab setup is automated using vagrant and ansible automation tools.
You can change the vm version in the Vagrantfile according to Stefan Scherer vagrant repository : https://app.vagrantup.com/StefanScherer

## Blueteam / ELK

- **elk** a kibana is configured on http://192.168.56.50:5601 to follow the lab events
- infos : log encyclopedia : https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/
- the elk is not installed installed by default due to ressources reasons. 
- to install and start the elk play the following commands :
  1. uncomment the elk vm in vagrant and provision with `vagrant up elk`
```
# { :name => "elk", :ip => "192.168.56.50", :box => "bento/ubuntu-18.04", :os => "linux",
#   :forwarded_port => [
#     {:guest => 22, :host => 2210, :id => "ssh"}
#   ]
# }
```

  2. you need `sshpass` for the elk installation
```
sudo apt install sshpass
```

  3. play the elk.yml playbook to install and run elk:
```
ansible-playbook elk.yml
```

### Users/Groups and associated vulnerabilites/scenarios

dev.labb.LOCAL
- STARKS
  - kevin.randall:        Execute as user on mssql
  - melanie.johnston:      DOMAIN ADMIN dev/ (bot 5min) LLMRN request to do NTLM relay with responder
  - zoea.newman:     
  - jack.piper:        bot (3min) RESPONDER LLMR
  - yvonne.ball:       
  - piers.black:     ASREP_ROASTING
  - blake.tucker:      GPO abuse (Edit Settings on "ChangeWallpaperInBlue" GPO)
  - theon.greyjoy:
  - leah.mitchell:          mssql admin / KERBEROASTING / group cross domain / mssql trusted link
  - adrian.jackson:             PASSWORD SPRAY (user=password)
- NIGHT WATCH
  - tim.butler:     Password in ldap description / mssql execute as login
  - leah.mitchell:          (see starks)
  - nathan.berry:      (see mormont)
- MORMONT
  - nathan.berry:      ACL writedacl-writeowner on group Group4
- Dev_Group1 :       cross forest group

labb.LOCAL
- LANISTERS
  - colin.knox:   ACL genericall-on-user sean.harris / ACL forcechangepassword on jaime.lanister
  - elizabeth.forsyth:   ACL genericwrite-on-user sean.harris
  - irene.duncan:   ACL self-self-membership-on-group Domain Admins
  - sean.harris:  DOMAIN ADMIN labb
- BARATHEON
  - benjamin.robertson:  DOMAIN ADMIN labb
  - katherine.gibson: 
  - carol.russell:
  - jasmine.lewis: ACL genericall-on-computer dc01 / ACL writeproperty-self-membership Domain Admins
- SMALL COUNCIL
  - alexander.sharp:    ACL writeproperty-on-group Domain Admins
  - rebecca.peake:        ACL genericall-on-group Domain Admins
  - sally.paterson:   ACL write owner on group Domain Admins

prod.LOCAL
- TARGERYEN
  - ian.abraham: DOMAIN ADMIN prod
  - emma.short:  
  - carol.ellison:      mssql trusted link
- DOTHRAKI
  - nicholas.grant:         mssql admin / GenericAll on viserys (shadow credentials) / GenericAll on ECS4
- Prod_Group1:       cross forest group
- Prod_Group2:                 cross forest group

### Computers Users and group permissions

- labb
  - DC01 : dc01.labb.local (Windows Server 2019) (labb DC)
    - Admins : benjamin.robertson (U), sean.harris (U)
    - RDP: Group8 (G)

- dev
  - DC02 : dc02.dev.labb.local (Windows Server 2019) (dev DC)
    - Admins : melanie.johnston (U), zoea.newman (U), jack.piper (U)
    - RDP: Group3(G)

  - SRV02 : srv02.prod.local (Windows Server 2019) (IIS, MSSQL, SMB share)
    - Admins: nathan.berry (U)
    - RDP: Group4 (G), Group5 (G), Group3 (G)
    - IIS : allow asp upload, run as NT Authority/network
    - MSSQL:
      - admin : leah.mitchell
      - impersonate : 
        - execute as login : samwel.tarlly -> sa
        - execute as user : kevin.randall -> dbo
      - link :
        - to srv03 : leah.mitchell -> sa

- prod
  - DC03  : dc03.prod.local (Windows Server 2016) (prod DC)
    - Admins: ian.abraham (U)
    - RDP: Group1 (G)

  - SRV03 : srv03.prod.local (Windows Server 2016) (MSSQL, SMB share)
    - Admins: nicholas.grant (U)
    - RDP: Group2 (G)
    - MSSQL :
      - admin : nicholas.grant
      - impersonate :
        - execute as login : carol.ellison -> sa
      - link:
        - to srv02: carol.ellison -> sa


## ROAD MAP
- [X] Password reuse between computer (PTH)
- [X] Spray User = Password
- [X] Password in description
- [X] SMB share anonymous
- [X] SMB not signed
- [X] Responder
- [X] Zerologon
- [X] Windows defender
- [X] ASREPRoast
- [X] Kerberoasting
- [X] AD Acl abuse 
- [X] Unconstraint delegation
- [X] Ntlm relay
- [X] Constrained delegation
- [X] Install MSSQL
- [X] MSSQL trusted link
- [X] MSSQL impersonate
- [X] Install IIS
- [X] Upload asp app
- [X] Multiples forest
- [X] Anonymous RPC user listing
- [X] Child parent domain
- [X] Generate certificate and enable ldaps
- [X] ADCS - ESC 1/2/3/8
- [X] Certifry
- [X] Samaccountname/nopac
- [X] Petitpotam unauthent
- [X] Printerbug
- [X] Drop the mic
- [X] Shadow credentials
- [ ] Add LAPS
- [ ] Add Applocker
- [ ] Zone transfert
- [ ] GPO abuse
- [ ] Mitm6
- [ ] Wsus
- [ ] Sccm
- [ ] Exchange

## MISC commands

### Force replication (no more used)

- On dragonstone play as domain admin user :
```
repadmin /replicate dc01.labb.local dragonstone.labb.local dc=labb,dc=local /full
```

### vagrant usefull commands (vm management)

- start all lab vms :
```
vagrant up
```

- start only one vm :
```
vagrant up <vmname>
```

- stop all the lab vm :
```
vagrant halt
```

- drop all the lab vm (because you want to recreate all) (carrefull : this will erase all your lab instance)
```
vagrant destroy
```

- snapshot the lab (https://www.vagrantup.com/docs/cli/snapshot)
```
vagrant snapshot push
```

- restore the lab snapshot (this could break servers relationship, reset servers passwords with fix_trust.yml playbook)
```
vagrant snapshot pop
```

### ansible commands (provisionning management)
#### Play only an ansible part
- only play shares of member_server.yml :
```
ansible-playbook member_server.yml --tags "shares"
```

#### Play only on some server
```
ansible-playbook -l dc2 domain_controller.yml
```

#### Add some vulns
```
ansible-playbook vulns.yml
```

## Troubleshooting

- In most case if you get errors during install, don't think and just replay the main playbook (most of the errors which could came up are due to windows latency during installation, wait few minutes and replay the main.yml playbook)
```
ansible-playbook main.yml
```

### Ansible-playbook

#### old Ansible version

```bash
ERROR! no action detected in task. This often indicates a misspelled module name, or incorrect module path.
 
The error appears to have been in '/home/hrrb0032/Documents/mission/GOAD/roles/domain_controller/tasks/main.yml': line 8, column 3, but maybe elsewhere in the file depending on the exact syntax problem.
 
The offending line appears to be:
 
- name: disable enhanced exit codes
^ here
```

solution : upgrade Ansible

##### old ansible.windows version
```bash
ERROR! couldn't resolve module/action 'win_powershell'. This often indicates a misspelling, missing collection, or incorrect module path.
```

- solution: reinstall ansible.windows module :
```bash
ansible-galaxy collection install ansible.windows --force
```

### winrm

```bash
PLAY [DC01 - dc01] *******************************************************

 

TASK [Gathering Facts] ***********************************************************
fatal: [192.168.56.10]: FAILED! => {"msg": "winrm or requests is not installed: No module named winrm"}

 

PLAY RECAP ***********************************************************************
192.168.56.10              : ok=0    changed=0    unOldable=0    failed=1    skipped=0    rescued=0    ignored=0   
```

solution : pip install pywinrm



### winrm send input timeout

```bash
TASK [Gathering Facts] ****************************************************************************************************************************************************
[WARNING]: ERROR DURING WINRM SEND INPUT - attempting to recover: WinRMOperationTimeoutError
ok: [192.168.56.11]
```

solution : wait or if crashed then re-run Ansible script



### Domain controller : ensure Users are present 

```bash
TASK [domain_controller : Ensure that Users presents in ou=<kingdom>,dc=labb,dc=local] ***************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was:    at Microsoft.ActiveDirectory.Management.Commands.ADCmdletBase`1.ProcessRecord()
failed: [192.168.56.10] (item={u'key': u'rebecca.peake', u'value': {u'city': u"King's Landing", u'password': u'_W1sper_$', u'name': u'Lord Varys', u'groups': u'Group8', u'path': u'OU=Users,OU=Finance,OU=labb,DC=labb,DC=local'}}) => {"ansible_loop_var": "item", "changed": false, "item": {"key": "rebecca.peake", "value": {"city": "King's Landing", "groups": "Group8", "name": "Lord Varys", "password": "_W1sper_$", "path": "OU=Users,OU=Finance,OU=labb,DC=labb,DC=local"}}, "msg": "Unhandled exception while executing module: An unspecified error has occurred"}

```
 solution : re-run Ansible script

## Special Thanks to

- Thomas Rollain (tests & some vulns writing)
- Quentin Galliou (tests)

## Links
- https://unicornsec.com/home/siem-home-lab-series-part-1
- https://github.com/jckhmr/adlab
- https://www.jonathanmedd.net/2019/09/ansible-windows-and-powershell-the-basics-introduction.html
- https://www.secframe.com/badblood/
- https://josehelps.com/blog/2019-08-06_building-a-windows-2016-dc/
- https://medium.com/@vartaisecurity/lab-building-guide-virtual-active-directory-5f0d0c8eb907
- https://www.ansible.com/blog/an-introduction-to-windows-security-with-ansible
- https://github.com/rgl/windows-domain-controller-vagrant
- https://www.sconstantinou.com/powershell-active-directory-delegation-part-1/
- https://www.shellandco.net/playing-acl-active-directory-objects/
- https://github.com/clong/DetectionLab
- https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces
- ...

## Note
- This repo is based on the work of [jckhmr](https://github.com/jckhmr/adlab) and [kkolk](https://github.com/kkolk/mssql)
