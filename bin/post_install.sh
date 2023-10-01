#!/bin/bash

username=makerspace
name='Maker Space'

#Create User
grep -E '^dialout:' /usr/lib/group >> /etc/group
grep -E '^users:' /usr/lib/group >> /etc/group
    #Allow Passwordless Login
    groupadd -r nopasswdlogin
useradd -mG nopasswdlogin,dialout,users -c "$name" $username

# #Automatic updates
# sed -i 's/none/stage/g' /etc/rpm-ostreed.conf  #set to install if set to none
# sed -i 's/check/stage/g' /etc/rpm-ostreed.conf #set to install if set to none
# sed -i 's/#AutomaticUpdatePolicy/AutomaticUpdatePolicy/g' /etc/rpm-ostreed.conf #set to install if set to none
# #systemctl reload rpm-ostreed
# systemctl enable rpm-ostreed-automatic.timer --now
git clone https://github.com/tonywalker1/silverblue-update.git /root/Downloads/AutoUpdate
(cd /root/Downloads/AutoUpdate && ./install.sh)
#rm -r /root/Downloads/AutoUpdate

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
mkdir /home/$username/.icons /home/$username/.themes
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




#Flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.inkscape.Inkscape org.blender.Blender org.freecadweb.FreeCAD org.librecad.librecad -y

#SheetCAM
(cd ~/Downloads && wget https://www.sheetcam.com/Downloads/akp3fldwqh/SheetCam_setupV7.1.35-64.bin --show-progress -nc -q && mkdir /home/makerspace/Applications && unzip SheetCam_setupV7.1.35-64.bin -d /home/makerspace/Applications/SheetCam)
rpm-ostree install mesa-libGLU
#mkdir /home/makerspace/.local/share/Applications
mkdir /var/usrlocal/share/applications
cat > /var/usrlocal/share/applications/SheetCAM.Desktop << 'EOF'
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Terminal=false
Exec=/home/makerspace/Applications/SheetCam/data/run-sheetcam
Name=SheetCAM
Icon=/var/home/makerspace/Applications/SheetCam/data/resources/Bitmaps/Cutter.ico
EOF
chmod +x /var/usrlocal/share/applications/SheetCAM.Desktop

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
# mkdir /home/makerspace/.local/bin
# cp /usr/sbin/ether-wake /home/makerspace/.local/bin/etherwake
# setcap cap_net_raw+ep /home/makerspace/.local/bin/etherwake