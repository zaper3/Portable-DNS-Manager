# DNS Provider Catalog / Catálogo de proveedores DNS

> Reviewed / Revisado: **August / Agosto 2026**

This table is informational. Provider addresses and policies can change. Before a future release, the catalog should be revalidated against provider documentation.

Esta tabla es informativa. Las direcciones y políticas de los proveedores pueden cambiar. Antes de una futura Release, el catálogo debe volver a validarse contra la documentación de cada proveedor.

| Profile / Perfil | Category / Categoría | DNS1 / DNS2 (IPv4) | IPv6 | DoH |
|---|---|---|---|---|
| Cloudflare Standard | standard | `1.1.1.1 / 1.0.0.1` | `2606:4700:4700::1111 / 2606:4700:4700::1001` | `https://cloudflare-dns.com/dns-query` |
| Cloudflare Malware Protection | security | `1.1.1.2 / 1.0.0.2` | `2606:4700:4700::1112 / 2606:4700:4700::1002` | `https://security.cloudflare-dns.com/dns-query` |
| Cloudflare Family | family | `1.1.1.3 / 1.0.0.3` | `2606:4700:4700::1113 / 2606:4700:4700::1003` | `https://family.cloudflare-dns.com/dns-query` |
| Google Public DNS | standard | `8.8.8.8 / 8.8.4.4` | `2001:4860:4860::8888 / 2001:4860:4860::8844` | `https://dns.google/dns-query` |
| Cisco OpenDNS / Umbrella | standard | `208.67.222.222 / 208.67.220.220` | `2620:119:35::35 / 2620:119:53::53` | `https://dns.opendns.com/dns-query` |
| OpenDNS FamilyShield | family | `208.67.222.123 / 208.67.220.123` | `2620:119:35::123 / 2620:119:53::123` | `https://familyshield.opendns.com/dns-query` |
| Quad9 Secure | security | `9.9.9.9 / 149.112.112.112` | `2620:fe::fe / 2620:fe::9` | `https://dns.quad9.net/dns-query` |
| Quad9 Secure + ECS | security | `9.9.9.11 / 149.112.112.11` | `2620:fe::11 / 2620:fe::fe:11` | `https://dns11.quad9.net/dns-query` |
| Quad9 Unfiltered | standard | `9.9.9.10 / 149.112.112.10` | `2620:fe::10 / 2620:fe::fe:10` | `https://dns10.quad9.net/dns-query` |
| Quad9 Unfiltered + ECS | standard | `9.9.9.12 / 149.112.112.12` | `2620:fe::12 / 2620:fe::fe:12` | `https://dns12.quad9.net/dns-query` |
| Yandex DNS Basic | standard | `77.88.8.8 / 77.88.8.1` | `2a02:6b8::feed:0ff / 2a02:6b8:0:1::feed:0ff` | `https://common.dot.dns.yandex.net/dns-query` |
| Yandex DNS Safe | security | `77.88.8.88 / 77.88.8.2` | `2a02:6b8::feed:bad / 2a02:6b8:0:1::feed:bad` | `https://safe.dot.dns.yandex.net/dns-query` |
| Yandex DNS Family | family | `77.88.8.7 / 77.88.8.3` | `2a02:6b8::feed:a11 / 2a02:6b8:0:1::feed:a11` | `https://family.dot.dns.yandex.net/dns-query` |
| AdGuard DNS Default | adblock | `94.140.14.14 / 94.140.15.15` | `2a10:50c0::ad1:ff / 2a10:50c0::ad2:ff` | `https://dns.adguard-dns.com/dns-query` |
| AdGuard DNS Unfiltered | standard | `94.140.14.140 / 94.140.14.141` | `2a10:50c0::1:ff / 2a10:50c0::2:ff` | `https://unfiltered.adguard-dns.com/dns-query` |
| AdGuard DNS Family | family | `94.140.14.15 / 94.140.15.16` | `2a10:50c0::bad1:ff / 2a10:50c0::bad2:ff` | `https://family.adguard-dns.com/dns-query` |
| CleanBrowsing Security | security | `185.228.168.9 / 185.228.169.9` | `2a0d:2a00:1::2 / 2a0d:2a00:2::2` | `https://doh.cleanbrowsing.org/doh/security-filter/` |
| CleanBrowsing Adult | adult | `185.228.168.10 / 185.228.169.11` | `2a0d:2a00:1::1 / 2a0d:2a00:2::1` | `https://doh.cleanbrowsing.org/doh/adult-filter/` |
| CleanBrowsing Family | family | `185.228.168.168 / 185.228.169.168` | `2a0d:2a00:1:: / 2a0d:2a00:2::` | `https://doh.cleanbrowsing.org/doh/family-filter/` |
| DNS4EU Protective | security | `86.54.11.1 / 86.54.11.201` | `2a13:1001::86:54:11:1 / 2a13:1001::86:54:11:201` | `https://protective.joindns4.eu/dns-query` |
| DNS4EU Protective + Child | family | `86.54.11.12 / 86.54.11.212` | `2a13:1001::86:54:11:12 / 2a13:1001::86:54:11:212` | `https://child.joindns4.eu/dns-query` |
| DNS4EU Protective + Ads | adblock | `86.54.11.13 / 86.54.11.213` | `2a13:1001::86:54:11:13 / 2a13:1001::86:54:11:213` | `https://noads.joindns4.eu/dns-query` |
| DNS4EU Child + Ads | family | `86.54.11.11 / 86.54.11.211` | `2a13:1001::86:54:11:11 / 2a13:1001::86:54:11:211` | `https://child-noads.joindns4.eu/dns-query` |
| DNS4EU Unfiltered | standard | `86.54.11.100 / 86.54.11.200` | `2a13:1001::86:54:11:100 / 2a13:1001::86:54:11:200` | `https://unfiltered.joindns4.eu/dns-query` |
| Control D Unfiltered | standard | `76.76.2.0 / 76.76.10.0` | `2606:1a40::0 / 2606:1a40:1::0` | `https://freedns.controld.com/p0` |
| Control D Malware | security | `76.76.2.1 / 76.76.10.1` | `2606:1a40::1 / 2606:1a40:1::1` | `https://freedns.controld.com/p1` |
| Control D Ads & Tracking | adblock | `76.76.2.2 / 76.76.10.2` | `2606:1a40::2 / 2606:1a40:1::2` | `https://freedns.controld.com/p2` |
| Control D Social | special | `76.76.2.3 / 76.76.10.3` | `2606:1a40::3 / 2606:1a40:1::3` | `https://freedns.controld.com/p3` |
| Control D Family Friendly | family | `76.76.2.4 / 76.76.10.4` | `2606:1a40::4 / 2606:1a40:1::4` | `https://freedns.controld.com/family` |
| Control D Uncensored | standard | `76.76.2.5 / 76.76.10.5` | `2606:1a40::5 / 2606:1a40:1::5` | `https://freedns.controld.com/uncensored` |
| Vercara UltraDNS Unfiltered | standard | `64.6.64.6 / 64.6.65.6` | `2620:74:1b::1:1 / 2620:74:1c::2:2` | — |
| Vercara UltraDNS Threat Protection | security | `156.154.70.2 / 156.154.71.2` | `2610:a1:1018::2 / 2610:a1:1019::2` | — |
| Vercara UltraDNS Family Secure | family | `156.154.70.3 / 156.154.71.3` | `2610:a1:1018::3 / 2610:a1:1019::3` | — |
| Oracle OCI / Dyn Recursive DNS | standard | `216.146.35.35 / 216.146.36.36` | `—` | — |
| Hurricane Electric Public Recursor | standard | `74.82.42.42` | `2001:470:20::2` | `https://ordns.he.net/dns-query` |
| Comodo Secure DNS | security | `8.26.56.26 / 8.20.247.20` | `—` | — |
| SafeDNS Service Resolvers | special | `195.46.39.39 / 195.46.39.40` | `2001:67c:2778::3939 / 2001:67c:2778::3940` | — |
| Mullvad Encrypted DNS - Unfiltered | encrypted | `194.242.2.2` | `2a07:e340::2` | `https://dns.mullvad.net/dns-query` |
| Mullvad Encrypted DNS - Ads & Trackers | encrypted | `194.242.2.3` | `2a07:e340::3` | `https://adblock.dns.mullvad.net/dns-query` |
| Mullvad Encrypted DNS - Base | encrypted | `194.242.2.4` | `2a07:e340::4` | `https://base.dns.mullvad.net/dns-query` |
| Mullvad Encrypted DNS - Extended | encrypted | `194.242.2.5` | `2a07:e340::5` | `https://extended.dns.mullvad.net/dns-query` |
| Mullvad Encrypted DNS - Family | encrypted | `194.242.2.6` | `2a07:e340::6` | `https://family.dns.mullvad.net/dns-query` |
| Mullvad Encrypted DNS - All | encrypted | `194.242.2.9` | `2a07:e340::9` | `https://all.dns.mullvad.net/dns-query` |

## Categories / Categorías

- `general`: no category filtering / sin filtrado por categorías.
- `security`: security-oriented filtering / filtrado orientado a seguridad.
- `ads`: advertising/tracker filtering / publicidad y rastreadores.
- `family`: child/family-oriented filtering / protección familiar.
- `adult`: adult-content filtering / contenido adulto.
- `encrypted`: encrypted-only profiles where applicable / perfiles solo cifrados cuando corresponda.

## Notes / Notas

- The application may expose one provider under multiple profiles because filtering policies differ.
- IPv4/IPv6 endpoints are not automatically equivalent to an encrypted DoH endpoint.
- Encrypted-only Mullvad profiles are not applied as plain DNS by the Linux v1.0.0 edition.
- NextDNS is offered as a custom configuration flow rather than one universal public DNS pair.

- La aplicación puede mostrar varios perfiles del mismo proveedor porque sus políticas de filtrado son distintas.
- Tener IPv4/IPv6 no significa que esos endpoints equivalgan automáticamente a un endpoint DoH cifrado.
- Los perfiles Mullvad solo cifrados no se aplican como DNS plano en Linux v1.0.0.
- NextDNS se ofrece mediante configuración personalizada, no como un único par DNS público universal.
