#This report describes how to compile the Linux kernel on Ubuntu 22.04
#Step 0: Clone the source code
$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
$ cd linux

#Step 1: Install Build Dependencies
#I'm using Ubuntu 22.04. 
#On Ubuntu, the apt tool has ability to resolve the build dependencies from source package.
#This however requires enabling source packages channels from the source list. 
#To do this, edit the /etc/apt/source.list:
$ sudo vim /etc/apt/sources.list
#Uncomment (by removing the # in the beginning) the deb-src lines and run apt update. 

#Step 2: Build Dependencies
#After the apt update, install the build dependencies:
$ sudo apt build-dep linux

#According to BuildYourOwnKernel in Ubuntu community WiKi this may not be enough. 
#There are other package that may be needed:
$ sudo apt install libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf llvm


#Configuration
#Step 1: The /boot directory
#The /boot directory contains configuration for the current kernel. I used as a starting point:
$ cat /boot/config-$(uname -r) > .config

#Run the menuconfig
$ make menuconfig

#Step 2: Remove Debian-specific configs
#Some options in Ubuntu kernel configuration are configured specifically for Debian packaging the kernel binary.
#Those options may lead to error during mainline kernel compilation, as the mainline kernel tree is no Debian source package. 
#Those options needs to be removed.
#First, scroll down to the Cryptographic API, then Certificates for signature checking. 
#There should be a line that looks like this in the menuconfig:
(debian/canonical-certs.pem) Additional X.509 keys for default system keyring 

#This is the path of the key file used by Canoncial. 
#The debian directory in the path is specific for Debian packaging and doesn't exist in the mainline kernel.
#Remve the line. It should looks like this:
()    Additional X.509 keys for default system keyring

#Another file that needs to be removed is:
(debian/canonical-revoked-certs.pem) X.509 certificates to be preloaded into the system blacklist keyring

#Remove the path as well. It should now looks like this:
()      X.509 certificates to be preloaded into the system blacklist keyring

#Build and Install
#Step 1: make
#This is a very standard make. I tee the build log into another file:
#The build command takes hours to finish (It took me 4 hours and 40 minutes). I had to increase the swap file from 4G to 10G since my RAM is only 4G. 
#This will ensure that your build won't stop due to insufficient memory. 
#It is also important to mention that you should close any unnecessary applications such as web browsers (they take a huge amont of RAM)
#Lastly, I also had to stop the Pahole utility; it takes a huge amount of memory which made the OOM killer stops the whole process.
$ make -j$(nproc) 2>&1 | tee build.log

#Step 2: modules_install
#The next step would be installing the modules. 
#This however comes with a catch. If I install all modules without stripping them, the size of initrd.image would explode and is unable to boot. 
#So I stripped the module while installing:
$ sudo make INSTALL_MOD_STRIP=1 modules_install

#Step 3: Install the kernel
$ sudo make install

#Boot the kernel
#Step 1: Change GRUB next boot order with grub-reboot
#Instead of modifying the /etc/default/grub, I use grub-reboot the set the next boot entry.
$ sudo grub-reboot "Advanced options for Ubuntu>Ubuntu, with Linux 6.9.0-rc5"

#and reboot
$ sudo reboot


#Step 2: Confirm the kernel version
#After reboot, confirm kernel version using uname:
$ uname -a

#or using dmseg
$ sudo dmesg



