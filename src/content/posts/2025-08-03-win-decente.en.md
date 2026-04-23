---
title: "A Decent Windows"
date: "2025-08-03"
categories: ["sysadmin"]
tags: ["linux","wsl","windows","win11","ubuntu","development","dualboot","clean","lean","tiny","mini"]
draft: false
cover:
  image: "/img/posts/logo-win-decente.svg"
  hidden: true
---


<img src="/img/posts/logo-win-decente.svg" alt="linux development logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

According to the Spanish RAE dictionary, *Deshinchar: v. To deflate or reduce something swollen*. That's what this post is about: stripping Windows 11 of the apps, services, and options that simply get in the way — *bloatware* — that eat resources and clutter the experience. Works on a fresh Windows install as well as on one already in use.

<br clear="left"/>
<style>
table {
    font-size: 0.8em;
}
</style>
<!--more-->

{{< admonition note "Windows series">}}

- Preparing a PC for [Dualboot Linux / Windows]({{< relref "2024-08-23-dual-linux-win.md" >}}) and installing Windows 11 Pro.
- Configuring [a decent Windows 11]({{< relref "2025-08-03-win-decente.md" >}}) by removing the cruft.
- Preparing [Windows for software development]({{< relref "2024-08-25-win-desarrollo.md" >}}): CLI, WSL2, and tools.
- Installing [VMWare Workstation Pro on Windows 11]({{< relref "2024-08-26-win-vmware.md" >}}) with a Windows 11 Pro VM.
- Installing a [Windows 11 VM on Proxmox]({{< relref "2025-08-04-proxmox-win.md" >}}) to run Windows 11 Pro on top of a Proxmox host.

{{< /admonition >}}

## Strategy

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-07.png" alt="Avoiding the cruft (source: dall-e)" width="400px" />
  <div class="image-caption">Avoiding the cruft (source: dall-e)</div>
</div>

The plan, in order:

