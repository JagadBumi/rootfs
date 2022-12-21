#!/bin/bash
folder=debian-fs
if [ -d "$folder" ]; then
	first=1
	clear
	echo "Debian is installed !"
	exit
fi
arch=`dpkg --print-architecture`
targz="debian-${arch}-rootfs.tar.gz"
if [ "$first" != 1 ]; then
	if [ ! -f $targz ]; then
		case $arch in arm|arm64|x86|x86_64)
		    clear
		    echo "Download Rootfs, this may take a while base on your internet speed."
		    pkg install proot pulseaudio openssl-tool -y
		    wget "https://github.com/CypherpunkArmory/UserLAnd-Assets-Debian/releases/download/v0.0.5/${arch}-rootfs.tar.gz" -O $targz;;
		    *)
		    clear
		    echo "Rootfs not found !"
		    exit;;
		esac
	fi
	cur=`pwd`
	mkdir -p $folder
	cd $folder
	echo "Decompressing Rootfs, please be patient."
	tar -xvzf $cur/$targz
	cd etc
	rm -rf bash.bashrc
	wget https://raw.githubusercontent.com/JagadBumi/rootfs/main/bash.bashrc
	cd $cur
fi
mkdir -p debian-binds
bin=start-debian.sh
echo "Writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
pulseaudio --start
## For rooted user: pulseaudio --start --system
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r ${cur}/debian-fs"
if [ -n "\$(ls -A ${cur}/debian-binds)" ]; then
    for f in ${cur}/debian-binds/* ; do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b ${cur}/debian-fs/root:/dev/shm"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to / 
command+=" -b /sdcard"
command+=" -b /storage"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ]; then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

echo "Setting up pulseaudio so you can have music in distro."
if grep -q "anonymous" ~/../usr/etc/pulse/default.pa; then
    echo "module already present"
else
    echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> ~/../usr/etc/pulse/default.pa
fi

echo "exit-idle-time = -1" >> ~/../usr/etc/pulse/daemon.conf
echo "Modified pulseaudio timeout to infinite"
echo "autospawn = no" >> ~/../usr/etc/pulse/client.conf
echo "Disabled pulseaudio autospawn"
echo "export PULSE_SERVER=127.0.0.1" >> ${cur}/ubuntu-fs/etc/profile
echo "Setting Pulseaudio server to 127.0.0.1"

termux-fix-shebang $bin | echo "Fixing shebang of $bin"
chmod +x $bin | echo "Making $bin executable"
rm -rf $targz | echo "Removing image for some space"
echo "You can launch Debian with the ./${bin} script"
ls
