#!/bin/bash
pkg install wget openssl-tool proot -y
folder=ubuntu-fs
if [ -d "$folder" ]; then
	first=1
	echo "Ubuntu is installed."
	exit
fi
arch=`dpkg --print-architecture`
tarball="${arch}-rootfs.tar.gz"
if [ "$first" != 1 ]; then
	if [ ! -f $tarball ]; then
		case $arch in arm|arm64|x86|x86_64)
		    echo "Download Rootfs, this may take a while base on your internet speed."
		    wget "https://github.com/CypherpunkArmory/UserLAnd-Assets-Ubuntu/releases/download/v0.0.6/${arch}-rootfs.tar.gz" -O $tarball;;
		    *)
		    echo "Rootfs not found."
		    exit;;
		esac
	fi
	cur=`pwd`
	mkdir -p "$folder"
	cd "$folder"
	echo "Decompressing Rootfs, please be patient."
	tar -xf ${cur}/${tarball}
	cd etc
	rm -rf bash.bashrc
	wget https://raw.githubusercontent.com/JagadBumi/rootfs/main/bash.bashrc
	cd "$cur"
fi
mkdir -p ubuntu-binds
bin=start-ubuntu.sh
echo "writing launch script"
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
command+=" -r /data/data/com.termux/files/home/ubuntu-fs"
if [ -n "\$(ls -A /data/data/com.termux/files/home/ubuntu-binds)" ]; then
    for f in /data/data/com.termux/files/home/ubuntu-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b /data/data/com.termux/files/home/ubuntu-fs/root:/dev/shm"
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
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

echo "Setting up pulseaudio so you can have music in distro."
pkg install pulseaudio -y
if grep -q "anonymous" ~/../usr/etc/pulse/default.pa;then
    echo "module already present"
else
    echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> ~/../usr/etc/pulse/default.pa
fi

echo "exit-idle-time = -1" >> ~/../usr/etc/pulse/daemon.conf
echo "Modified pulseaudio timeout to infinite"
echo "autospawn = no" >> ~/../usr/etc/pulse/client.conf
echo "Disabled pulseaudio autospawn"
echo "export PULSE_SERVER=127.0.0.1" >> ubuntu-fs/etc/profile
echo "Setting Pulseaudio server to 127.0.0.1"

termux-fix-shebang $bin | echo "fixing shebang of $bin"
chmod +x $bin | echo "making $bin executable"
rm -rf $tarball | echo "removing image for some space"
echo "You can launch Ubuntu with the ./${bin} script"
ls
