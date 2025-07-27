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

1. If you are familiar with Git, clone this repository to a temporary folder
   on your computer.
   Otherwise, click on the down arrow in the bright green button that says
   <kbd style="background: #238636; color: white; border-radius: 7px; padding: 6px;">&lt;&gt; Code &#9660;</kbd>,
   then click on **Download ZIP**.
   Unzip the downloaded file to a temporary folder on your computer.

2. Open a PowerShell window.
   One way to do this is to right-click the <kbd>Start</kbd> button and
   select **Windows PowerShell**.

3. Change to the directory where you cloned or downloaded this git repository
   and open the `Scripts` folder.
   For example, if you cloned or unzipped it to your `Downloads` folder,
   type something like this:

   ```powershell
   cd ~\Downloads\totalmix_multiuser\Scripts
   ```

4. Run the installation script:

   ```powershell
   .\install.ps1
   ```

5. If you are prompted to run the script, type `Y` and press Enter.

6. Restart your computer.

7. Login to various user accounts to verify that TotalMix works in each account.
   If you have an RME ARC USB, verify that it works in each account as well.
