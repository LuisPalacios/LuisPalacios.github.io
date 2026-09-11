---
title: "SSH with 1Password"
date: "2026-09-04"
categories: ["sysadmin"]
tags:
  [
    "1password",
    "ssh",
    "ssh-agent",
    "git",
    "homelab",
    "security",
    "windows",
    "wsl",
    "macos",
    "linux",
  ]
draft: false
cover:
  image: "/img/posts/logo-1password-ssh.svg"
  hidden: true
---

<img src="/img/posts/logo-1password-ssh.svg" alt="SSH with 1Password logo" width="150px" height="150px" style="float:left; padding-right:25px" />

A few weeks ago I shelved my ["homemade Bitwarden"]({{< relref "2025-03-02-bitwarden.md" >}}) and moved to 1Password on the family plan. Yes, you have to pay, but sharing with the family and the ease of use make up for it. Shortly after migrating the passwords I ran into the _Developer_ tab and its **SSH agent**: private keys live in the vault, they sync themselves across my machines, and every use is authorized with a fingerprint or with Windows Hello.

By the way, I later found out that Bitwarden has had an SSH agent too since early 2025. You learn something new every day.

It sounded too good to be true, so I set out to check whether it fit my case: several workstations (macOS, Windows, Linux), lots of servers, network gear with SSH from another era, and more and more scripts and AI agents running `ssh` without me being at the keyboard. In this post I go through what I learned, how I set it up, and where I do NOT use it.

<br clear="left"/>
<!--more-->

## The problem

I've been using SSH keys since the last century, and over the years the whole thing has got out of hand. Three machines, each with its "equivalent" `~/.ssh/config` holding dozens of destinations, and on each one a handful of private keys that are supposedly the same but that I sync by hand and every now and then discover are not.

The destinations are not few either: servers and virtual machines at home, old network gear, the odd server on the Internet, relatives' homes I reach over VPN and, from time to time, customer servers where I'm a guest and they impose their own key on me.

And then there's how I use them: interactive sessions, scripts, and for a while now [AI agents in the terminal]({{< relref "2026-04-25-modo-ia-en-la-terminal.md" >}}) that call the system `ssh` without me typing anything.

The question was simple: does the 1Password SSH agent hold up to all of this, or is it going to leave me stranded at the first hurdle?

Short answer: **yes, it holds up**, and I'm keeping it. For everything I do while I'm at the keyboard, including scripts and AI agents launched from my terminal, it works beautifully. The only thing I leave out is what runs on its own with nobody around (cron, CI runners), which stays on well-restricted file-based keys.

## How it works

A quick refresher. When `ssh` connects to a server, the first thing they do is set up an encrypted channel and agree on a **session identifier**, a value unique to that connection. Only then does authentication begin, which with public key takes two rounds: the client offers a public key and asks "do you accept this one?", and if the server says yes, the client signs the session identifier with the private key and sends the signature. The server checks it against the public key it has in `authorized_keys` and opens the session.

<div class="image-box">
  <img src="/img/posts/2026-09-04-ssh-con-1password-01.png" alt="SSH public key authentication in five steps: encrypted channel, public key offer, acceptance, session identifier signature and session opening" width="700px" />
  <div class="image-caption">The server never sees the private key: it only verifies a signature against the public key it has in authorized_keys.</div>
</div>

Two details of this dance matter later on. One: the client offers keys **in order**, and every "I don't accept it" counts as a failed attempt against the server's limit, which by default is six. Two: the private key is only used for signing, so an agent that asks for confirmation asks you just once, for the key the server has already accepted.

With 1Password the only thing that changes is who signs. The 1Password agent speaks the standard `ssh-agent` protocol, so for the OpenSSH client there's nothing new: when it's time to sign, `ssh` asks the agent through a socket (or a _named pipe_ on Windows), 1Password checks that it's unlocked, asks for your fingerprint if that process didn't have permission yet, signs inside its own process and returns **only the signature**.

<div class="image-box">
  <img src="/img/posts/2026-09-04-ssh-con-1password-02.png" alt="Flow of an SSH authentication with the 1Password agent: the server requests the signature, the client delegates it through the agent socket and 1Password returns only the signature" width="800px" />
  <div class="image-caption">The ssh client talks to 1Password over a socket or named pipe; the private key never leaves the 1Password process.</div>
</div>

The private key never leaves 1Password: it's not on disk unencrypted, it's not loaded into the memory of `ssh` or your shell, and with the vault locked the agent doesn't even have it in memory.

### Compared with the usual suspects

