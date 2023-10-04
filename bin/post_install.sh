#!/bin/bash

username=makerspace
name='Maker Space'

#Create User
grep -E '^dialout:' /usr/lib/group >> /etc/group
grep -E '^users:' /usr/lib/group >> /etc/group
    #Allow Passwordless Login
    groupadd -r nopasswdlogin
adduser -mG nopasswdlogin,dialout,users -c "$name" $username

# #Automatic updates
git clone https://github.com/tonywalker1/silverblue-update.git /root/Downloads/AutoUpdate
(cd /root/Downloads/AutoUpdate && ./install.sh)
#rm -r /root/Downloads/AutoUpdate
    # sed -i 's/none/stage/g' /etc/rpm-ostreed.conf  #set to install if set to none
    # sed -i 's/check/stage/g' /etc/rpm-ostreed.conf #set to install if set to none
    # sed -i 's/#AutomaticUpdatePolicy/AutomaticUpdatePolicy/g' /etc/rpm-ostreed.conf #set to install if set to none
    # #systemctl reload rpm-ostreed
    # systemctl enable rpm-ostreed-automatic.timer --now

#Create Folders
mkdir /home/$username/Desktop /home/$username/Documents /home/$username/Downloads /home/$username/Music /home/$username/Pictures /home/$username/Public /home/$username/Templates /home/$username/Videos /home/$username/.icons /home/$username/.themes /home/$username/.applications

#User Autologin
sed -i "s/#User=/User=$username/g" /etc/sddm.conf
sed -i 's/#Session=/Session=plasma.desktop/g' /etc/sddm.conf

#Allow Passwordless Login
sed -i '1 i\auth       sufficient      pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/sddm
sed -i '1 aauth       sufficient      pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/kde

#Set user avatar
sudo cp /usr/share/plasma/avatars/photos/Pencils.png /var/lib/AccountsService/icons/$username
echo "[User]" | sudo tee /var/lib/AccountsService/users/$username
echo "Icon=/var/lib/AccountsService/icons/$username" | sudo tee -a /var/lib/AccountsService/users/$username

#Flatpak use system Theme
cp -r /usr/share/themes/* /home/$username/.themes
cp -r /usr/share/icons/* /home/$username/.icons

#Flatpak use system Theme
flatpak override --filesystem=~/.themes
flatpak override --filesystem=~/.icons
flatpak override --env=GTK_THEME=Adwaita-dark
flatpak override --env=ICON_THEME=breeze-dark

#Remove mounted boot drive
#sed -i '/boot/d' /etc/fstab

#Set Dark theme for root
#lookandfeeltool -a org.kde.breezedark.desktop
kwriteconfig5 --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop

#Set Dark theme for User
su $username <<'EOF'
kwriteconfig5 --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop
EOF

#Make UI more like windows
su $username <<'EOF'
kwriteconfig5 --file kdeglobals --group KDE --key ShowDeleteCommand false
kwriteconfig5 --file kdeglobals --group KDE --key SingleClick false
EOF

#Dissable forced logout
su $username <<'EOF'
kwriteconfig5 --file kscreenlockerrc --group Daemon --key Autolock false
kwriteconfig5 --file kscreenlockerrc --group Daemon --key LockOnResume false
kwriteconfig5 --file kscreenlockerrc --group Daemon --key LockGrace 300
EOF

#Install dependancies and set Login/Lockscreen to use defined keyboard
rpm-ostree install mesa-libGLU
rpm-ostree initramfs-etc --track=/etc/vconsole.conf
rpm-ostree apply-live




#Flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.inkscape.Inkscape org.blender.Blender org.freecadweb.FreeCAD org.librecad.librecad -y

#SheetCAM
(cd ~/Downloads && wget https://www.sheetcam.com/Downloads/akp3fldwqh/SheetCam_setupV7.1.35-64.bin --show-progress -nc -q && mkdir /home/$username/.applications && unzip SheetCam_setupV7.1.35-64.bin -d /home/$username/.applications/SheetCam)
rpm-ostree install mesa-libGLU
#mkdir /home/$username/.local/share/Applications
#mkdir /var/usrlocal/share/applications
#cat > ~/.local/share/applications/SheetCAM.Desktop << EOF
cat > /var/lib/flatpak/exports/share/applications/SheetCAM.desktop << EOF
[Desktop Entry]
Encoding=UTF-8
Value=1.0
Type=Application
Name=SheetCam TNG
GenericName=CAM software
Comment=SheetCam TNG V7.1.35
Categories=Graphics
Exec="/home/$username/.applications/SheetCam/data/run-sheetcam"
Icon=/var/home/$username/.applications/SheetCam/dataresources/sheetcamlogo.png
EOF
chmod +x /var/lib/flatpak/exports/share/applications/SheetCAM.desktop
update-desktop-database /var/lib/flatpak/exports/share/applications

#Allow user to apply updates
cat > /etc/polkit-1/rules.d/45-polkit-allow-updates.rules << 'EOF'
/* Allow users in to update or upgrade without authentication */
polkit.addRule(function(action, subject) {
    if (action.id == "org.projectatomic.rpmostree1.upgrade" || "org.projectatomic.rpmostree1.deploy" && subject.isInGroup("users")) {
        return polkit.Result.YES;
    }
});
EOF


















# cat > /etc/polkit-1/rules.d/45-polkit-allow-updates.rules << 'EOF'
# /* Allow users in to update or upgrade without authentication */
# polkit.addRule(function(action, subject) {
#     if (action.id == "org.projectatomic.rpmostree1.upgrade" && subject.isInGroup("users")) {
#         return polkit.Result.YES;
#     }
#     if (action.id == "org.projectatomic.rpmostree1.deploy" && subject.isInGroup("users")) {
#         return polkit.Result.YES;
#     }
# });
# EOF

# cat > /etc/polkit-1/rules.d/45-polkit-allow-updates.rules << 'EOF'
# /* Allow users in to update or upgrade without authentication */
# polkit.addRule(function(action, subject) {
#     if ((action.id == “org.projectatomic.rpmostree1.upgrade” || “org.projectatomic.rpmostree1.deploy”) && subject.isInGroup("users")) {
#         return polkit.Result.YES;
#     }
# });
# EOF

# ##etherwake without root
# mkdir /home/$username/.local/bin
# cp /usr/sbin/ether-wake /home/$username/.local/bin/etherwake
# setcap cap_net_raw+ep /home/$username/.local/bin/etherwake
