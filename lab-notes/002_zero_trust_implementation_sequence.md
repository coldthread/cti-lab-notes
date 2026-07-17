# Zero Trust Implementation Sequence
## Home Lab Build: Total Compromise Assumption Model

**Date:** July 2026
**TLP:** CLEAR
**Category:** Reference / Sequence
**Status:** Living Document
**Follows:** `lab-notes/001_zero_trust_architecture_framework.md`

---

## Overview

This is the execution sequence for the framework in Lab Note 001. Each phase
builds on the previous; later phases assume earlier ones are complete. Phases
are ordered by impact-to-effort ratio: the highest-value, lowest-effort moves
come first.

This is a reference sequence, not a status report. It describes the order and
the method. Specific addresses, credentials, and per-device assignments are
chosen at configuration time and recorded in private notes, never in a public
document.

---

## Phase 1: Bridge Mode (Highest Impact, Lowest Effort)

**Achieves:** Removes the ISP's visibility into the internal network. The
ISP gateway becomes a signal converter; the owned router takes over routing.

**Effort:** 15-30 minutes. Cost: $0. Reversible.

The ISP gateway's admin interface is reached at its documented admin address
(commonly printed on the device label), using the default credentials on the
label. Locate the bridge mode setting and enable it. If the interface does not
expose bridge mode, the ISP can enable it on request: it is a standard
supported feature.

After the gateway restarts, the owned router connects to it by ethernet. The
gateway handles the physical ISP link; the router handles everything else. The
network's external IP is now the router's. The ISP still sees traffic at the
infrastructure level: bridge mode removes internal visibility, not ISP-level
visibility.

---

## Phase 2: Open Source Router

**Achieves:** Replaces proprietary router firmware with auditable open source
firmware, enabling VLANs, encrypted DNS, logging, and fine-grained firewall
control.

**Effort:** 2-4 hours. Cost: varies by hardware.

Before buying any router, verify the exact model (not just the brand) against
the OpenWrt supported-devices table at openwrt.org/toh/start. Flashing the
wrong image for a model bricks the device: confirm the hardware revision
printed on the label, not just the product name.

Some devices ship with OpenWrt pre-installed, which is the lowest-friction
path. Otherwise, download the correct factory image for the exact model and
flash it through the stock admin interface. On first access to OpenWrt, set an
admin password immediately.

Jurisdiction is a hardware consideration here too: router origin is part of the
supply chain the framework assumes is unverified. Open source firmware from the
community, rather than vendor firmware, is what collapses that concern.

---

## Phase 3: Network Segmentation (VLANs)

**Achieves:** Isolates trusted workstations from IoT, household, and guest
devices. A compromise on one segment cannot reach another.

**Effort:** 2-3 hours. Follow OpenWrt documentation carefully.

Segment by trust class rather than by device. The structure below is the
instructional shape; the actual VLAN IDs and subnet ranges are chosen at
configuration and recorded in private notes. Non-default ranges add mild
friction against anyone assuming a standard tutorial layout.

| Trust Class | Internet | Access to Other Classes |
|-------------|----------|-------------------------|
| Trusted workstations | Via VPN | None |
| IoT / untrusted | Restricted | None |
| Household / personal | Yes | None |
| Guest | Isolated | None |

In OpenWrt (Network → Interfaces), create an interface per class, assign VLAN
IDs, and configure DHCP to hand out a separate range per interface. In Network
→ Firewall, create a zone per class and set default-deny between zones,
explicitly allowing only each class to the WAN. The trusted class reaches the
internet; no class reaches another.

Write both IPv4 and IPv6 firewall rules. A firewall that isolates on IPv4 while
leaving IPv6 unfiltered has a second door. Where IPv6 is not managed
deliberately, disable it at the WAN until it is.

For wireless, create one SSID per trust class, each bound to its VLAN. Apply
the wireless standard from Layer 3.5 of the framework: WPA3-SAE where supported,
802.11w enabled, and rotate any passphrase carried over from prior equipment.

---

## Phase 4: Encrypted DNS

**Achieves:** The ISP can no longer see domain lookups in plaintext.

**Effort:** 30-60 minutes. Cost: $0.

Install a DoH or DoT client on the router (on OpenWrt, `https-dns-proxy` with
its LuCI app) and point it at a privacy-respecting resolver whose jurisdiction
is chosen deliberately:

| Resolver | Jurisdiction | Notes |
|----------|-------------|-------|
| Quad9 | Switzerland | Blocks malicious domains. Non-profit. |
| Mullvad | Sweden | No-log. Independently audited. |

A US-jurisdiction resolver is a poor fit for the trusted class: it is
compellable under US process. That is a jurisdiction choice, not a quality
judgment.

**Make the encrypted path explicit, not incidental.** Configure the resolver
and transport directly on the device that resolves, rather than relying on a
transparent firewall redirect that a later config change could silently remove.
Verify: with a packet capture on the WAN interface during normal browsing, no
plaintext port 53 traffic should appear. Any visible port 53 is a leak to fix
before proceeding. Confirm the IPv6 path too: router advertisements must not be
handing out ISP DNS servers as a parallel plaintext route.

