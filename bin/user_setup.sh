#Create Folders
mkdir -p $HOME/.icons $HOME/.themes $HOME/.local/bin $HOME/.local/share/applications $HOME/git

#Flatpak use system Theme
cp -r /usr/share/themes/* $HOME/.themes
cp -r /usr/share/icons/* $HOME/.icons

#Set Dark theme for User
lookandfeeltool -a org.kde.breezedark.desktop
#kwriteconfig5 --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop

#Make UI more like windows
#kwriteconfig5 --file kdeglobals --group KDE --key ShowDeleteCommand false
kwriteconfig5 --file kdeglobals --group KDE --key SingleClick false

#Dissable forced logout
kwriteconfig5 --file kscreenlockerrc --group Daemon --key Autolock false
kwriteconfig5 --file kscreenlockerrc --group Daemon --key LockOnResume false
kwriteconfig5 --file kscreenlockerrc --group Daemon --key LockGrace 300




#SheetCAM
wget https://www.sheetcam.com/Downloads/akp3fldwqh/SheetCam_setupV7.1.35-64.bin --show-progress -nc -q -P ~/Downloads 
unzip ~/Downloads/SheetCam_setupV7.1.35-64.bin "data/*" -d $HOME/.local/share/SheetCam
cat > $HOME/.local/share/applications/SheetCAM.desktop << EOF
[Desktop Entry]
Encoding=UTF-8
Value=1.0
Type=Application
Name=SheetCam TNG
GenericName=CAM software
Comment=SheetCam TNG V7.1.35
Categories=Graphics
Exec="$HOME/.local/share/SheetCam/data/run-sheetcam"
Icon=$HOME/.local/share/SheetCam/data/resources/sheetcamlogo.png
EOF
chmod +x $HOME/.local/share/applications/SheetCAM.desktop
#update-desktop-database $HOME/.local/share/applications

#Lightburn
curl -s https://api.github.com/repos/LightBurnSoftware/deployment/releases/latest \
| grep "browser_download_url.*run" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -nc -O ~/git/LightBurn-Linux64.run --show-progress -qi -
chmod +x ~/git/LightBurn-Linux64.run
~/git/LightBurn-Linux64.run




#Install Inkscape extras
#Run Inkscape to create the required folders, with the correct permissions for the user
flatpak run org.inkscape.Inkscape

#Github Inkscape extensions - Managed repo
#https://stadtfabrikanten.org/display/IFM/MightyScape+Extension+Collection
cp /usr/bin/git $HOME/.local/bin/git

git clone https://gitea.fablabchemnitz.de/FabLab_Chemnitz/mightyscape-1.2.git $HOME/git/mightyscape
git -C $HOME/git/mightyscape pull #Update if we are running this script a second time, as Git clone will not update an existing repo
wget -nc https://bootstrap.pypa.io/get-pip.py --show-progress -P $HOME/Downloads
chmod +x $HOME/Downloads/get-pip.py
cp -R $HOME/git/mightyscape/extensions $HOME/.var/app/org.inkscape.Inkscape/config/inkscape/
#Create a script to run inside the sandbox, to install dependancies
cat > $HOME/git/mightyscape.sh << EOF
#!/bin/bash
export PATH="$HOME/.local/bin:$PATH"
$HOME/Downloads/get-pip.py
cat $HOME/git/mightyscape/requirements.txt | sed '/^#/d' | xargs -n 1 pip install --upgrade --quiet --no-cache-dir #use this in case the previous command failed (skip errors)
EOF
chmod +x $HOME/git/mightyscape.sh

flatpak run --command=$HOME/git/mightyscape.sh org.inkscape.Inkscape

#Github Inkscape extensions - Laser-Tool 
curl -s https://api.github.com/repos/JTechPhotonics/J-Tech-Photonics-Laser-Tool/releases/latest \
| grep "browser_download_url.*zip" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -nc -O $HOME/git/laser.zip -qi -
unzip $HOME/git/laser.zip "laser/*" -d "$HOME/.var/app/org.inkscape.Inkscape/config/inkscape/extensions"
#unzip /root/git/laser.zip "laser/*" -d "/var/lib/flatpak/app/org.inkscape.Inkscape/x86_64/stable/active/files/share/inkscape/extensions"

#Github Inkscape extensions - InkStitch https://github.com/inkstitch/inkstitch/releases/latest/download/inkstitch-3.0.1-linux.sh
curl -s https://api.github.com/repos/inkstitch/inkstitch/releases/latest \
| grep "browser_download_url.*linux.sh" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -nc -O $HOME/git/inkstitch-linux.sh --show-progress -qi -
chmod +x $HOME/git/inkstitch-linux.sh
flatpak run --command=$HOME/git/inkstitch-linux.sh org.inkscape.Inkscape


#Blender
#BlenderCAM #https://github.com/vilemduha/blendercam/blob/master/documentation/Blendercam%20Installation.md
git clone https://github.com/vilemduha/blendercam.git $HOME/git/blendercam
git -C $HOME/git/blendercam pull #Update if we are running this script a second time, as Git clone will not update an existing repo





#Appimage stuff
#AppImageLauncher 
curl -s https://api.github.com/repos/TheAssassin/AppImageLauncher/releases/latest \
| grep "browser_download_url.*-x86_64.AppImage" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -nc -O $HOME/Downloads/appimagelauncher-lite-x86_64.AppImage --show-progress -qi -
chmod +x $HOME/Downloads/appimagelauncher-lite-x86_64.AppImage
$HOME/Downloads/appimagelauncher-lite-x86_64.AppImage install
# curl -s https://api.github.com/repos/TheAssassin/AppImageLauncher/releases/latest \
# | grep "browser_download_url.*x86_64.rpm" \
# | cut -d : -f 2,3 \
# | tr -d \" \
# | wget -nc -O $HOME/Downloads/appimagelauncher.x86_64.rpm --show-progress -qi -
# #chmod +x $HOME/Downloads/appimagelauncher.x86_64.rpm
# rpm2cpio $HOME/Downloads/appimagelauncher.x86_64.rpm  | cpio -D $HOME/Downloads -idmv
# cp -r $HOME/Downloads/usr/* $HOME/.local

#OpenBuilds-CONTROL 
curl -s https://api.github.com/repos/OpenBuilds/OpenBuilds-CONTROL/releases/latest \
| grep "browser_download_url.*AppImage" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -nc -P $HOME/Applications --show-progress -qi -

#OrcaSlicer 
curl -s https://api.github.com/repos/SoftFever/OrcaSlicer/releases/latest \
| grep "browser_download_url.*AppImage" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -nc -P $HOME/Applications --show-progress -qi -

#Random notes, for things not needed, or not working correctly yet

# ##etherwake without root
# mkdir $HOME/.local/bin
# cp /usr/sbin/ether-wake $HOME/.local/bin/etherwake
# setcap cap_net_raw+ep $HOME/.local/bin/etherwake
