Youcrypt
========

Youcrypt is (was) an attempt to give Dropbox-like shared folders for
all, **but with end-to-end encryption**. Using the FUSE-based encrypted
filesystem exposed by [EncFS](https://github.com/vgough/encfs), we
created a higher-layer app that managed multiple encrypted folders, as
well as folder sharing via a public key mechanism (hosted on
a PKI server at youcrypt.com).

The service is no longer maintained so this code is being open-sourced
under the GPLv3 license. 


Features
--------

 - Mac UI for Encrypted folders
 - Double-click encrypted folder to show contents, provided Youcrypt is
   running.
 - Share any encrypted folder with separate groups of people
 - Ability to encrypt folders and decrypt encrypted folders
 - Turn filename encryption on/off from UI

Screenshots
-----------

Encryption:
![Encryption][https://raw.github.com/anirudhvr/youcrypt/master/easyenc/Youcrypt/images/yc-1.png]


Folder icon for encrypted folders:
![Icon][https://raw.github.com/anirudhvr/youcrypt/master/easyenc/Youcrypt/images/yc-2.png]

Youcrypt supports filename encryption as well; decrypted view (via FUSE)
shown above. 
![Icon][https://raw.github.com/anirudhvr/youcrypt/master/easyenc/Youcrypt/images/yc-3.png]


Bugs
----

This is beta code so there may be several. In particular, this code may
not compile on Xcode 6, so some work remains.


Roadmap
-------

  * Compilation w/ Xcode 6
  * Integrate Keybase as the backend for PKI





