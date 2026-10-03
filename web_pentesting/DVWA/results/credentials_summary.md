# DVWA Credentials Summary

| Username | Password | Wordlist (full path) | Tool | Notes |
|----------|----------|------------------------|------|-------|
| admin    | password | /usr/share/wordlists/metasploit/http_default_pass.txt | Burp Intruder | Cluster bomb attack; response length outlier (4740 vs 4703 baseline) |
| pablo    | letmein  | /usr/share/wordlists/seclists/Passwords/Common-Credentials/Pwdb_top-1000.txt | wfuzz | First wordlist attempt, immediate hit |
| smithy   | password | /usr/share/wordlists/seclists/Passwords/Common-Credentials/Pwdb_top-1000.txt | wfuzz | First wordlist attempt, immediate hit |
| gordonb  | abc123   | /usr/share/wordlists/seclists/Passwords/Common-Credentials/Pwdb_top-1000.txt | wfuzz | First wordlist attempt, immediate hit |
| 1337     | charley  | /usr/share/wordlists/seclists/Passwords/Common-Credentials/Pwdb_top-10000.txt | wfuzz | Pwdb_top-1000.txt had zero hits; escalated to top-10000 |

## Usernames (found separately, via image endpoint fuzzing)

| Username | Wordlist (full path) | Tool |
|----------|------------------------|------|
| admin    | /usr/share/seclists/Usernames/xato-net-10-million-usernames.txt | ffuf |
| pablo    | /usr/share/seclists/Usernames/xato-net-10-million-usernames.txt | ffuf |
| smithy   | /usr/share/seclists/Usernames/xato-net-10-million-usernames.txt | ffuf |
| gordonb  | /usr/share/seclists/Usernames/xato-net-10-million-usernames.txt | ffuf |
| 1337     | /usr/share/seclists/Usernames/xato-net-10-million-usernames.txt | ffuf |

Note: a smaller shortlist (top-usernames-shortlist.txt) only caught `admin`; the full 8.3M-entry list was needed to catch the other 4 deliberately unusual DVWA usernames.
