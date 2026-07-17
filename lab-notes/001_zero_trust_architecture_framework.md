# Zero Trust Architecture Framework
## Total Compromise Assumption: Home Lab Security Model

**Date:** July 2026
**TLP:** CLEAR
**Category:** Reference / Framework
**Status:** Living Document
**Next:** `lab-notes/002_zero_trust_implementation_sequence.md`

---

## Threat Model

### Core Assumption

Every layer of the existing network infrastructure is treated as potentially
compromised before any remediation begins. This includes ISP-provided
equipment, existing home network devices (smart TVs, IoT devices, household
phones), the ISP itself at the infrastructure level, and any device purchased
with an unverified supply chain.

### What "Compromised" Means in Practice

A compromised layer does not necessarily mean active exploitation. It means
that layer cannot be trusted to protect the confidentiality or integrity of
traffic passing through it. Even without active malicious use, ISP
infrastructure provides passive surveillance capability by design.

### What This Model Does Not Claim

This framework does not assume a targeted nation-state attacker. It assumes the
threat model of a person who has reason to compartmentalize research activity,
uses one home network for both sensitive and general-purpose activity, cannot
fully verify hardware supply chain integrity, and operates under a jurisdiction
where ISP metadata collection is legal and routine.

---

## The Layers: What Each Is and What It Protects

### Layer 0: The ISP (Uncontrollable)

**What it is:** The ISP's physical infrastructure. Every packet leaving the
home rides their network.

**What the ISP sees regardless of configuration:** your IP address at all
times, the IP addresses of every server you connect to, the timing and volume
of every connection, DNS queries in plaintext unless encrypted DNS is
configured, and the fact that you are using a VPN or Tor (though not what
passes through them).

**What the ISP cannot see with proper configuration:** the content of
HTTPS-encrypted traffic, DNS queries when encrypted DNS is active, destinations
beyond a properly configured VPN server, and the content of Tor traffic.

**Honest ceiling:** You cannot hide your existence on their network. The goal
is making bulk passive surveillance less informative, not achieving
invisibility.

---

### Layer 0.5: The ISP Account

**What it is:** The online account that controls the ISP-provided gateway.

**Why it is a layer:** The framework models the ISP as an infrastructure
threat, but the account itself is a separate attack surface. A party holding
the account credentials can reconfigure the gateway remotely, including
disabling bridge mode and re-inserting ISP equipment into the routing chain,
with no physical access required. A single credential can undo the boundary.

**Mitigation:** Strong unique password and multi-factor authentication on the
ISP account. Where the ISP offers a public hotspot broadcast from customer
equipment, opt out through account privacy settings. Treat the account as part
of the trust boundary, not as billing plumbing.

---

### Layer 1: The Gateway (ISP Equipment)

**What it is:** The ISP-managed modem/router on the premises.

**The problem:** The ISP retains administrative access. They can push firmware,
read diagnostic data, and the device phones home on a schedule. You do not
fully control it.

**Mitigation: bridge mode.** Disabling the routing function so the device acts
only as a signal converter. It handles the physical link to the ISP but passes
all routing decisions to a router you own placed behind it. The ISP still sees
traffic at Layer 0 but loses visibility into internal network topology: which
devices talk to which, and the segment structure.

**What bridge mode does not fix:** The ISP still sees all traffic leaving the
network at the infrastructure level. Bridge mode removes internal visibility,
not ISP-level visibility.

---

### Layer 2: Your Router (The Controllable Boundary)

**What it is:** A router you physically own, running open source firmware
(OpenWrt or a comparable auditable platform), placed behind the gateway in
bridge mode.

**Why open source firmware matters:** Proprietary firmware may contain
telemetry, remote access, or vendor dependencies. Open source firmware is
auditable, community-reviewed, and free of a manufacturer cloud dependency.
Updates come from the community, not the vendor.

**What the router controls:** all routing between devices and the internet,
network segmentation, DNS resolution for every device, directional firewall
rules, and connection logging.

**Boundary self-hardening:** Once bridge mode is active, this router holds the
public-facing IP and becomes the internet-facing surface. Its own posture
matters: the WAN zone should drop unsolicited input, the admin interface should
be unreachable from the WAN, SSH should use key authentication only and be
reachable from the LAN alone, and the configuration should be exported and
backed up after every change. A boundary device with no configuration backup is
a rebuild-from-memory outage waiting to happen.

---

### Layer 3: Network Segmentation

**What it is:** Logical separation of devices into isolated segments that cannot
communicate without explicit routing rules.

**Why it matters:** On a flat network where every device shares one subnet, any
compromised device can potentially observe traffic from all others.
Segmentation contains a compromise to its segment.

