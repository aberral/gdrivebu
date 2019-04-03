# Using Google Drive as a backend for Duplicity and programming with crontab in Centos 7

Duplicity can use Google Drive as a cloud backend for your Linux Workstation backups. These repo was implemented on Centos 7.

# Required software
First, we need to install python and pip, or update them in case we have installed previously both.
```{bash}
# Enabling epel repository
$ sudo yum install epel-release
$ sudo yum -y update
$ sudo yum -y install python-pip
```
# First Step
We need to Setup OAth Credentials in Google API.
 * Go to https://console.developers.google.com/
 * Create Project a new project and give it some sensible name like “Duplicity Backup”
 * From the Dashboard click on “Enable API”
 * Search for “Google Drive”, select and enable it
 * Select “Credentials” from the panel on the left
 * Use the arrow on the Create Credentials button (the blue one) to select “OAuth Client ID”
 * For Application Type, select “Other” and name the client. I used “Duplicity”. Click Create.
 * Save your credentials somewhere safe, although they can easily be regenerated (you can download them).
 
 # Configure Duplicity
 ```{bash}
$ cd /home/aberral
$ mkdir .duplicity
$ cd .duplicity
$ touch credentials
$ touch excludes
```
 Paste the following text in your credentials file:
```{}
client_config_backend: settings
client_config:
   client_id: [id from previous step (GOOGLE)]
   client_secret: [secret from previous step (GOOGLE)]
save_credentials: True
save_credentials_backend: file
save_credentials_file: gdrive.cache
get_refresh_token: True
```
The excludes file will contain all the files you don't want to back up or ignore. In my case all /data inside my home contains cel files, .rdata, and geo datasets that are large files and will take an eternity to backup. A good starting point is:
```{}
**~
**.bak
**.cache
**cache**
**debuginfo**
**duplicity-**
**Trash**
**.iso
**/.cache/**
**/Cache/**
**/Downloads/**
**/BUILD/**
**/Music/**
**/temp/**
**/.thumbnails/**
**/.beagle/**
```

# Running Duplicity for the first time
The first time, Duplicity will return a URL, click the link, log in and paste the code in the shell. With the next command we can backup the home directory to Google drive. The first run is always (unless we specify it) a full backup, and every subsequent run will be incremental.

```{bash}
$ GOOGLE_DRIVE_SETTINGS=/home/aberral/.duplicity/credentials duplicity --exclude-filelist /home/aberral/.duplicity/excludes ~/ gdocs://[username]@gmail.com/[folder that will contain the backup files]
```
The files in the repo contains:
  * credentials: my credentials to make the backup
  * excludes: the file list I wont back up
  * readme_alberto: some useful commands that are worth noticing
    ```{bash}
    # Verify
    sudo GOOGLE_DRIVE_SETTINGS=~/.duplicity/credentials duplicity verify gdocs://aberralgonzalez@usal.es/trinitybu  ~/
    ## Para ver que archivos han cambiado: ... duplicity -v4 ...

    # List Files in backup
    sudo GOOGLE_DRIVE_SETTINGS=~/.duplicity/credentials duplicity list-current-files gdocs://aberralgonzalez@usal.es/trinitybu

    # Restore
    sudo GOOGLE_DRIVE_SETTINGS=~/.duplicity/credentials duplicity --file-to-restore  "file to restore" gdocs://aberralgonzalez@usal.es/trinitybu
    "archivo"

    sudo GOOGLE_DRIVE_SETTINGS=~/.duplicity/credentials duplicity --file-to-restore apt/sources.list gdocs://aberralgonzalez@usal.es/trinitybu
    /home/user/sources.list
    ```
  * backup.sh: the file with the commands and the route that config duplicity to back up things
  * execute.sh: the function that will be executed with crontab to do the backup. It also generates a logfile with the timestamp with the duplicity output.
 
 NOTE: Don't forget to give the files the right permisions to be properly executed.
 # The last step
 The final step is to set crontab to do the automated backcup
 ```{bash}
 $ crontab -e
 # We edit the crontab file to add the execute.sh script with the line:
 # @daily echo raistlin1640 | sudo -S /scripts/./execute.sh
 # it will do a daily incremental backup, to google drive and the external HDD, plus a full backup every 90D / 30D to google drive / external HDD
 $ crontab -l
 # To check the task was saved
 ```
 
 
 
 
 
