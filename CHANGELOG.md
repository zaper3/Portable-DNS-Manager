# Changelog

All notable public changes to Portable DNS Manager are documented here.

## [1.0.0] - 2026-08-14

### Added
- First public release.
- English / Español interface.
- Simple Mode and Advanced Mode.
- 43-profile curated DNS catalog reviewed in August 2026.
- DNS1/DNS2 display and profile details.
- Goal/category filters: general, security, ads/tracking, family, adult and European providers.
- Family DNS comparison.
- DNS provider benchmark using real resolution queries where supported.
- Current DNS and network/interface diagnostics.
- Public IP / approximate region / VPN indicators.
- Local domain blocker with managed `hosts` section and backup.
- Previous-DNS restore and separate Automatic/DHCP reset.
- Windows IPv4/IPv6 and native DoH support when available.
- GNU/Linux NetworkManager edition.
- iOS/iPadOS DoH `.mobileconfig` profiles.
- SHA-256 release verification and authenticity documentation.

### Security
- Windows elevates before extracting its embedded PowerShell engine.
- Strict input validation for custom DNS addresses and local domain blocking.
- No telemetry, background service or auto-update channel.
