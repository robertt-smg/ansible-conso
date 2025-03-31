# smg-ansible

# Hyper-V Switch / WSL

- Installiere VMWware Workstation player
- Setze IP Addresse in VMNet8
- %ALLUSERSPROFILE%\vmnetdhcp.conf  Anpassen / siehe ./VMWarePlayer/vmnetdhcp.conf
- %ALLUSERSPROFILE%\vmnetnat.conf  Anpassen / siehe ./VMWarePlayer/vmnetdhcp.conf
- registry HKLM\System\CurrentControlSet\Services\VMNetDHCP\Parameters\Virtuall
- https://www.assono.de/blog/change-nat-vmnet8-subnet-in-vmware-player
- Reboot
- Create Switch in Hyper-V Manager "VM Bridge", External with "VMNet8"
- evtl. Enable Forwarding on VMNet8: netsh interface ipv4 set interface 28 forwarding=enabled ()
- In guest, before checking IP with host/ping turn firewall off !
- WSL user mirrored network

=> https://www.aligrant.com/web/blog/2022-12-16_creating_multiple_vlans_on_windows_11
=> 

# ansible on wsl
Wir verwenden podman um ansible auf wsl zu installieren.
Daher muss vor dem ausführen von script immer erst auf den ansible container geconnectet werden.
wsl muss als den Netzwerk Type networkingMode=mirrored verwenden, damit der VM Bridged Switch der VMs erreichbar ist 

# Testen von docker containern
Docker container können in podman getestet werden, podman-proxy kann Ports nach Windows spiegeln
Dazu muss die lokale IP 127.0.0.X und der Port in docker-compose.yaml angegeben sein

# Test Linux VM
Die Linux server können direkt aus bash mit up.sh gestartet werden.
Diese werden dynamisch in hyper-V erstellt
Da diese auf dem VM Bridged Netzwerk laufen, sind diese direkt vom Windows Host erreichbar, ohne podman-proxy und Port Forwarding