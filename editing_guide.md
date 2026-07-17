# Editing Guide
## Documentation Standards for This Repository

**Date:** July 2026
**Status:** Living Document
**TLP:** CLEAR

---

## About the TLP Marking

Documents in this repository are marked TLP:CLEAR under the Traffic Light
Protocol (TLP 2.0, FIRST.org), the information sharing standard used across
the threat intelligence community. TLP:CLEAR means the content carries no
disclosure restriction. Everything here is written and sanitized for public
release.

---

## Repository Structure

```
cti-lab-notes/
├── README.md              Orientation and a short "start here" list.
├── editing_guide.md       This document.
├── lab-notes/             The build, numbered by decade block.
├── ctf/                   CTF and Search Party writeups, date-named.
├── threat-intel/          External threat analysis, date-named.
├── scripts/               Supporting scripts, grouped by purpose.
├── templates/             Reusable note templates.
└── assets/                Sanitized images: diagrams, screenshots.
```

Lab notes analyze internal telemetry and the build itself. The threat-intel
folder analyzes the external landscape. That boundary is deliberate.

---

## File Naming

**Lab notes:** `0##_descriptive_title.md`
Three-digit decade-block numbering. The first two digits encode the
architecture layer:

| Block | Layer |
|-------|-------|
| 00x | Foundation |
| 01x | Network |
| 02x | Endpoints |
| 03x | Virtualization and SOC lab |
| 04x | Analysis artifacts |
| 05x | Local AI |
| 06x | Salvage, firmware, and mobile |

New notes slot into their block without renumbering neighbors. Dotted
sub-numbers (`0##.1`) are overflow within a topic. Committed notes are never
renumbered: renaming committed files breaks history links.

**CTF writeups:** `YYYY-MM_event_challenge.md`
Episodic work, date-named, no sequence numbers. Lives in `ctf/`.

**Threat intel reports:** `YYYY-MM-DD_report_title.md`
External threat analysis, date-named. Lives in `threat-intel/`.

Files are named with their `.md` extension before content is added. GitHub
will not render markdown preview without the extension.

---

## Style Rules

**M-dash rule.** M-dashes are not used in this portfolio. Every m-dash is
replaced with one of two options.

Option 1, colon: when the second part explains or follows directly from the
first.
Right: "Bridge mode removes the ISP's visibility: your router takes over."

Option 2, new sentence: when a colon does not read naturally.
Right: "Do not skip this. It is not optional."

When in doubt, new sentence.

**Trailing spaces.** Markdown line breaks inside a block require two trailing
spaces after each line. Mobile editors strip trailing spaces on save; blank
lines between fields are the fallback.

**Tables.** Tables are for short content only: index lists, brief reference
data, short comparisons. Anything needing more than one line per cell goes to
prose.

**Tags.** All lab notes end with a tags line:

*Tags: [tag-one] [tag-two] [tag-three]*

Common tags: [os-install] [linux] [kali] [osint] [ctf] [vm-setup]
[networking] [openwrt] [pihole] [dns] [zero-trust] [threat-intel] [opsec]
[hardware] [airgap]

**Status definitions.** Used consistently across all notes and the README
index:

| Status | Meaning |
|--------|---------|
| Complete | Work finished. No open questions remain. |
| In Progress | Work started. Findings still being added. |
| Pending | Not started. Waiting on hardware, prerequisites, or sequencing. |
| Stub | File exists with structure only. Content to follow. |

---

## Lab Note Template

The current lab note template lives in `templates/lab_note_template.md`. Copy
it to start a new note.

---

## README Standard

Every README in this repository ends with:

*cualli tonalli*

---

## What This Repository Never Contains

Content is sanitized before publication. Process publishes. Data does not.

Never published here:

- Credentials, API keys, tokens, password patterns
- Internal IP addresses, MAC addresses, hostnames, or network topology
  specifics
- Real names, addresses, or identifying information from casework
- Anything that could identify a missing person or their family
- Author-identifying detail
- Hardware serial numbers or purchase records

Always published:

- Methodology: how the problem was approached
- Tools, queries, and sanitized results
- Dead ends and how they were recognized
- Lessons learned and what would be done differently

---

*TLP:CLEAR*
*Tags: [meta] [reference] [editing] [opsec]*