The **good old `ssh-agent`** loads the decrypted key into memory once and never asks again. Convenient, but the key still lives in a file on every machine and syncing is your problem. **gpg-agent** does something similar with a lot more ceremony; I used it for years and I don't miss it. **Hardware keys** (YubiKey and friends) isolate the key best of all, but every device is a different key and you have to touch the key on every operation. **SSH certificates** with a CA are the "enterprise" solution, and for a homelab it's using a sledgehammer to crack a nut.

1Password sits at a very reasonable middle ground: isolation, biometric authorization per use, automatic sync and zero private files on disk. In exchange, it needs the desktop app open and unlocked. And that's the catch.

## Where I use it and where I don't

It's not "all or nothing". The 1Password agent takes care of:

- **Interactive sessions** to any destination.
- **Scripting from the workstation**, including heredocs and pipes with `tar`.
- The **AI agents** I launch from an unlocked desktop session.
- Everything that is **Git** over SSH.

And the classic file-based keys keep everything that has nobody in front of a screen: cron, systemd timers, CI runners and scripts that run on a server without a user session. For those cases the key lives on disk and, above all, is restricted in the destination's `authorized_keys` with `command="..."` and no shell, no port forwarding and no agent forwarding. A key with no person behind it that can only run one specific script is an acceptable risk; one with a full shell is not.

This isn't some exotic limitation of 1Password: any agent that asks a person for authorization fails in exactly the same way when there's no person.

## How many keys?

There are four reasonable strategies. **One for everything** is the most convenient and the worst idea: if it gets compromised, you have to change it on every server the same day. **One per host** is the opposite extreme: revoking is trivial, but with dozens of destinations the maintenance is hell. **One per machine** is what I had before, and with 1Password it stops making sense, because the key is no longer tied to the machine. And **one per purpose**: group destinations by trust domain, so that if a key falls the damage stays within that group.

I'm going with the last one. I ended up with six:

| Key              | Type    | Destinations                                          |
| ---------------- | ------- | ----------------------------------------------------- |
| `Homelab`        | ed25519 | Servers, VMs and containers at home                   |
| `Network`        | ed25519 | Network gear with current firmware                    |
| `Network Legacy` | RSA     | Old switch that only understands `ssh-rsa`            |
| `VPS`            | ed25519 | Virtual machines in the cloud                         |
| `Clientes`       | ed25519 | Relatives' homes and customers who accept my key      |
| `Git`            | ed25519 | Forgejo and GitHub (and signing commits, if you want) |

Having few keys also has a practical advantage: not hitting the server's limit of six attempts. It happened to me on day one: eight keys in the agent, the right one at the end, and a `Too many authentication failures`. Ten seconds of panic and a lesson well learned.

I avoid it in two ways, and I use both. **From the client**, with `IdentitiesOnly yes` on every `Host` and an `IdentityFile` pointing to the **public key** (`.pub`) downloaded from 1Password and stored in `~/.ssh/keys/`. OpenSSH lets you specify just the public key to use the matching private key from the agent, so `ssh` asks for that key and no other. **From the agent**, with the `agent.toml` file, where the order of the blocks is the order in which the keys are offered:

{{< codefile path="snippets/2026-09-04-ssh-con-1password/agent.toml" lang="toml" title="agent.toml — key order and visibility" >}}

Two warnings about this file. As soon as it exists, only the keys listed are offered. And it's a per-machine file: it doesn't travel with the vault, you have to copy it to every computer.

## Setting it up on each machine

It starts the same way everywhere: _Settings > Developer > Use the SSH Agent_. As soon as you enable it, 1Password asks whether it may store the key names on disk; I say yes, because an item's name is not a secret and that way the authorization prompt says "SSH Homelab" instead of a truncated fingerprint. And in _Settings > General_, on all three platforms, I leave 1Password in the menu bar or tray and starting at login: if you close the app, the agent dies with it.

What changes per system is where the agent listens and which SSH client talks to it.

**macOS.** The agent listens on a socket inside the 1Password folder, and the app offers to edit `~/.ssh/config` to point to it. My recommendation: **don't let it**. Copy the snippet and put it in a separate file that gets included at the end of the config, for a reason I explain in the next section. And if you use `ControlMaster`, remember that connections already open don't re-authenticate: to really test it, `ssh -o ControlPath=none host`.

**Linux.** The socket is `~/.1password/agent.sock`. Two warnings: the agent **does not work with the Flatpak or Snap installs**, so install 1Password from its repository, as I describe in [Linux for development]({{< relref "2024-07-25-linux-desarrollo.md" >}}); and if you use GNOME, its keyring already exports an `SSH_AUTH_SOCK` that can override 1Password's. That's why I prefer `IdentityAgent` in the config to fighting environment variables.

