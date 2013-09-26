About
-----

This script allow you to update your TYPO3 installation.
The script will download the latest TYPO3 branch release or specific version 
and extract the tarball to the script directory and create symlinks from your TYPO3 installation to the new release.


Installation
------------

1] Upload the script to your www directory OR download the script with wget:
```
wget --no-check-certificate "https://raw.github.com/der-berni/TYPO3-update/master/t3update.sh"
```

2] Allow your user to execute this script with a chmod

3] Execute the script

update your TYPO3 branch (mandatory)
```
./t3update.sh -p "/var/www/dummy package/"
```

update to a specific version
```
./t3update.sh -p "/var/www/dummy package/" -s "4.5.10"
```


Example of execution
------------

	**********************************************************************
	TYPO3 Update v.13.269
	**********************************************************************
	date                          : 2013-09-26 11:01
	TYPO3 path                    : /var/www/my_test/
	TYPO3 branch                  : 4.5
	current TYPO3 release         : 4.5.30
	latest TYPO3 release          : 4.5.30
	force update to TYPO3 release : 4.5.10
	checking symlink
	TYPO3 update success
