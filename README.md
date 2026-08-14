# Portable DNS Manager

**Portable DNS Manager v1.0.0** is a bilingual (English / Español), portable DNS configuration and diagnostics utility for Windows, GNU/Linux and iOS/iPadOS.

> **Official source / Fuente oficial:** `https://github.com/zaper3/Portable-DNS-Manager`  
> **DNS catalog reviewed / Catálogo DNS revisado:** August / Agosto 2026

## English

### What it does

Portable DNS Manager is designed for two kinds of users:

- **Simple Mode:** goal-based choices such as general use, extra security, ad/tracker reduction, family protection, adult-content filtering, public-IP/VPN information and local website blocking.
- **Advanced Mode:** full provider catalog, DNS1/DNS2 visibility, profile details, IPv4/IPv6, DNS-over-HTTPS where supported, provider benchmarking, interface/network diagnostics, custom DNS, backup/restore, cache flushing and local domain management.

The public catalog contains **43 curated DNS profiles** from established providers. A lower benchmark time does **not** mean a provider is automatically better for privacy, filtering or security.

### Platforms

**Windows 10/11**
- One portable `.bat`; no installer.
- Uses Windows PowerShell and native `DnsClient` cmdlets.
- Detects real active network interfaces instead of assuming names such as `Wi-Fi` or `Ethernet`.
- Backs up DNS state before changes and keeps **Restore previous DNS** separate from **Automatic/DHCP**.
- Supports native Windows DoH configuration when available.
- Manages only its own marked section in the Windows `hosts` file for local domain blocking.

**GNU/Linux**
- One portable Bash `.sh`; no installer.
- DNS-changing functions target systems using **NetworkManager / `nmcli`**.
- Diagnostics remain available even when NetworkManager is not present.
- Uses standard DNS endpoints; v1.0.0 deliberately does **not** install a local DoH proxy/daemon.
- Includes backup/restore, benchmark, interface information, public IP/VPN indicators and a managed `/etc/hosts` domain blocker.

**iOS / iPadOS**
- Includes unsigned `.mobileconfig` profiles for the catalog entries that publish a DoH endpoint.
- These are configuration profiles, not executable scripts.
- Review the profile before installation and verify its SHA-256 checksum from the official Release.

### Privacy

There is **no telemetry** and Portable DNS Manager operates locally for configuration work. External requests happen only when the user explicitly runs a feature that requires them, such as:
- public IP / approximate region lookup;
- DNS provider benchmarking or DNS resolution tests;
- opening the documentation repository.

The public-IP feature currently uses `ipwho.is`. Approximate IP location and VPN detection are informational and may be wrong.

### Important limits

- DNS filtering is **not** a complete parental-control system.
- A local `hosts` entry does not guarantee that every subdomain, app endpoint, VPN or proxy path is blocked.
- Browser Secure DNS / DoH, VPN software, enterprise policies and other network software may override system DNS settings.
- Back up critical systems independently before changing network settings.

## Español

### Qué hace

Portable DNS Manager está diseñado para dos tipos de usuario:

- **Modo Simple:** selección por objetivo: uso normal, más seguridad, reducción de publicidad/rastreo, protección familiar, filtrado de contenido adulto, IP pública/VPN y bloqueo local de sitios.
- **Modo Avanzado:** catálogo completo, DNS1/DNS2 visibles, detalles de perfil, IPv4/IPv6, DNS-over-HTTPS cuando la plataforma lo admite, benchmark de proveedores, diagnóstico de interfaces/red, DNS personalizado, backup/restore, caché y gestión local de dominios.

El catálogo público contiene **43 perfiles DNS revisados**. Un menor tiempo en el benchmark **no** significa automáticamente mayor privacidad, seguridad o capacidad de filtrado.

### Plataformas

**Windows 10/11**
- Un único `.bat` portable; sin instalador.
- Usa Windows PowerShell y cmdlets nativos `DnsClient`.
- Detecta interfaces reales activas sin asumir nombres como `Wi-Fi` o `Ethernet`.
- Guarda el estado DNS antes de cambiarlo y separa **Restaurar DNS anterior** de **Automático/DHCP**.
- Admite configuración DoH nativa de Windows cuando está disponible.
- El bloqueador local administra únicamente su sección marcada del archivo `hosts`.

**GNU/Linux**
- Un único Bash `.sh` portable; sin instalador.
- Las funciones que modifican DNS están orientadas a **NetworkManager / `nmcli`**.
- Los diagnósticos siguen disponibles aunque NetworkManager no esté presente.
- Utiliza endpoints DNS estándar; v1.0.0 deliberadamente **no** instala proxies/daemons DoH.
- Incluye backup/restore, benchmark, interfaces, IP pública/VPN y bloqueo administrado mediante `/etc/hosts`.

**iOS / iPadOS**
- Incluye perfiles `.mobileconfig` sin firmar para las entradas del catálogo que publican endpoint DoH.
- Son perfiles de configuración, no scripts ejecutables.
- Revisa el perfil antes de instalarlo y verifica su SHA-256 contra la Release oficial.

### Privacidad

No existe **telemetría**. Las operaciones de configuración son locales. Solo se hacen consultas externas cuando el usuario ejecuta expresamente una función que las necesita, por ejemplo:
- consulta de IP pública / región aproximada;
- benchmark o pruebas de resolución DNS;
- apertura del repositorio de documentación.

La consulta de IP pública utiliza actualmente `ipwho.is`. La geolocalización IP y la detección de VPN son orientativas y pueden equivocarse.

### Límites importantes

- El filtrado DNS **no** sustituye un sistema completo de control parental.
- Una entrada local en `hosts` no garantiza bloquear todos los subdominios, endpoints de aplicaciones, VPN o proxies.
- Secure DNS / DoH del navegador, VPN, políticas empresariales u otro software de red pueden sustituir los DNS del sistema.
- Mantén copias de seguridad independientes en sistemas críticos.

## Quick start / Inicio rápido

### Windows
1. Download `Portable_DNS_Manager.bat` from the official Release.
2. Double-click it.
3. Select English or Español.
4. Approve the Windows UAC prompt.
5. Choose Simple or Advanced Mode.

### Linux
```bash
chmod +x portable-dns-manager.sh
./portable-dns-manager.sh
```

### iOS / iPadOS
See [`ios/README.md`](ios/README.md).

## Documentation

- [`PROVIDERS.md`](PROVIDERS.md) — catalog / catálogo.
- [`SECURITY.md`](SECURITY.md) — security model / modelo de seguridad.
- [`PRIVACY.md`](PRIVACY.md) — external requests and privacy / consultas externas y privacidad.
- [`AUTHENTICITY.md`](AUTHENTICITY.md) — official source and checksum verification / fuente oficial y verificación.
- [`CHANGELOG.md`](CHANGELOG.md) — version history / historial.
- [`RELEASE_NOTES_v1.0.0.md`](RELEASE_NOTES_v1.0.0.md) — release details / detalles de Release.
- [`LICENSE.md`](LICENSE.md) — license / licencia.

## Author / Autor

Copyright © 2026 **zaper3**. See `LICENSE.md` and `AUTHENTICITY.md`.
