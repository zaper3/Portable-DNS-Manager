# Security Policy / Política de Seguridad

> Official source / Fuente oficial: `https://github.com/zaper3/Portable-DNS-Manager`

## English

Portable DNS Manager changes security-sensitive operating-system network settings. The design therefore follows these rules:

- Windows requests elevation before extracting the embedded PowerShell engine. The temporary engine is created by the elevated process under `%ProgramData%\PortableDNSManager\Runtime` and removed after execution.
- Windows DNS changes use native `DnsClient` cmdlets and interface indexes.
- A DNS backup is written before supported changes. Restoring the previous configuration is intentionally separate from resetting to DHCP.
- The local domain blocker validates/normalizes the requested hostname, backs up `hosts`, and changes only the block delimited by Portable DNS Manager markers.
- Linux modification actions require `sudo`; DNS changes target NetworkManager connections instead of blindly rewriting `/etc/resolv.conf`.
- iOS/iPadOS `.mobileconfig` profiles are **unsigned**. Users must review them and verify published hashes when practical.
- The project has no auto-update mechanism, background service, telemetry agent or remote command channel.

### Threat model and limits

The tool cannot guarantee protection against an administrator, malware with elevated privileges, VPN/proxy software, browser-specific DoH, enterprise management or deliberate tampering.

Family DNS and local domain blocking are useful protection layers, **not tamper-resistant parental control**.

### Reporting

Do not publish secrets, private IP inventories or personal information in a public issue. Provide a minimal reproducible description of:
- platform/version;
- function used;
- expected vs actual result;
- anonymized error output.

## Español

Portable DNS Manager modifica ajustes sensibles de red del sistema operativo. Por ello:

- En Windows se solicita elevación antes de extraer el motor PowerShell embebido. El motor temporal lo crea ya el proceso elevado en `%ProgramData%\PortableDNSManager\Runtime` y se elimina al terminar.
- Los cambios DNS de Windows usan cmdlets nativos `DnsClient` e índices reales de interfaz.
- Se guarda una copia DNS antes de los cambios soportados. Restaurar la configuración anterior es deliberadamente distinto de volver a DHCP.
- El bloqueador local valida/normaliza el hostname solicitado, crea copia de `hosts` y modifica solo el bloque delimitado por las marcas de Portable DNS Manager.
- En Linux las modificaciones requieren `sudo`; el cambio DNS se aplica a conexiones NetworkManager y no reescribe ciegamente `/etc/resolv.conf`.
- Los perfiles `.mobileconfig` de iOS/iPadOS están **sin firmar**. Deben revisarse y, cuando sea práctico, comprobarse sus hashes publicados.
- El proyecto no incluye auto-update, servicio residente, agente de telemetría ni canal de comandos remoto.

### Modelo de amenazas y límites

La herramienta no puede garantizar protección frente a un administrador, malware elevado, VPN/proxy, DoH propio del navegador, gestión empresarial o manipulación deliberada.

El DNS familiar y el bloqueo local son capas útiles de protección, **no control parental resistente a manipulación**.

### Reporte

No publiques secretos, inventarios privados de IP ni datos personales en un issue público. Incluye plataforma/versión, función utilizada, resultado esperado/real y error anonimizado.