**Windows 11.** There's no socket here: 1Password listens on the same _named pipe_ that Microsoft's native OpenSSH uses. That's why you have to **disable the "OpenSSH Authentication Agent" service** before enabling 1Password's (the app itself asks you to), and that's why the Windows `ssh.exe` uses the 1Password agent for every host without configuring anything. I installed it back in the day exactly as I describe in [Windows for development]({{< relref "2024-08-25-win-desarrollo.md" >}}).

Git Bash is another story: its `ssh` doesn't know how to talk to named pipes. The fix is to use Microsoft's from there too, with `core.sshCommand` in Git pointing to the full path `C:/Windows/System32/OpenSSH/ssh.exe` and prepending that directory to the `PATH` in `~/.bashrc`, because Git for Windows puts its own directories first at startup.

**WSL.** The official route is to delegate to the Windows `ssh.exe` with a few aliases, with two consequences: the Windows `~/.ssh/config` is used, not WSL's, and every new tab asks for approval again. The alternative I use is a bridge with `socat` and `npiperelay` that creates the socket at `~/.1password/agent.sock`, the same place as on Linux, so that the same config works on both:

{{< codefile path="snippets/2026-09-04-ssh-con-1password/1password-agent-relay.sh" lang="bash" title="~/.local/bin/1password-agent-relay.sh — WSL → 1Password bridge" >}}

To check that the agent responds, on any of the platforms, `ssh-add -l` should list the keys in the vault.

## One config for all three machines

My goal was to have **a single** `~/.ssh/config`, identical on all three machines, where the only thing that changes per platform is the agent's path. The solution is a base file plus an `Include config.d/*.conf`, where on each machine only its platform file exists.

{{< codefile path="snippets/2026-09-04-ssh-con-1password/config" lang="bash" title="~/.ssh/config — identical base on all three machines" >}}

{{< codefile path="snippets/2026-09-04-ssh-con-1password/macos.conf" lang="bash" title="~/.ssh/config.d/macos.conf" >}}

{{< codefile path="snippets/2026-09-04-ssh-con-1password/linux.conf" lang="bash" title="~/.ssh/config.d/linux.conf (also on WSL with the bridge)" >}}

{{< codefile path="snippets/2026-09-04-ssh-con-1password/windows.conf" lang="bash" title="~/.ssh/config.d/windows.conf" >}}

Three decisions that deserve an explanation:

**The `Include` goes at the end.** It's the opposite of what you'll see in almost every example, but in `ssh_config` the **first** value found for each option wins. If the global `IdentityAgent` were at the top, the customers' `IdentityAgent none` would never apply. Specific at the top, general at the bottom. And watch out: an `Include` that comes after a `Host` block belongs to that block, which is why the `Host *` with the defaults goes right before it. If `ssh -G destination` doesn't show you `identityagent`, this is why.

**Keys that aren't in 1Password.** For the customers who impose their own key, the block carries `IdentityAgent none` and an `IdentityFile` pointing to the file-based key. `ssh` doesn't even ask the agent. It works on all three platforms, Windows included.

**ForwardAgent off.** Forwarding the agent leaves a socket on the intermediate host that anyone with root there can use for as long as your session lasts. With 1Password the damage is limited to whatever you authorize at that moment, but I prefer `ForwardAgent no` and, when I have to hop through an intermediate host, `ProxyJump`, which opens a second connection from my machine without exposing anything on the hop.

The old network gear has its own block that re-enables `ssh-rsa`, and I cover it in the server section.

## Git

With SSH sorted, Git comes almost for free: the `Host` entries for GitHub and for my Forgejo use the `Git` key with `IdentitiesOnly yes`. If you have several accounts, the host alias trick I described in [Multi-account Git]({{< relref "2024-09-21-git-multicuenta.md" >}}) still holds, each alias with its own `.pub`.

And if you want to sign commits, since Git 2.34 you can do it with SSH keys instead of GPG, and 1Password ships its own signer. The shared `.gitconfig` ends up like this, moving what changes per system, which is the signer's path, out to a local file:

{{< codefile path="snippets/2026-09-04-ssh-con-1password/gitconfig" lang="ini" title="~/.gitconfig — shared across all three machines" >}}

Note that `user.signingkey` is the **full public key**, not a path. The most reliable way to get the local part is to open the key's item in the app, click _Configure Commit Signing_ and copy the snippet it generates for your system. I don't sign commits myself, by the way: I leave it here in case you're interested.

