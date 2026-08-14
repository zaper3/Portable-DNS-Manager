#!/usr/bin/env python3
"""Generate deterministic iOS/iPadOS DNS-over-HTTPS configuration profiles.

Source of truth: ../PROVIDERS.md
No network access is required.
"""
from __future__ import annotations

import argparse
import hashlib
import plistlib
import re
import uuid
from pathlib import Path

REPO_URL = "https://github.com/zaper3/Portable-DNS-Manager"
EXPECTED_PROFILE_COUNT = 37


def clean_cell(value: str) -> str:
    return value.strip().strip("`").strip()


def parse_addresses(value: str) -> list[str]:
    value = clean_cell(value)
    if not value or value == "—":
        return []
    return [part.strip() for part in value.split(" / ") if part.strip() and part.strip() != "—"]


def slug(value: str) -> str:
    return re.sub(r"[^A-Za-z0-9._-]+", "-", value).strip("-")


def deterministic_uuid(seed: str) -> str:
    return str(uuid.uuid5(uuid.NAMESPACE_URL, f"{REPO_URL}/{seed}")).upper()


def load_profiles(providers_md: Path) -> list[dict[str, object]]:
    profiles: list[dict[str, object]] = []
    for line in providers_md.read_text(encoding="utf-8").splitlines():
        if not line.startswith("| ") or "Profile / Perfil" in line or line.startswith("|---"):
            continue
        parts = [part.strip() for part in line.strip().strip("|").split("|")]
        if len(parts) < 5:
            continue
        name, category, ipv4_raw, ipv6_raw, doh_raw = parts[:5]
        doh = clean_cell(doh_raw)
        if not doh or doh == "—":
            continue
        if not doh.startswith("https://"):
            raise ValueError(f"Invalid DoH URL for {name}: {doh}")
        profiles.append(
            {
                "name": clean_cell(name),
                "category": clean_cell(category),
                "ipv4": parse_addresses(ipv4_raw),
                "ipv6": parse_addresses(ipv6_raw),
                "doh": doh,
            }
        )
    if len(profiles) != EXPECTED_PROFILE_COUNT:
        raise RuntimeError(
            f"Expected {EXPECTED_PROFILE_COUNT} DoH profiles, found {len(profiles)}. "
            "Review PROVIDERS.md before releasing."
        )
    return profiles


def build_profile(profile: dict[str, object]) -> bytes:
    name = str(profile["name"])
    identifier_slug = re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")
    payload_id = f"com.zaper3.portablednsmanager.dns.{identifier_slug}"
    addresses = [*profile["ipv4"], *profile["ipv6"]]

    dns_settings: dict[str, object] = {
        "DNSProtocol": "HTTPS",
        "ServerURL": str(profile["doh"]),
    }
    if addresses:
        dns_settings["ServerAddresses"] = addresses

    inner = {
        "DNSSettings": dns_settings,
        "PayloadDescription": f"Portable DNS Manager: {name} (DNS over HTTPS).",
        "PayloadDisplayName": name,
        "PayloadIdentifier": payload_id + ".settings",
        "PayloadType": "com.apple.dnsSettings.managed",
        "PayloadUUID": deterministic_uuid("ios-inner-" + name),
        "PayloadVersion": 1,
    }
    outer = {
        "PayloadContent": [inner],
        "PayloadDescription": (
            f"Portable DNS Manager v1.0.0 — {name}. "
            "Unsigned profile; install only from the official repository/release."
        ),
        "PayloadDisplayName": f"Portable DNS Manager - {name}",
        "PayloadIdentifier": payload_id,
        "PayloadOrganization": "zaper3 / Portable DNS Manager",
        "PayloadRemovalDisallowed": False,
        "PayloadType": "Configuration",
        "PayloadUUID": deterministic_uuid("ios-outer-" + name),
        "PayloadVersion": 1,
    }
    data = plistlib.dumps(outer, fmt=plistlib.FMT_XML, sort_keys=False)

    # Round-trip structural validation before writing any release file.
    parsed = plistlib.loads(data)
    payload = parsed["PayloadContent"][0]
    if payload["PayloadType"] != "com.apple.dnsSettings.managed":
        raise RuntimeError(f"Unexpected payload type for {name}")
    if payload["DNSSettings"]["DNSProtocol"] != "HTTPS":
        raise RuntimeError(f"Unexpected DNS protocol for {name}")
    if payload["DNSSettings"]["ServerURL"] != profile["doh"]:
        raise RuntimeError(f"DoH URL mismatch for {name}")
    return data


def generate(providers_md: Path, output_dir: Path, checksums_md: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    for old in output_dir.glob("*.mobileconfig"):
        old.unlink()

    entries: list[tuple[str, str]] = []
    for profile in load_profiles(providers_md):
        filename = slug(str(profile["name"])) + ".mobileconfig"
        target = output_dir / filename
        data = build_profile(profile)
        target.write_bytes(data)
        entries.append((hashlib.sha256(data).hexdigest(), filename))

    entries.sort(key=lambda item: item[1].lower())
    lines = [
        "# iOS / iPadOS profile checksums",
        "",
        "> Generated reproducibly from `PROVIDERS.md` by `ios/generate_profiles.py`.",
        "> Generado de forma reproducible desde `PROVIDERS.md` mediante `ios/generate_profiles.py`.",
        "",
    ]
    lines.extend(f"`{digest}`  `{filename}`" for digest, filename in entries)
    checksums_md.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Generated and validated {len(entries)} DoH profiles.")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--providers", type=Path, default=Path("PROVIDERS.md"))
    parser.add_argument("--output", type=Path, default=Path("ios/profiles"))
    parser.add_argument("--checksums", type=Path, default=Path("ios/PROFILE_SHA256.md"))
    args = parser.parse_args()
    generate(args.providers, args.output, args.checksums)


if __name__ == "__main__":
    main()