**Trust-class structure (labels are generic; assignments are per-deployment):**

| Trust Class | Internet Access | Access to Other Classes |
|-------------|-----------------|-------------------------|
| Trusted workstations | Yes | None |
| IoT and untrusted | Yes, restricted | None |
| Household / personal | Yes | None |
| Guest | Yes, isolated | None |
| Management | No | Admin only |

**Key rule:** The IoT class has internet access but zero ability to reach the
trusted-workstation class. A compromised device on one segment cannot reach
machines on another regardless of what it attempts.

**Addressing note:** Specific subnet ranges are chosen at configuration time
and recorded in private notes, not here. Non-default ranges add mild friction
against anyone assuming the network matches standard tutorial layouts.

**IPv6 note:** Segmentation rules must cover IPv6, not only IPv4. A firewall
that isolates segments on IPv4 while leaving IPv6 unfiltered has a second door.
Where IPv6 is not being managed deliberately, it should be disabled at the WAN
until it is.

---

### Layer 3.5: Wireless

**What it is:** The radio layer. Wireless is a distinct boundary the moment the
owned router's Wi-Fi comes up, and it needs its own standard rather than
inheriting whatever the migration left in place.

**Standard:**
- WPA3-SAE where all devices support it; WPA2/WPA3 mixed mode only during a
  device-migration window, closed afterward.
- 802.11w management frame protection enabled.
- One SSID per trust class, each bound to its segment, once segmentation is
  live.
- Rotate any passphrase carried over from prior equipment once migration is
  stable. A credential inherited from the old boundary is not a new boundary.

---

### Layer 4: DNS Security

**What it is:** Encrypted DNS prevents the ISP from seeing domain lookups in
plaintext.

**The problem without it:** Even with HTTPS on all web traffic, standard DNS
queries travel in plaintext. The ISP sees every domain looked up, when, and how
often. Behavioral profiling from DNS logs alone is significant.

**The DNS leak problem:** A VPN encrypts the connection to the VPN server. If
DNS queries are configured to use the ISP's resolvers and escape the tunnel,
the ISP still sees every lookup. The VPN protects the destination while the
lookups stay visible.

**Make the encrypted path explicit, not incidental.** A privacy property should
not depend on a transparent firewall redirect that a future config change could
silently remove. The resolver and the encrypted transport should be configured
directly on the device that performs resolution, and verified: a packet capture
on the WAN interface during normal browsing should show no plaintext port 53
traffic. Any visible port 53 confirms a leak.

**IPv6 parallel path:** Confirm that IPv6 router advertisements are not handing
out ISP DNS servers, which would create a second plaintext resolution path that
ignores the filtering resolver entirely.

**Solution stack:** configure the router or resolver for DNS-over-HTTPS or
DNS-over-TLS; use a privacy-respecting upstream whose jurisdiction is chosen
deliberately; run a local sinkhole (Pi-hole or equivalent) for network-wide
query logging and filtering; and verify no leak with the capture above.

---

### Layer 5: Encryption

**What it is:** Protecting data confidentiality at rest, in transit, and on
mobile devices. Encryption is a first-class control here, not a byproduct of
other layers.

**At rest (desktop and laptop):** Full disk encryption (LUKS on Linux) makes
stored data inaccessible without the passphrase if a device is seized or
stolen. Enable swap encryption in the same pass; unencrypted swap can write
decrypted file contents, passwords, and session keys to disk in plaintext. For
portable sensitive data, an encrypted container (VeraCrypt) opens on any machine
with the passphrase. Backups of an encrypted disk must themselves be encrypted:
an unencrypted backup defeats the protection. Verify backup encryption before
trusting it.

LUKS (Linux Unified Key Setup) is an open standard, jurisdiction-neutral, owned
by no government or corporation. There is no recovery path if the passphrase is
lost and no backup exists: plan accordingly before the reinstall, not after.

**At rest (mobile):** Modern Android and iOS devices encrypt storage by default;
verify it. A strong PIN is the correct primary authentication, not biometric
alone: in many US circuits a PIN carries Fifth Amendment protection a fingerprint
does not. For research-related mobile data, prefer local encrypted backups over
cloud backups, which the provider can be compelled to produce.

**In transit:** Prefer WireGuard for router-level VPN (far smaller attack
surface than OpenVPN, faster handshake). Use SSH key authentication (Ed25519)
for access to VMs and secondary machines; disable password authentication once
keys work.

**Communications:** Signal for sensitive coordination (end-to-end encrypted,
minimal metadata). For email that cannot use Signal, an end-to-end encrypted
provider in a favorable jurisdiction. Communications encryption protects
content, never metadata: who, when, and how often remain visible.

---

