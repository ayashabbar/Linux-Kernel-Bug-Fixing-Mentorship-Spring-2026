#Task 2: Generate a patch to the Makefile to add an extra version field and bot that kernel and send patch (use git send-email) Shuah Khan <skhan@linuxfoundation.org>


#Part 1: Modifying the Makefile
#Simply open the kernel's Makefile, located in the root directory in the source code, with vim text editor. 
#The first five lines will have EXTRAVERSION somewhere in it. 
#Change the value.
$ sudo vim Makefile

#build and boot again
$ make -j$(nproc) 2>&1 | tee build.log
$ sudo make INSTALL_MOD_STRIP=1 modules_install
$ sudo make install
$ sudo reboot
$ uname -a

#Part 2: Generating the Patch
$ git diff > Makefile.patch
$ git commit --allow-empty -m "Initial commit"
$ git format-patch -s --subject-prefix="PATCH" -1 HEAD


#Part 3: Sending the patch
#I followed the instructions 
