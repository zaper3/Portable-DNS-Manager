# Portable DNS Manager — iOS / iPadOS v1.0.0

## English

This folder documents the **unsigned Apple configuration profiles (`.mobileconfig`)** distributed in the official v1.0.0 Release for DNS-over-HTTPS providers included in Portable DNS Manager.

Installation:
1. Download **one** `.mobileconfig` profile from the official GitHub Release using Safari or Mail.
2. Open **Settings** and tap **Profile Downloaded**.
3. Review the provider name and profile contents, then tap **Install**.
4. Remove or replace the profile from Settings when you want to change DNS.

Important:
- These profiles are intentionally **unsigned** because the project does not operate an Apple signing/MDM infrastructure.
- Verify the SHA-256 checksum against `PROFILE_SHA256.md` and the Release `SHA256SUMS.txt` whenever practical.
- Manual DNS Settings profiles can apply to Wi-Fi and cellular traffic, subject to iOS/iPadOS behavior and other VPN/DNS software.
- VPNs, enterprise management, or other DNS/VPN profiles can override or conflict with these settings.
- Install only one Portable DNS Manager profile at a time unless you understand Apple DNS payload precedence.
- This project does not collect telemetry.

## Español

Esta carpeta documenta los **perfiles de configuración Apple sin firmar (`.mobileconfig`)** distribuidos en la Release oficial v1.0.0 para proveedores DNS-over-HTTPS incluidos en Portable DNS Manager.

Instalación:
1. Descarga **un** perfil `.mobileconfig` desde la Release oficial de GitHub usando Safari o Mail.
2. Abre **Ajustes** y pulsa **Perfil descargado**.
3. Revisa el nombre del proveedor y el contenido del perfil y pulsa **Instalar**.
4. Elimina o sustituye el perfil desde Ajustes cuando quieras cambiar de DNS.

Importante:
- Los perfiles están **sin firmar** intencionadamente porque el proyecto no opera infraestructura Apple de firma/MDM.
- Cuando sea práctico, verifica el SHA-256 contra `PROFILE_SHA256.md` y `SHA256SUMS.txt` de la Release oficial.
- Los perfiles DNS instalados manualmente pueden aplicarse a Wi‑Fi y datos móviles, sujetos al comportamiento de iOS/iPadOS y a otras apps VPN/DNS.
- VPN, gestión empresarial u otros perfiles DNS/VPN pueden sustituir o interferir con estos ajustes.
- Instala un solo perfil de Portable DNS Manager a la vez salvo que conozcas la precedencia de cargas DNS de Apple.
- Este proyecto no recopila telemetría.
