# Authenticity and Verification / Autenticidad y Verificación

The **only official source** for Portable DNS Manager is:

`https://github.com/zaper3/Portable-DNS-Manager`

La **única fuente oficial** de Portable DNS Manager es:

`https://github.com/zaper3/Portable-DNS-Manager`

## Verify release files / Verificar archivos

Every official Release publishes `SHA256SUMS.txt`.

### Windows PowerShell

```powershell
Get-FileHash .\Portable-DNS-Manager-Windows-v1.0.0.zip -Algorithm SHA256
```

### GNU/Linux

```bash
sha256sum Portable-DNS-Manager-Linux-v1.0.0.tar.gz
```

Compare the resulting digest with `SHA256SUMS.txt` from the same official Release.

Compara el resultado con `SHA256SUMS.txt` de la misma Release oficial.

## Identity / Identidad

- Copies, forks or modified distributions are **not official builds** unless explicitly published from the repository above.
- Do not trust a third-party download merely because it uses the project name, icon, screenshots or version number.
- The iOS/iPadOS profiles in v1.0.0 are intentionally unsigned; checksum verification and source provenance are therefore especially important.

- Las copias, forks o distribuciones modificadas **no son builds oficiales** salvo que se publiquen expresamente desde el repositorio anterior.
- No confíes en una descarga de terceros solo porque use el nombre, icono, capturas o número de versión del proyecto.
- Los perfiles iOS/iPadOS de v1.0.0 están intencionadamente sin firmar; por ello es especialmente importante verificar checksum y procedencia.