With a VPN active, an external DNS leak test should show only the VPN
provider's resolvers, never the ISP's.

---

## Phase 5: DNS Sinkhole (Pi-hole)

**Achieves:** Network-wide DNS logging and filtering. Visibility into what
every device queries.

**Effort:** 1-2 hours. Cost: dedicated low-power hardware.

Run the sinkhole on dedicated always-on hardware, not on a workstation that
sleeps. DNS is infrastructure: if it goes down, the network loses resolution.
A low-power single-board computer (a Raspberry Pi draws only a few watts at
idle) is purpose-built for this.

Assign the device a static lease on the router (by MAC, outside the DHCP pool)
and record the address in private notes. Install Pi-hole, setting its upstream
to the same resolver chosen in Phase 4. Then set the router's DHCP DNS option
for each VLAN to the sinkhole's address, so every device resolves through it
and the query is logged before being forwarded upstream over encrypted
transport.

The dashboard shows every domain queried, by which device, and when. Observe
for at least two weeks to establish per-device normal before treating anything
as anomalous. This baseline-and-deviation method is the same one used in SIEM
environments, practiced here on real data.

---

## Phase 6: VPN

**Achieves:** Encrypts traffic leaving the trusted class. The ISP sees a VPN
server IP instead of actual destinations.

**Effort:** 1-2 hours. Cost: a few dollars a month.

Choose a no-log, independently audited provider outside the Five Eyes for
trusted-class use (Mullvad and ProtonVPN are common choices). Avoid free VPNs:
if the product is free, traffic analysis may be the product.

Use WireGuard over OpenVPN: far smaller attack surface (~4,000 lines versus
70,000+), faster handshake, better performance on modest router hardware.
Configure it at the router level so the entire trusted class routes through the
tunnel without per-device setup, and bind the VPN interface to that class only.
Other classes use the ordinary connection.

Verify from a trusted-class device that an external IP-check shows the VPN
server's IP, not the home IP.

---

## Phase 6.5: Device Encryption Hardening

**Achieves:** Verifies and completes encryption at rest on every machine, and
adds SSH key authentication. Verification steps only; no destructive changes.

Confirm full disk encryption on each machine (`lsblk -f` should show
`crypto_LUKS` on the root device). Confirm swap is covered: a swapfile inside
an encrypted root is encrypted automatically; a separate unencrypted swap
partition is not, and can leak decrypted RAM contents to disk. For portable
sensitive data, use an encrypted container (VeraCrypt), verifying the download
checksum before install. For backups, use an encrypting tool (restic or Borg)
and confirm the repository cannot be read without its passphrase: an
unencrypted backup of an encrypted disk defeats the purpose.

On mobile devices, verify default storage encryption is active and set a strong
PIN as primary authentication rather than biometric alone: in many US circuits
a PIN carries Fifth Amendment protection a fingerprint does not. Prefer local
encrypted backups over provider cloud backups for sensitive data.

For remote access, generate an Ed25519 SSH key, install the public key on each
target, confirm key-based login works, then disable password authentication
(`PasswordAuthentication no` in `sshd_config`) and restart SSH. Password SSH is
brute-forceable; key auth removes that surface.

---

## Phase 6.6: Browser Hardening and Identity Compartmentalization

**Achieves:** Reduces browser fingerprint and separates research identity from
personal identity at the account and session layer. Network controls are
bypassed if the browser is left at defaults.

In the research browser (Firefox), set `privacy.resistFingerprinting` to true,
enable tracking protection, block third-party cookies, and disable geolocation
and WebRTC (which can leak a local IP). Install only a minimal extension set:
uBlock Origin and a container extension. Every added extension makes the
fingerprint more unique, not less.

Use container isolation to keep research, professional, and personal contexts
separate within one browser, and never open a personal account in the research
context. Keep research accounts free of shared recovery email, phone, or
payment paths that would link them to a personal identity. Verify the
fingerprint blends into a large population rather than standing out; a unique
fingerprint is a failure state.

---

## Phase 7: Network Security Monitoring

**Achieves:** Full network security monitoring: intrusion detection, traffic
analysis, and behavioral baselining.

**Prerequisites:** Earlier phases stable and documented. This platform is
resource-heavy; add it only once the foundation is solid.

Run the monitoring platform (Security Onion or equivalent) in a VM under a
kernel-native hypervisor (KVM), fed by a mirror of the segment's traffic.
Suricata provides intrusion-detection alerts, Zeek provides traffic analysis and
logging, and Kibana provides investigation and visualization. Initial focus:
unexpected outbound connections from the trusted class, any attempts to cross
isolated segments, DNS that bypasses the sinkhole, regular fixed-interval
"beacon" traffic (a command-and-control pattern), and large transfers at
unusual times.

---

## Data Tier

The sequence produces documentation and data across the three-tier disclosure
model defined in Layer 10 of the framework: public sanitized material, working
reference at limited disclosure, and unsanitized research on air-gapped offline
storage. Speculation and open threads never leave the private tier; only
sanitized findings are promoted to public. Nothing becomes public by accident.

---

*TLP:CLEAR*
*Tags: [zero-trust] [networking] [openwrt] [bridge-mode] [dns]*