1. Prepare the OS: updates and essentials (via a script of mine).
2. Activate Windows with [MAS](https://github.com/massgravel/Microsoft-Activation-Scripts).
3. Debloat with [Win11Debloat](https://github.com/Raphire/Win11Debloat). Alternatives: [Winhance](https://github.com/memstechtips/Winhance), [Andrew Taylor's Debloat 10/11](https://andrewstaylor.com/2022/08/09/removing-bloatware-from-windows-10-11-via-script/), [Tiny11 Builder](https://github.com/ntdevlabs/tiny11builder).
4. Finish off manually what the script doesn't cover.
5. Optional: [pre-debloated unattended install](#unattended-install) to replay the process on more machines.

## Step 1 — Prepare the OS

With Windows 11 already installed (normal install from the official ISO, or the [unattended](#unattended-install) one):

### Update the system

Start > "Update" > **Check for Updates** > apply all pending updates and reboot as required.

### Run the essentials script

This post is about stripping things, but a few basics are non-negotiable: Chrome, 7-Zip, VSCode, PowerShell 7, and PowerToys. I install them from PowerShell 5 as administrator, running a script from my repo.

1. Open PowerShell as Administrator: Start > search "PowerShell" > right-click > **Run as Administrator**.
2. Enable System Restore and allow script execution:

    ```PS1
    Enable-ComputerRestore -Drive "C:\"
    vssadmin resize shadowstorage /for=C: /on=C: /maxsize=10GB
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

3. Verify `winget` is present (it usually is on an up-to-date Win11) and accept its agreement:

    ```PS1
    winget list
    ```

4. Reboot.
5. Run the script — it installs Chrome, 7-Zip, VSCode, PowerShell 7, PowerToys, and downloads Win11Debloat. If you prefer another browser, install it manually:

    ```PS1
    iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/LuisPalacios/devcli/main/addons/windecente-inicio.ps1" -UseBasicParsing).Content
    ```

<div class="image-box">
  <img src="/img/posts/2025-08-03-win-decente-01.png" alt="Running the first automated script" width="800px" />
  <div class="image-caption">Running the first automated script</div>
</div>

> The script leaves Win11Debloat downloaded and ready for Step 3.

## Step 2 — Activate Windows

Two options:

**Retail key.** Buy a digital copy of Windows 11 Pro from an authorized reseller (cheap and quick, you get the key by email). Then: `Start > Settings > System > Activation > Change product key` and enter the key.

**MAS — [Microsoft Activation Script](https://github.com/massgravel/Microsoft-Activation-Scripts).** Open-source activator for Windows and Office. Includes HWID, Ohook, TSforge, KMS38, and Online KMS. Worth reading [the documentation](https://massgrave.dev/). I use it for VMs and lab work:

1. Open **PowerShell 7** as Administrator (the one Step 1's script installed).
2. Run:

    ```PS1
    irm https://get.activated.win | iex
    ```

3. Choose `(1) HWID for Windows activation`.
4. Verify in `Start > Settings > System > Activation`.

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-05.png" alt="MAS method" width="600px" />
  <div class="image-caption">MAS method</div>
</div>

> To activate Office, use `(2) Ohook` from the same script. See [the documentation](https://massgrave.dev/).

## Step 3 — Debloat with Win11Debloat

[Win11Debloat](https://github.com/Raphire/Win11Debloat) is lightweight and direct. Worth reading its [wiki](https://github.com/Raphire/Win11Debloat/wiki/) and the [default settings](https://github.com/Raphire/Win11Debloat/wiki/Default-Settings).

Step 1's script already dropped it in `C:\Users\[user]\Desktop\Win11Debloat\`.

1. Edit `Appslist.txt` with the apps to uninstall:

    ```PS1
    cd Desktop\Win11Debloat\Raphire-Win11Debloat-70ebe29
    notepad.exe Appslist.txt
    ```

    You can start from [this Appslist.txt](https://gist.githubusercontent.com/LuisPalacios/919d1150ad31bb0a19d1528a38e6da81/raw/Appslist.txt) — tick a few more than the defaults, except **Edge**: Win11Debloat itself recommends not touching it automatically. We'll do it by hand in Step 4.

2. Run the script and pick option 1:

    ```PS1
    .\Win11Debloat.ps1
    ```

    <div class="image-box">
      <img src="/img/posts/2025-08-03-win-decente-02.png" alt="Win11Debloat" width="600px" />
      <div class="image-caption">Win11Debloat - option 1</div>
    </div>

3. Reboot.

## Step 4 — Debloat manually

Time to wrap up what Win11Debloat doesn't cover.

{{< admonition tip "If you went the unattended route" >}}
Several of the sections below (registry, privacy, renaming Home, preinstalled apps, taskbar) are already baked into the ISO built with [UnattendedWinstall](#unattended-install). I flag them with **`[unattended ✓]`** in each heading — feel free to skip those.
{{< /admonition >}}

### Registry tweaks `[unattended ✓]`

Open PowerShell as administrator and run:

Disable "Let websites show me locally relevant content by accessing my language list":

```PS1
reg add "HKEY_CURRENT_USER\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d 1 /f
```

Set UAC to "Never notify":

```PS1
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f
```

### Remove Edge and set Chrome as default

Edge isn't cross-platform, so I remove it.

- **Start > Settings > Apps**:
  - **Installed Apps**: uninstall **Edge**.
  - Launch Google Chrome and set it as the default browser.
  - **Default apps > Google Chrome**: check that everything is assigned to Chrome.
  - **Apps for Websites**: all **off**.

### Privacy `[unattended ✓]`

- **Privacy & Security**:
  - Security > Windows Security > `Open Windows Security`: everything **On**.
  - Windows Permissions: **all off** (General, Speech, etc.).
  - App permissions > `Location`: **off**. The rest at defaults.

### Rename the user's home folder `[unattended ✓]`

During install, Windows creates the short username from the first 5 characters of your email (in my case `luisp`, with HOME at `C:\Users\luisp\`). To rename it ([full guide](https://www.elevenforum.com/t/change-name-of-user-profile-folder-in-windows-11.2133/)):

1. Enable the Administrator account:

    ```PS1
    net user Administrator /active:yes
    ```

2. Reboot and log in as Administrator (no password).
3. Find your user's SID:

    ```PS1
    Get-LocalUser | Select-Object Name, SID
    ```

4. In `regedit`, edit `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-...\ProfileImagePath` with the new path.
5. In Explorer, rename the folder from `C:\Users\luisp` to `C:\Users\luis`.
6. Create a symbolic link for compatibility with programs that still point to the old folder:

    ```PS1
    New-Item -ItemType SymbolicLink -Path "C:\Users\luisp" -Target "C:\Users\luis"
    ```

If the symlink misbehaves or the old folder gets re-created, delete it and use a Junction instead:

```PS1
rmdir C:\Users\luisp
mklink /J C:\Users\luisp C:\Users\luis
```

### Remove preinstalled apps `[unattended ✓]`

Start > right-click on icons you don't use > **Unpin** or **Uninstall** (in my case I removed LinkedIn and similar).

### Customize the Taskbar `[unattended ✓]`

- Right-click the taskbar icons and remove the ones you don't use.
- Start > search "Start settings":
  - Layout > **More pins**.
  - Show recently added apps: **off**.
  - Show recommended files...: **off**.
  - Show account notifications: **off**.
  - Show recently opened: **off**.

### Remove the English keyboard

Start > Settings > Time & Language > Language & Region > Preferred Languages > "..." > Options > Keyboards > **remove US** (leave only Spanish).

### File Explorer

Show hidden files, extensions, and the full path:

- Start > Settings > `System` > `For developers`:
  - Enable developer mode if not already on.
  - Go to `File Explorer`:
    - `Show file extensions`: **On**.
    - `Show hidden and system files`: **On**.
    - `Show full path in title bar`: **On**.
    - `Show empty drives`: **On**.

### File Sharing (SMB)

- Start > Settings > `Network and Internet` > `Advanced network settings > Advanced Sharing Settings`:
  - `File & Printer sharing`: **On**.
  - `Public folder sharing`: **On**.
- Start > Settings > System > About > `Advanced System Settings` > Computer Name > **Change**: verify it's on **WORKGROUP**.
- Enable SMB 1.0 only if you need compatibility with legacy machines:
  - Start > "Control Panel" > `Programs` > `Programs and features` > `Turn Windows features on or off`.
  - Enable **SMB 1.0/CIFS File Sharing Support**.

### Firewall

The default install puts the network on **Public**. If it's a private network, change it:

Start > Settings > Network & Internet > Ethernet (and WiFi) > **Private Network**.

To reduce Firewall alerts:

- Start > "Control Panel" > System & Security > Windows Defender Firewall:
  - `Advanced Settings`: review inbound and outbound rules.
  - `Change notification settings`: uncheck "Notify me when Windows Defender Firewall blocks a new app".

### Disable Cortana

- Start > search `gpedit.msc` and open the Policy Editor.
  - Navigate to `Computer Configuration > Administrative Templates > Windows Components > Search`.
  - Double-click **Allow Cortana** > **Disabled** > Apply.

### More preinstalled apps

Uninstall OEM crapware via PowerShell. What to uninstall depends on your OEM; [Should I Remove It?](http://www.shouldiremoveit.com) helps decide.

List all installed apps:

```PS1
Get-AppxPackage | Select Name, PackageFullName
```

Uninstall a specific one:

```PS1
Get-AppxPackage *AppName* | Remove-AppxPackage
```

### Unneeded services

Open `services.msc`, identify services you don't use (e.g. the `xbox*` ones), double-click > **Startup type: Disabled** > Apply.

### Performance: WinSAT

To check CPU, memory, disk, and graphics:

```PowerShell
winsat formal
Get-CimInstance Win32_WinSat
```

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-04.png" alt="Ready to get work done" width="600px" />
  <div class="image-caption">Ready to get work done</div>
</div>

The same steps apply to [Windows virtual machines]({{< relref "2024-08-26-win-vmware.md" >}}), with very good performance.

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-06.png" alt="Another optimized Windows 11, this time as a VMWare Workstation Guest" width="600px" />
  <div class="image-caption">Another optimized Windows 11, this time as a VMWare Workstation Guest</div>
</div>

### Maintenance

Useful commands as administrator:

- `chkdsk`: checks the disk and fixes issues.
- `sfc /SCANNOW`: verifies system file integrity.
- `dism /online /cleanup-image /restorehealth`: downloads and replaces corrupt files from Windows Update.

> **Heads up**: `sfc` had a long-standing false positive with `bthmodem.sys` (it would flag it as corrupt and remove it). If it happens to you, run `dism ... /restorehealth` to recover.

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-02.png" alt="Minimalist Start version" width="450px" />
  <div class="image-caption">Minimalist Start version</div>
</div>

## The devcli tool

If you spend a lot of time in the CLI, complement this post with [Windows for development]({{< relref "2024-08-25-win-desarrollo.md" >}}), where I cover CLI, Terminal, WSL2, and tools.

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-05.png" alt="Options galore" width="2560px" />
  <div class="image-caption">Options galore</div>
</div>

There I mention **[devcli](https://github.com/LuisPalacios/devcli)**, a project of mine for setting up the CLI environment on Linux, macOS, WSL2, and Windows. After *debloating*, it's worth preparing the CLI:

- Installs tools: git, curl, wget, nano, htop, tmux, fzf, bat, fd-find, ripgrep, tree, jq, lsd, zoxide.
- Installs Oh-My-Posh for any shell.
- Sets `LANG` (default `es_ES.UTF-8`) on Linux, macOS, and WSL2.
- Copies config files (see the `dotfiles` subdirectory).
- Copies my Git toolbox from [gitbox](https://github.com/LuisPalacios/gitbox).
- Creates handy scripts in `~/bin`: `e`, `s`, `confcat`.
- Installs FiraCode Nerd Font for icons in tools like `lsd`.

## Unattended install

To replay the process on more machines, it pays to automate the Windows install itself. I tried [UnattendedWinstall](https://github.com/memstechtips/UnattendedWinstall) and [WIMUtil](https://github.com/memstechtips/WIMUtil).

**1. Install Windows ADK** (to get [oscdimg.exe](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/oscdimg-command-line-options), used later):

- Download [Windows ADK](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install?source=recommendations), install it, and select only **Deployment Tools**.
- Copy the contents of `C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\` into a directory that's on your PATH.

**2. Run WIMUtil** from PowerShell as administrator:

```PowerShell
irm "https://github.com/memstechtips/WIMUtil/raw/main/src/WIMUtil.ps1" | iex
```

This generates a custom ISO using the `autounattend.xml` from [UnattendedWinstall](https://github.com/memstechtips/UnattendedWinstall):

- Select ISO, temp directory, **START**.
- Next > customize Windows > **Download UW** (pulls the UnattendedWinstall one). No answer file.
- Next > optionally "Add Drivers" from the Windows you're running it on.
- Next > Select Location > `win11-custom.iso`.
- **Create ISO**.

<div class="image-box">
  <img src="/img/posts/2025-08-03-win-decente-08.png" alt="Creating an unattended ISO" width="800px" />
  <div class="image-caption">Creating an unattended ISO</div>
</div>

**3. Test the ISO in a VM** (see [VMWare on Windows]({{< relref "2024-08-26-win-vmware.md" >}})):

- VMware Workstation > New virtual Machine > Typical > Installer disc > `win11-custom.iso`.
- The install only asks for language, time, keyboard, disk type, user, and security questions. Very quick.

> **Important**: at the end of the unattended install, **Defender and UAC are disabled**. Re-enable at least Defender.

<div class="image-box">
  <img src="/img/posts/2025-08-03-win-decente-09.png" alt="Final setup" width="650px" />
  <div class="image-caption">Final setup</div>
</div>

After reboot, install the VMware Tools and return to **Step 1** to finish off.

## Useful links

- **[Clink](https://github.com/chrisant996/)**: enriches CMD (`cmd.exe`) with Linux-style readline — colors, history, autocomplete.
- **[CCleaner](https://www.ccleaner.com/)**: general cleanup, though the interesting bits require the Pro license.
- **[BleachBit](https://www.bleachbit.org/)**: Open Source alternative to CCleaner (no Registry or performance optimization). Before installing the latest version, grab the [Visual Studio 2019 (VC++ 10.0) redistributable SP1 x86](https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe).
- **[TCPView](https://learn.microsoft.com/en-us/sysinternals/downloads/tcpview)**: live network connections (Sysinternals).
- **[Autoruns](https://learn.microsoft.com/en-us/sysinternals/downloads/autoruns)**: everything that launches automatically on Windows startup (more complete than Task Manager or MSConfig).
- **[Sysinternals Suite](https://learn.microsoft.com/en-us/sysinternals/downloads/)**: the full suite of advanced tools (Russinovich/Cogswell, maintained by Microsoft).
- **[autounattend.xml generator](https://schneegans.de/windows/unattend-generator/)** for Windows 10/11.
- **[Winhance](https://github.com/memstechtips/Winhance)**: after all the cleanup, there were still things left for Winhance to polish.

<div class="image-box">
  <img src="/img/posts/2025-08-03-win-decente-03.png" alt="Winhance - Windows Enhancement Utility" width="650px" />
  <div class="image-caption">Winhance - Windows Enhancement Utility</div>
</div>
