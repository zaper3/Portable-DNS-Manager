# Portable DNS Manager

[![Release](https://img.shields.io/badge/release-v1.0.0-blue)](../../releases/latest)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-informational)
![Linux](https://img.shields.io/badge/Linux-NetworkManager-informational)
![iOS](https://img.shields.io/badge/iOS%20%7C%20iPadOS-DoH%20profiles-informational)
![DNS profiles](https://img.shields.io/badge/DNS%20profiles-43-success)
![Telemetry](https://img.shields.io/badge/telemetry-none-success)
![Catalog](https://img.shields.io/badge/catalog-reviewed%20Aug%202026-lightgrey)
![License](https://img.shields.io/badge/license-source--available-orange)

**Portable, bilingual DNS configuration and network diagnostics utility with Simple/Advanced modes, family filtering guidance, benchmarking, IP/VPN information and local domain blocking.**

**Utilidad DNS portátil y bilingüe con modos Simple/Avanzado, orientación para protección familiar, benchmark, información IP/VPN y bloqueo local de dominios.**

> **Official source / Fuente oficial:** this GitHub repository / este repositorio de GitHub.  
> **DNS catalog reviewed / Catálogo DNS revisado:** August / Agosto 2026.

[**Download latest release / Descargar última versión**](../../releases/latest)

---

## Platform status / Estado por plataforma

| Platform / Plataforma | Edition / Edición | Status / Estado | DNS capabilities / Capacidades DNS | Language / Idioma |
|---|---|---|---|---|
| Windows 10/11 | Portable `.bat` | Stable / Estable | IPv4 + IPv6 + native DoH when supported / DoH nativo cuando está disponible | EN / ES |
| GNU/Linux | Bash `.sh` + NetworkManager | Stable / Estable | IPv4 + IPv6; no local DoH proxy/daemon in v1.0.0 / sin proxy/daemon DoH local | EN / ES |
| iOS / iPadOS | `.mobileconfig` profiles | Stable profiles / Perfiles estables | DNS-over-HTTPS profiles / Perfiles DoH | EN / ES docs |

Windows and Linux provide interactive Simple/Advanced modes. The iOS/iPadOS edition uses Apple DNS configuration profiles because iOS does not execute arbitrary `.bat` or `.sh` files like desktop operating systems. See [`ios/README.md`](ios/README.md).

Windows y Linux ofrecen modos interactivos Simple/Avanzado. La edición iOS/iPadOS utiliza perfiles de configuración DNS de Apple porque iOS no ejecuta archivos `.bat` o `.sh` arbitrarios como los sistemas de escritorio. Consulta [`ios/README.md`](ios/README.md).

---

# English

## What it does

Portable DNS Manager helps users change, compare and diagnose DNS settings without installing a conventional desktop application.

It is designed for two user profiles:

- **Simple Mode:** goal-based choices for everyday users who want to improve normal browsing, security, ad/tracker filtering, family protection or adult-content filtering without learning DNS terminology first.
- **Advanced Mode:** full catalog access, DNS1/DNS2 visibility, provider details, IPv4/IPv6, native DoH on supported Windows versions, benchmarking, interface diagnostics, custom DNS, backup/restore and local domain management.

Core features:

- English or Spanish selected at startup.
- **43 curated DNS profiles** reviewed for the v1.0.0 catalog.
- Goal/category filters: general use, security, advertising/tracking, family protection, adult-content filtering and European providers.
- Family DNS comparison visible from the main experience.
- DNS provider benchmark using real resolution queries where supported.
- Current DNS, interface and network diagnostics.
- Public IP, approximate region and VPN/tunnel indicators.
- Custom DNS configuration.
- Previous DNS backup/restore kept separate from Automatic/DHCP reset.
- Local website/domain blocker using a managed section of the system `hosts` file.
- No telemetry, accounts, analytics or project-operated backend.

A lower benchmark time does **not** automatically mean better privacy, security or filtering. Provider policies are different and should be selected according to the intended use.

## Simple Mode

Simple Mode starts from **what the user wants to achieve**, rather than from DNS-provider names.

| Goal | Typical use |
|---|---|
| General use | Stable DNS without category filtering |
| More security | Malware, phishing and malicious-domain filtering |
| Less ads & tracking | DNS profiles focused on advertising/tracking domains |
| Family protection | Child-oriented filtering profiles and comparison |
| Block adult content | Adult-content filtering choices |
| Choose a DNS | Browse the complete catalog manually |

The family-protection comparison is intentionally visible from the main menus so a non-technical user can understand the differences before selecting a provider.

## Advanced Mode

Advanced Mode adds:

- Complete provider catalog with **DNS1 / DNS2 shown directly**.
- Detailed profile information, IPv6 and DoH endpoints.
- Provider/category filters.
- DNS benchmark and current-DNS test.
- Full network/interface information.
- DNS cache flush.
- Custom DNS and NextDNS configuration flows.
- Restore previous DNS vs reset to Automatic/DHCP.
- Local domain management and `hosts` backup.

See [`PROVIDERS.md`](PROVIDERS.md) for the full catalog.

## Windows

Download the Windows ZIP or standalone `.bat` from Releases and run it directly.

Repository source: [`windows/Portable_DNS_Manager.bat`](windows/Portable_DNS_Manager.bat)

The Windows edition:

- uses Windows PowerShell and native `DnsClient` cmdlets;
- detects active interfaces using interface indexes instead of assuming names such as `Wi-Fi` or `Ethernet`;
- supports IPv4 and IPv6;
- uses native Windows DNS-over-HTTPS configuration where supported;
- requests elevation before network/`hosts` changes;
- stores a previous-DNS backup before supported modifications.

## GNU/Linux

Download the Linux package from Releases or use [`linux/portable-dns-manager.sh`](linux/portable-dns-manager.sh).

```bash
chmod +x portable-dns-manager.sh
./portable-dns-manager.sh
```

The Linux edition targets systems using **NetworkManager / `nmcli`** for DNS-changing functions. Diagnostics remain available even when NetworkManager is not present.

Version 1.0.0 deliberately does **not** install a local DoH proxy, background daemon or resident service. Encrypted-only profiles that require such infrastructure are therefore not applied as plain DNS.

## iOS / iPadOS

The Apple edition contains unsigned `.mobileconfig` profiles for catalog entries that publish DNS-over-HTTPS endpoints.

These are configuration profiles, not executable scripts. Review a profile before installation and, when practical, verify its SHA-256 checksum against the official Release.

See [`ios/README.md`](ios/README.md) and [`ios/PROFILE_SHA256.md`](ios/PROFILE_SHA256.md).

## Family protection and local blocking

Family DNS profiles are a useful protection layer, but they are **not a complete or tamper-resistant parental-control system**.

Portable DNS Manager can additionally block individual domains locally through a managed `hosts` section. It validates/normalizes the requested domain, creates a backup and changes only entries owned by Portable DNS Manager.

A local domain block does not guarantee that every subdomain, mobile-app endpoint, VPN or proxy path will be blocked. A future dedicated parental-control/network-guardian project can address those broader requirements separately.

## Privacy and network access

Portable DNS Manager contains **no telemetry**.

Most configuration work is local. External communication happens only when the user explicitly invokes functionality that requires it, for example:

- public IP / approximate region lookup;
- DNS benchmark or DNS-resolution tests;
- opening the official documentation repository.

The public-IP function currently queries `ipwho.is`. IP geolocation and VPN detection are approximate and should not be treated as proof of physical location or identity.

See [`PRIVACY.md`](PRIVACY.md) for details.

## Safety and authenticity

DNS settings can materially affect connectivity. Keep independent backups for critical systems and use **Restore previous DNS** if a new configuration does not behave as expected.

Download official builds only from this repository's Releases and verify the published SHA-256 checksums when practical.

See:

- [`SECURITY.md`](SECURITY.md) — security model.
- [`AUTHENTICITY.md`](AUTHENTICITY.md) — official-source and checksum verification.
- [`FINAL_AUDIT_v1.0.0.txt`](FINAL_AUDIT_v1.0.0.txt) — v1.0.0 release audit summary.

## License

This project is **source-available**, not OSI open source. Personal, educational and internal organizational use is permitted under the conditions in [`LICENSE.md`](LICENSE.md). Public redistribution or modified distributions must comply with the attribution, identity and authenticity conditions defined there.

---

# Español

## Qué hace

Portable DNS Manager permite cambiar, comparar y diagnosticar la configuración DNS sin instalar una aplicación de escritorio convencional.

Está pensado para dos perfiles de usuario:

- **Modo Simple:** opciones por objetivo para usuarios cotidianos que quieren mejorar navegación normal, seguridad, publicidad/rastreo, protección familiar o filtrado de contenido adulto sin tener que aprender primero terminología DNS.
- **Modo Avanzado:** acceso al catálogo completo, DNS1/DNS2 visibles, detalles de proveedores, IPv4/IPv6, DoH nativo en versiones compatibles de Windows, benchmark, diagnóstico de interfaces, DNS personalizado, backup/restore y gestión local de dominios.

Funciones principales:

- Selección de inglés o español al iniciar.
- **43 perfiles DNS revisados** para el catálogo v1.0.0.
- Filtros por objetivo/categoría: uso general, seguridad, publicidad/rastreo, protección familiar, contenido adulto y proveedores europeos.
- Comparativa DNS familiar visible desde la experiencia principal.
- Benchmark de proveedores mediante consultas reales de resolución cuando la plataforma lo permite.
- Diagnóstico del DNS actual, interfaces y red.
- IP pública, región aproximada e indicadores VPN/túnel.
- DNS personalizado.
- Backup/restauración del DNS anterior separado de Automático/DHCP.
- Bloqueo local de sitios/dominios mediante una sección administrada del archivo `hosts`.
- Sin telemetría, cuentas, analítica ni backend operado por el proyecto.

Un menor tiempo en el benchmark **no** significa automáticamente mayor privacidad, seguridad o capacidad de filtrado. Las políticas de cada proveedor son diferentes y deben elegirse según el objetivo.

## Modo Simple

El Modo Simple parte de **qué quiere conseguir el usuario**, no de nombres de proveedores DNS.

| Objetivo | Uso habitual |
|---|---|
| Uso normal | DNS estable sin filtrado por categorías |
| Más seguridad | Bloqueo de malware, phishing y dominios maliciosos |
| Menos publicidad y rastreo | Perfiles orientados a publicidad/rastreadores |
| Protección familiar | Perfiles para menores y comparativa de protección |
| Bloquear contenido adulto | Opciones centradas en contenido adulto |
| Elegir un DNS | Navegar manualmente por el catálogo completo |

La comparativa de protección familiar se mantiene deliberadamente visible desde los menús principales para que un usuario no técnico pueda comprender las diferencias antes de elegir proveedor.

## Modo Avanzado

El Modo Avanzado añade:

- Catálogo completo con **DNS1 / DNS2 visibles directamente**.
- Información detallada del perfil, IPv6 y endpoints DoH.
- Filtros por proveedor/categoría.
- Benchmark y prueba del DNS actual.
- Información completa de interfaces/red.
- Vaciado de caché DNS.
- Flujos de DNS personalizado y NextDNS.
- Restaurar DNS anterior frente a volver a Automático/DHCP.
- Gestión de dominios locales y backup de `hosts`.

Consulta [`PROVIDERS.md`](PROVIDERS.md) para ver el catálogo completo.

## Windows

Descarga el ZIP de Windows o el `.bat` independiente desde Releases y ejecútalo directamente.

Código fuente en el repositorio: [`windows/Portable_DNS_Manager.bat`](windows/Portable_DNS_Manager.bat)

La edición Windows:

- utiliza Windows PowerShell y cmdlets nativos `DnsClient`;
- detecta interfaces activas por índice sin asumir nombres como `Wi-Fi` o `Ethernet`;
- admite IPv4 e IPv6;
- utiliza DNS-over-HTTPS nativo de Windows cuando está disponible;
- solicita elevación antes de modificar red o `hosts`;
- guarda una copia del DNS anterior antes de cambios soportados.

## GNU/Linux

Descarga el paquete Linux desde Releases o utiliza [`linux/portable-dns-manager.sh`](linux/portable-dns-manager.sh).

```bash
chmod +x portable-dns-manager.sh
./portable-dns-manager.sh
```

La edición Linux está orientada a sistemas con **NetworkManager / `nmcli`** para las funciones que modifican DNS. Los diagnósticos continúan disponibles aunque NetworkManager no esté presente.

La versión 1.0.0 deliberadamente **no** instala proxy DoH local, daemon en segundo plano ni servicio residente. Por ello, los perfiles exclusivamente cifrados que requieren esa infraestructura no se aplican como DNS plano.

## iOS / iPadOS

La edición Apple contiene perfiles `.mobileconfig` sin firmar para entradas del catálogo que publican endpoints DNS-over-HTTPS.

Son perfiles de configuración, no scripts ejecutables. Revisa el contenido antes de instalar y, cuando sea práctico, verifica el SHA-256 contra la Release oficial.

Consulta [`ios/README.md`](ios/README.md) y [`ios/PROFILE_SHA256.md`](ios/PROFILE_SHA256.md).

## Protección familiar y bloqueo local

Los perfiles DNS familiares son una capa útil de protección, pero **no constituyen un sistema completo de control parental resistente a manipulación**.

Portable DNS Manager permite complementar esa protección bloqueando dominios concretos mediante una sección administrada de `hosts`. La herramienta valida/normaliza el dominio solicitado, crea una copia y modifica únicamente sus propias entradas.

Un bloqueo local no garantiza bloquear todos los subdominios, endpoints de aplicaciones móviles, VPN o proxies. Un futuro proyecto dedicado de control parental/network guardian puede abordar esos requisitos más amplios por separado.

## Privacidad y acceso a red

Portable DNS Manager **no contiene telemetría**.

La mayor parte de las operaciones de configuración son locales. Solo existe comunicación externa cuando el usuario ejecuta expresamente una función que la necesita, por ejemplo:

- consulta de IP pública / región aproximada;
- benchmark o pruebas de resolución DNS;
- apertura del repositorio oficial de documentación.

La función de IP pública consulta actualmente `ipwho.is`. La geolocalización IP y la detección de VPN son aproximadas y no deben considerarse prueba de ubicación física o identidad.

Consulta [`PRIVACY.md`](PRIVACY.md) para más detalles.

## Seguridad y autenticidad

Los ajustes DNS pueden afectar materialmente a la conectividad. Mantén copias de seguridad independientes en sistemas críticos y utiliza **Restaurar DNS anterior** si una nueva configuración no funciona como esperabas.

Descarga builds oficiales únicamente desde Releases de este repositorio y verifica los checksums SHA-256 publicados cuando sea práctico.

Consulta:

- [`SECURITY.md`](SECURITY.md) — modelo de seguridad.
- [`AUTHENTICITY.md`](AUTHENTICITY.md) — fuente oficial y verificación de checksums.
- [`FINAL_AUDIT_v1.0.0.txt`](FINAL_AUDIT_v1.0.0.txt) — resumen de auditoría de la Release v1.0.0.

## Licencia

Este proyecto es **source-available / código visible**, no open source bajo una licencia OSI. Se permite el uso personal, educativo e interno organizacional bajo las condiciones de [`LICENSE.md`](LICENSE.md). La redistribución pública o versiones modificadas deben cumplir las condiciones de atribución, identidad y autenticidad definidas allí.

---

## Documentation / Documentación

- [`PROVIDERS.md`](PROVIDERS.md) — DNS catalog / catálogo DNS.
- [`SECURITY.md`](SECURITY.md) — security model / modelo de seguridad.
- [`PRIVACY.md`](PRIVACY.md) — privacy and external requests / privacidad y consultas externas.
- [`AUTHENTICITY.md`](AUTHENTICITY.md) — official source and verification / fuente oficial y verificación.
- [`CHANGELOG.md`](CHANGELOG.md) — version history / historial de versiones.
- [`RELEASE_NOTES_v1.0.0.md`](RELEASE_NOTES_v1.0.0.md) — release notes / notas de Release.
- [`LICENSE.md`](LICENSE.md) — license / licencia.

## Versioning / Versionado

The public project starts at **v1.0.0** as a multiplatform release. Semantic Versioning is used for subsequent public versions.

El proyecto público comienza en **v1.0.0** como Release multiplataforma. Las versiones públicas posteriores seguirán Versionado Semántico.

Developed and maintained by / Desarrollado y mantenido por **zaper3**.  
Copyright © 2026 zaper3.