## Scripts and AI agents

This is where the decision was really at stake. What rules here are two settings in _Settings > Developer_: **when it asks** (by default, once per application and key, and "application" includes its subprocesses, so authorizing the terminal covers the `ssh` that an AI agent launches from inside it) and **how long it remembers** (by default, until 1Password locks; it can be extended to a number of hours).

And one thing you need to be clear about: `BatchMode=yes` disables **ssh's own** prompts, not the 1Password dialog, which is a different application. So there are three scenarios:

1. **1Password unlocked and the terminal already authorized.** Everything works without any prompt. This is the normal case.
2. **1Password locked.** The agent throws up an unlock prompt and `ssh` sits there waiting. The script, or the AI agent, looks hung until you unlock.
3. **Request from an app that isn't in the foreground.** 1Password doesn't bother you with the prompt and leaves the request pending; you see it as _SSH request waiting_ on the tray icon. This is the one that has most often made me think the AI agent had hung.

My checklist so that nothing hangs:

- 1Password open and **unlocked**.
- Before letting the AI agent loose, a manual `ssh` from that same terminal to authorize the application and the key.
- For long sessions, extend how long the approval is remembered.
- If an SSH command goes more than a few seconds without output, look at the 1Password icon before killing anything.
- `IdentitiesOnly yes` on every `Host`: a single prompt per connection, not five.
- None of this applies to cron or runners. Those go with a file-based key and `command=`.

## Server side

Good news: on Linux servers there's nothing to change, because the signatures 1Password produces are normal OpenSSH signatures. The only thing I do is take the chance to tidy up the `authorized_keys`: a comment on each line saying which key it comes from, remove the keys of machines that no longer exist, and make sure the server doesn't allow password logins.

Three special cases:

**Virtual machines in the cloud.** The `authorized_keys` isn't entirely yours: the provider's agent writes it from the instance or project metadata, and whatever you add by hand disappears at the next sync. The new key gets added where the others live, with the provider's tool.

**Windows as a server.** If the user is an administrator, the keys don't go in their `authorized_keys` but in `C:\ProgramData\ssh\administrators_authorized_keys`. Check `sshd_config` before pasting the key in the wrong place. And one more thing: from an SSH session into that Windows box, the 1Password agent is **not available**, because it only serves processes from your desktop session. To hop from there to somewhere else, you have to be at the keyboard.

**Old network gear.** My main switch runs firmware from more than a decade ago and as a user key it only understands `ssh-rsa`. That's why the `Network Legacy` key is RSA (1Password imports RSA keys without any trouble) and that's why its block in the config re-enables `ssh-rsa` and an old key exchange, which OpenSSH disabled by default years ago. On the switch, the key is registered by its MD5 fingerprint, computed with `ssh-keygen -l -E md5` on the downloaded `.pub`. A warning: the agent signs with SHA-1 while leaving a complaint in its log, and there have been versions of 1Password where it stopped doing so. If one day your old gear stops letting you in right after an update, you know where to start looking.

The wireless controller, with current firmware, is another world: it accepts ed25519 and modern ciphers, so it uses the normal `Network` key and needs no exception at all.

## Security

Before trusting it I wanted to understand what it protects me from and what it doesn't. A **malicious local process** can write to the socket, and the protection is the prompt: 1Password tells you which process is asking for which key and you approve or deny. If one shows up that you weren't expecting, _Deny_ and go investigate. **Someone with root on my machine**, with file-based keys, walks off with them, full stop; with 1Password there's nothing on disk to take, and they'd have to wait for me to unlock and approve. It's not invulnerable, but the bar goes up a lot. And a **compromised intermediate host** with the agent forwarded can use it for as long as the session lasts, hence `ForwardAgent no` and `ProxyJump`.

My hardening checklist:

- Biometric authorization enabled.
- 1Password auto-locks after a few minutes of inactivity and when the screen locks.
- Approvals that are forgotten on lock, except for long sessions with AI agents.
- `ForwardAgent no` and `IdentitiesOnly yes` on every `Host`.
- `agent.toml` so the agent only offers what it's supposed to offer.
- Review the agent's _Activity_ tab in the app every now and then.

## Migrating from files

I did it in four steps, without rushing and without deleting anything until the end.

**Inventory.** On each machine, which private keys there are and which `Host` in the config uses them. With that I built a table: file, machine, destinations.

**Regenerate or import.** For everything modern I generated **new** ed25519 keys inside 1Password, so the private key has never existed on a disk. For the old switch I imported the RSA key I already had. For the customers, each one according to their rules.

