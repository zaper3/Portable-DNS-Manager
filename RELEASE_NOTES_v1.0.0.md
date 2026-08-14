# Portable DNS Manager v1.0.0

> Official source / Fuente oficial: `https://github.com/zaper3/Portable-DNS-Manager`

First public multiplatform release.  
Primera Release pública multiplataforma.

## English

### Highlights
- **Simple Mode** for people who just want a good DNS for general use, security, fewer ads/trackers, family protection or adult-content filtering.
- **Advanced Mode** with 43 DNS profiles, DNS1/DNS2 visibility, details, filters, benchmark and diagnostics.
- Family-protection comparison visible from the main experience.
- Public IP / approximate region / VPN indicators.
- Local website/domain blocker with safe managed `hosts` entries.
- Previous-DNS restore is separate from Automatic/DHCP reset.
- No telemetry.

### Windows
- Portable `.bat`, no installation.
- Windows PowerShell + native `DnsClient` integration.
- Real interface detection, IPv4/IPv6 and native DoH where supported.
- Elevated runtime is extracted only after UAC approval.

### GNU/Linux
- Portable Bash `.sh`.
- NetworkManager / `nmcli` for DNS changes.
- Diagnostics, benchmark, backup/restore and local domain blocker.
- Does not install a DoH proxy/daemon in v1.0.0.

### iOS / iPadOS
- Unsigned `.mobileconfig` profiles for catalog entries with a published DoH endpoint.
- Review profile contents and verify SHA-256 before installing.

## Español

### Destacados
- **Modo Simple** para quien solo quiere elegir un DNS adecuado para uso normal, seguridad, menos publicidad/rastreo, protección familiar o contenido adulto.
- **Modo Avanzado** con 43 perfiles, DNS1/DNS2 visibles, detalles, filtros, benchmark y diagnósticos.
- Comparativa de protección familiar accesible desde la experiencia principal.
- IP pública / región aproximada / indicadores VPN.
- Bloqueador local de sitios/dominios mediante una sección administrada de `hosts`.
- Restaurar DNS anterior es distinto de volver a Automático/DHCP.
- Sin telemetría.

### Windows
- `.bat` portable, sin instalación.
- Windows PowerShell + integración nativa `DnsClient`.
- Detección real de interfaces, IPv4/IPv6 y DoH nativo cuando está disponible.
- El runtime elevado solo se extrae después de aprobar UAC.

### GNU/Linux
- Bash `.sh` portable.
- NetworkManager / `nmcli` para modificar DNS.
- Diagnósticos, benchmark, backup/restore y bloqueo local.
- v1.0.0 no instala proxy/daemon DoH.

### iOS / iPadOS
- Perfiles `.mobileconfig` sin firmar para entradas con endpoint DoH publicado.
- Revisa el contenido y verifica SHA-256 antes de instalar.
