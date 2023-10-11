#!/bin/bash

# #Automatic updates
# git clone https://github.com/tonywalker1/silverblue-update.git /root/Downloads/AutoUpdate
# (cd /root/Downloads/AutoUpdate && ./install.sh)
#rm -r /root/Downloads/AutoUpdate
sed -i 's/none/stage/g' /etc/rpm-ostreed.conf  #set to install if set to none
sed -i 's/check/stage/g' /etc/rpm-ostreed.conf #set to install if set to none
sed -i 's/#AutomaticUpdatePolicy/AutomaticUpdatePolicy/g' /etc/rpm-ostreed.conf #set to install if set to none
#systemctl reload rpm-ostreed
systemctl enable rpm-ostreed-automatic.timer --now
#Is it running every hour?
#systemctl edit rpm-ostreed-automatic.timer

#Allow Passwordless Login
sed -i '1 i\auth       sufficient      pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/sddm
sed -i '1 aauth       sufficient      pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/kde

#Remove mounted boot drive
#sed -i '/boot/d' /etc/fstab

#Set Dark theme for root
lookandfeeltool -a org.kde.breezedark.desktop
#kwriteconfig5 --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop

#Allow user to apply updates
cat > /etc/polkit-1/rules.d/45-polkit-allow-updates.rules << 'EOF'
/* Allow users in to update or upgrade without authentication */
polkit.addRule(function(action, subject) {
    if (action.id == "org.projectatomic.rpmostree1.upgrade" && subject.isInGroup("users")) {
        return polkit.Result.YES;
    }
});
EOF
#     if (action.id == "org.projectatomic.rpmostree1.upgrade" || "org.projectatomic.rpmostree1.deploy" && subject.isInGroup("users")) {

#Install dependancies and set Login/Lockscreen to use defined keyboard
#rpm-ostree install kompare --idempotent #debug
rpm-ostree install mesa-libGLU webkit2gtk4.0 wine-core wine-core.i686 wine-ldap patch cabextract --idempotent
# rpm-ostree install mesa-libGLU #Required by SheetCAM
# rpm-ostree install webkit2gtk4.0 #Required by OrcaSlicer
# rpm-ostree install wine-core wine-core.i686 wine-ldap patch cabextract #Required by Vectric Aspire
                ##rpm-ostree install *.rpm #RPM's can be installed as a layer if required, or they can be extracted into /home/$username/.local i.e.
                ## rpm2cpio $HOME/Downloads/appimagelauncher.x86_64.rpm  | cpio -D $HOME/Downloads -idmv
                ## cp -r $HOME/Downloads/usr/* $HOME/.local
#rpm-ostree initramfs-etc --track=/etc/vconsole.conf #Use correct keyboard on Login screen? Doesn't seem to work
#rpm-ostree apply-live --allow-replacement


#Flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.inkscape.Inkscape org.blender.Blender org.gtk.Gtk3theme.Breeze -y
flatpak install flathub org.freecadweb.FreeCAD org.librecad.librecad -y
flatpak install flathub org.openscad.OpenSCAD com.vscodium.codium cc.arduino.IDE2 com.prusa3d.PrusaSlicer org.libreoffice.LibreOffice org.raspberrypi.rpi-imager -y

#Flatpak use system Theme
flatpak override --filesystem=~/.themes
flatpak override --filesystem=~/.icons
flatpak override --env=GTK_THEME=Adwaita-dark
flatpak override --env=ICON_THEME=breeze-dark


#Create user account
username=makerspace
name='Maker Space'

#clean up if we are going again
userdel $username
rm -r /home/$username

#Create User
grep -E '^dialout:' /usr/lib/group >> /etc/group
grep -E '^users:' /usr/lib/group >> /etc/group
    #Allow Passwordless Login
    groupadd -r nopasswdlogin
adduser -mG nopasswdlogin,dialout,users -c "$name" $username

#Set user avatar
cp /usr/share/plasma/avatars/photos/Pencils.png /var/lib/AccountsService/icons/$username
echo "[User]" | tee /var/lib/AccountsService/users/$username
echo "Icon=/var/lib/AccountsService/icons/$username" | tee -a /var/lib/AccountsService/users/$username

#User Autologin
sed -i "s/#User=/User=$username/g" /etc/sddm.conf
sed -i 's/#Session=/Session=plasma.desktop/g' /etc/sddm.conf

#Create link to user setup
mkdir /home/$username/Desktop
cat > /home/$username/Desktop/fetch_user_setup.sh << EOL
#!/bin/bash
bash <(curl -s https://raw.githubusercontent.com/alextrical/Fedora-Kinonite-Fablab-Kickstart/main/bin/user_setup.sh)
EOL
chmod +x /home/$username/Desktop/fetch_user_setup.sh
chown makerspace:makerspace -R /home/$username/Desktop

#Reboot post install, to apply changes
echo "System rebooting in 1 minute"
sleep 60
systemctl reboot