### Layer 6: Traffic Encryption and Routing

**What it is:** Tools that encrypt traffic content or obscure destinations from
the ISP.

- **VPN:** encrypts traffic between device or router and the VPN server. The ISP
  sees your IP, the VPN server IP, volume, and timing, but not destinations or
  content. Trust shifts from the ISP to the VPN provider: choose a no-log,
  audited one. Router-level VPN routes an entire trust class through the tunnel.
- **Tor:** routes through multiple encrypted relays so no single node sees both
  source and destination. Slower; appropriate for highest-sensitivity traffic,
  not general use.
- **HTTPS:** standard web encryption, already active on most sites. The ISP sees
  the server IP, timing, and volume, but not page content or specific URLs
  beyond the domain.

---

### Layer 7: Browser Hardening and Identity Compartmentalization

**What it is:** Controls above the network layer. VPN and encrypted DNS protect
what leaves the network; this layer addresses what happens inside the browser
session.

**Fingerprinting:** A unique profile assembled from canvas rendering, WebGL
output, fonts, resolution, timezone, and dozens of other signals, requiring no
cookies or login. It happens inside the HTTPS connection, so a VPN does not
change it. Mitigate with `privacy.resistFingerprinting`, a minimal extension set
(each added extension makes the profile more unique, not less), and uBlock
Origin for script blocking. No configuration eliminates fingerprinting; the goal
is blending into a large population.

**Account-layer correlation:** Logging into any account links the session to an
identity regardless of IP or VPN, and that linkage is compellable from the
provider. Keep research activity in separate accounts with no shared recovery
email, phone, or payment path, and never open a personal account in a research
browser context. Container isolation (Firefox Multi-Account Containers) keeps
cookies and sessions from leaking between contexts.

---

### Layer 8: Device Hardening

**What it is:** Configuring individual machines to minimize attack surface.

Full disk encryption (see Layer 5); a default-deny inbound firewall with only
required services allowed; unused services disabled; regular OS and application
patching; separate non-admin accounts for daily use; browser hardening per Layer
7; and SSH key authentication for all remote access, with password auth disabled
once keys are confirmed.

---

### Layer 9: Monitoring and Detection

**What it is:** Visibility into what is actually happening on the network so
anomalies are detectable.

- **DNS sinkhole (Pi-hole or equivalent):** logs every query from every device,
  surfaces unexpected behavior (a device querying unusual servers at odd hours),
  and blocks known ad and tracker domains network-wide.
- **Network security monitoring (Security Onion or equivalent):** ingests
  traffic on a mirror of the monitored segment; Suricata for intrusion detection,
  Zeek for traffic analysis, Kibana for investigation. Runs in a VM under a
  kernel-native hypervisor (KVM).

**Baseline-and-deviation method:** observe without alerting for at least two
weeks to establish normal per-device patterns, then alert on deviation.
Deviation cannot be detected without knowing normal.

---

### Layer 10: Data Compartmentalization

**What it is:** Separating sensitive material from general-use data and from the
internet entirely, mapped to a disclosure tier.

| Tier | Marking | Location | Use |
|------|---------|----------|-----|
| Public | TLP:CLEAR | Public repository | Sanitized methodology, tooling, lab documentation |
| Working | TLP:AMBER | Third-party working storage | Reference, templates, build history, session context |
| Private | TLP:RED | Air-gapped offline storage | Personal threat assessment, unsanitized research, speculation |

**Rule:** Speculation and open threads never leave the private tier. Only
findings that pass a sanitization checklist are promoted to public. Nothing
becomes public by accident.

---

## What This Framework Does Not Solve

**Hardware supply chain backdoors:** Firmware-level implants installed before
purchase are hard to detect without lab equipment. Network behavior monitoring
catches most practical cases: a backdoored device that cannot exfiltrate is
limited in what it can do.

**ISP-level traffic analysis:** No consumer tool fully hides existence, volume,
or timing from the ISP. The framework reduces information richness, not
visibility to zero.

**Physical security:** This framework addresses network and software threats.
Physical access bypasses most controls; full disk encryption mitigates it for
stored data.

**Devices you do not control:** Household or guest devices cannot be fully
hardened. Segmentation ensures a compromised one cannot reach trusted machines,
but cannot prevent data collection by the apps on it.

**Application-layer exfiltration:** A compromised application on a trusted
machine can exfiltrate over permitted HTTPS to its own server. A DNS sinkhole
blocks known-bad domains but cannot inspect encrypted content. The mitigation is
minimizing installed software, preferring auditable open source, and watching
for unexpected new outbound connections.

---

*TLP:CLEAR*
*Tags: [zero-trust] [networking] [opsec] [dns] [reference]*
