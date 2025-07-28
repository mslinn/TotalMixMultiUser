# RME TotalMix Multi-User Scripts

See [Multi-User Windows Support for RME TotalMix and ARC USB](https://www.mslinn.com/av_studio/320-totalmix-multi-user.html).

These scripts allow you to use RME TotalMix and an optional ARC USB controller
with multiple user accounts on a Windows computer.
By default, TotalMix and ARC USB settings are stored in the user profile,
which means they are not shared across different user accounts.
This can be inconvenient if you have multiple users who need to access the same settings.

Thanks to [maggie33](https://forum.rme-audio.de/profile.php?id=40292)
for the concept and the prototype code.


## Installation

1. Open a PowerShell window.
   One way to do this is to right-click the <kbd>Start</kbd> button and
   select **Windows PowerShell**.

2. If you are familiar with Git, clone this repository to your home directory.

   a. The following syntax works in PowerShell and Bash:

      ```powershell
      cd ~
      git clone https://github.com/mslinn/TotalMixMultiUser.git
      ```

      The above command creates a directory named `TotalMixMultiUser`
      in your home directory.

   b. If you cloned the git repository,
     change to the directory where you cloned it to.
     For example, if you cloned it to your home folder, type something like this:

     ```powershell
     cd ~\TotalMixMultiUser
     ```

3. If you did not clone the git repository, download the ZIP file
   and unzip it to `~\TotalMixMultiUser` using PowerShell, then
   rename the directory to something meaningful, and then
   change to the new directory as follows:

   ```powershell
    $uri = "https://github.com/mslinn/TotalMixMultiUser/archive/refs/heads/master.zip"
    $dest = "~\Downloads\TotalMixMultiUser-master.zip"
    Invoke-WebRequest -Uri $uri -OutFile $dest
    Expand-Archive `
      -DestinationPath ~\ `
      -Force `
      -Path $dest
    Rename-Item `
      -Path "~/TotalMixMultiUser-master"
      -NewName "TotalMixMultiUser"
    cd ~\TotalMixMultiUser
    ```

4. Run the installation script:

   ```powershell
   Scripts\install.ps1
   ```

5. If you are prompted to run the script, type `Y` and press Enter.

6. Restart your computer.

7. Login to various user accounts to verify that TotalMix works in each account.
   If you have an RME ARC USB, verify that it works in each account as well.
   The log files for each user are stored in the
   `C:\ProgramData\Scripts\TotalMixMultiUser\Logs\` directory.
