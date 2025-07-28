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
   The following syntax works in PowerShell and Bash:

    ```powershell
    cd ~
    git clone https://github.com/mslinn/TotalMixMultiUser.git
    ```

    The above command creates a directory named `TotalMixMultiUser`
    in your home directory.

3. If you did not clone the git repository, copy and paste the following commands
   into a PowerShell window.
   These commands download a ZIP file of the GitHub project and extracts it to
   the same directory that the `git clone` command would create.

   a. Download the ZIP file.

      ```powershell
      $uri = "https://github.com/mslinn/TotalMixMultiUser/archive/refs/heads/master.zip"
      $dest = "~\Downloads\TotalMixMultiUser-master.zip"
      Invoke-WebRequest -Uri $uri -OutFile $dest
      ```

   b. Unzip it to `~\TotalMixMultiUser` using PowerShell.

      ```powershell
      Expand-Archive `
        -DestinationPath ~\ `
        -Force `
        -Path $dest
      ```

   c. Rename the directory to the same name as the above `git clone`
      command would create.

      ```powershell
      Rename-Item `
        -Path "~/TotalMixMultiUser-master"
        -NewName "TotalMixMultiUser"
      ```

4. Change to the new directory.

   ```powershell
   cd ~\TotalMixMultiUser
   ```

5. Run the installation script:

   ```powershell
   Scripts\install.ps1
   ```

6. If you are prompted to run the script, type `Y` and press Enter.

7. Restart your computer.

8. Login to various user accounts to verify that TotalMix works in each account.
   If you have an RME ARC USB, verify that it works in each account as well.
   The log files for each user are stored in the
   `C:\ProgramData\Scripts\TotalMixMultiUser\Logs\` directory.
   Verify that each user has a log file in that directory
   and that the log file contains the expected information.