**Testing in parallel.** I downloaded the `.pub` files to `~/.ssh/keys/` and, host by host, always the same recipe: upload the new public key using the old key; log in forcing only the new one with `ssh -o IdentitiesOnly=yes -i ~/.ssh/keys/homelab.pub host`; if it gets in, remove the old one from `authorized_keys` keeping a copy; point the config block to the new `.pub`; and finally `ssh host` without forcing anything. Five minutes per host and no scares.

**Retire and delete.** Before deleting anything, I moved the private keys no `Host` referenced any more into a `~/.ssh/retired/` directory and gave them a few days' grace. I also took the chance to pull out of the config the passwords I had jotted down in comments; they now live in 1Password, which is where they belonged. Then, gone. What really protects them is that all three disks are encrypted.

## Common problems

| Error                                                      | Cause                                                                                  | Fix                                                              |
| ---------------------------------------------------------- | -------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `Could not open a connection to your authentication agent` | `IdentityAgent` points to a socket that doesn't exist, or 1Password isn't running      | Check the socket and that the agent is enabled under _Developer_ |
| `invalid format` on a `.pub`, then it asks for a password  | 1Password is closed: with no agent, `ssh` tries to read the `.pub` as a private key    | Open 1Password; the warning goes away on its own                 |
| `Too many authentication failures`                         | The agent offers more than six keys                                                    | `IdentitiesOnly yes` with the `.pub`, and order `agent.toml`     |
| `agent refused operation`                                  | 1Password refused to sign: request denied, vault locked or a regression with `ssh-rsa` | Check the prompt, update 1Password                               |
| `no matching key exchange method found`                    | The destination only offers old algorithms                                             | Re-enable them only for that `Host`                              |
| `Permission denied (publickey)` with `IdentitiesOnly`      | The `.pub` doesn't match any key in the agent, or that key isn't in `agent.toml`       | `ssh-add -l` and compare fingerprints                            |
| `ssh` hung with no output from a script or AI agent        | 1Password locked or prompt suppressed because it's in the background                   | Unlock and look for _SSH request waiting_ on the icon            |
| Nothing works in Git Bash                                  | It's using its own `ssh`, which doesn't talk to the pipe                               | `core.sshCommand` and `PATH` to the Windows `ssh.exe`            |

## Conclusion

I love it. The feeling of opening any of the three machines, typing `ssh pve`, touching the sensor and being in, without having copied a single file, is one of those you don't go back from. And the prompt that tells you _who_ is asking for _which_ key is a control I didn't have with `ssh-agent`.

But it's important to be clear about the limit: the 1Password agent is for people. Everything that runs on its own, with nobody around, stays on well-restricted file-based keys. And AI agents are somewhere in between: they work beautifully as long as you're there with the vault unlocked, and they stare into the void as soon as you're not.

## References

Consulted on 4 September 2026. Anything I've claimed in this post that doesn't appear here, take it as my own experience or opinion.

| Type      | Links                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1Password | [Get started with the SSH agent](https://developer.1password.com/docs/ssh/get-started/), [SSH agent config file](https://developer.1password.com/docs/ssh/agent/config/), [Advanced use cases](https://developer.1password.com/docs/ssh/agent/advanced/), [Security](https://developer.1password.com/docs/ssh/agent/security/), [Agent forwarding](https://developer.1password.com/docs/ssh/agent/forwarding/), [Compatibility](https://developer.1password.com/docs/ssh/agent/compatibility/) |
| 1Password | [Use the SSH agent with WSL](https://developer.1password.com/docs/ssh/integrations/wsl/), [Sign Git commits with SSH](https://developer.1password.com/docs/ssh/git-commit-signing/), [Manage SSH keys](https://developer.1password.com/docs/ssh/manage-keys/)                                                                                                                                                                                                                                  |
| OpenSSH   | [ssh_config(5)](https://man.openbsd.org/ssh_config), [sshd_config(5)](https://man.openbsd.org/sshd_config), [Release notes 8.8](https://www.openssh.com/txt/release-8.8)                                                                                                                                                                                                                                                                                                                       |
| Windows   | [OpenSSH key management (Microsoft)](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement), [npiperelay (albertony's fork)](https://github.com/albertony/npiperelay)                                                                                                                                                                                                                                                                                  |
| Community | [Git Bash and 1Password SSH not working](https://www.1password.community/discussions/developers/git-bash-and-1password-ssh-not-working/142552), [1Password release notes](https://releases.1password.com/mac/stable/)                                                                                                                                                                                                                                                                          |
