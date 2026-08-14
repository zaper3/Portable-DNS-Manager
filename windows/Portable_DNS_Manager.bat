@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Portable DNS Manager v1.0.0
set "PDM_SELF=%~f0"

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Windows PowerShell is required.
    echo ERROR: Se requiere Windows PowerShell.
    echo.
    pause
    exit /b 1
)

if /i "%~1"=="--pdm-elevated" (
    set "PDM_LANG=%~2"
    if /i not "%PDM_LANG%"=="en" if /i not "%PDM_LANG%"=="es" set "PDM_LANG=en"
    goto prepare_elevated
)

:language
cls
echo ====================================================================
echo                      PORTABLE DNS MANAGER
echo                            v1.0.0
echo ====================================================================
echo.
echo        DNS catalog reviewed: August 2026
echo        Catalogo DNS revisado: Agosto 2026
echo        No telemetry - External diagnostics only on request
echo        Sin telemetria - Diagnosticos externos solo bajo solicitud
echo.
echo                       Language / Idioma
echo.
echo                       [1] English
echo                       [2] Espanol
echo.
echo                       [0] Exit / Salir
echo.
choice /c 120 /n /m "> "
if errorlevel 3 exit /b 0
if errorlevel 2 set "PDM_LANG=es"&goto request_elevation
if errorlevel 1 set "PDM_LANG=en"&goto request_elevation
goto language

:request_elevation
cls
if /i "%PDM_LANG%"=="es" (
    echo Portable DNS Manager necesita permisos de Administrador para cambiar DNS y el archivo hosts.
    echo Windows mostrara el aviso UAC.
) else (
    echo Portable DNS Manager needs Administrator permission to change DNS and the hosts file.
    echo Windows will display a UAC prompt.
)
echo.

set "PDM_ELEV_LANG=%PDM_LANG%"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$bat=$env:PDM_SELF;$lang=$env:PDM_ELEV_LANG;$cmd='""'+$bat+'"" --pdm-elevated '+$lang;try{$p=Start-Process -FilePath $env:ComSpec -ArgumentList @('/d','/c',$cmd) -Verb RunAs -Wait -PassThru;exit $p.ExitCode}catch{exit 1223}"
set "PDM_CODE=%ERRORLEVEL%"
if "%PDM_CODE%"=="1223" (
    echo.
    echo Administrator permission was not granted. / No se concedieron permisos de Administrador.
    echo.
    pause
)
exit /b %PDM_CODE%

:prepare_elevated
powershell.exe -NoLogo -NoProfile -Command "$id=[Security.Principal.WindowsIdentity]::GetCurrent();$p=New-Object Security.Principal.WindowsPrincipal($id);if($p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){exit 0}else{exit 1}"
if errorlevel 1 (
    echo ERROR: Administrator permission is required. / Se requieren permisos de Administrador.
    pause
    exit /b 5
)

set "PDM_RUNTIME=%ProgramData%\PortableDNSManager\Runtime"
if not exist "%PDM_RUNTIME%" mkdir "%PDM_RUNTIME%" >nul 2>&1
if not exist "%PDM_RUNTIME%" (
    echo ERROR: Could not create protected runtime directory.
    echo ERROR: No se pudo crear el directorio de ejecucion protegido.
    pause
    exit /b 1
)

icacls "%PDM_RUNTIME%" /inheritance:r /grant:r "*S-1-5-18:(OI)(CI)F" "*S-1-5-32-544:(OI)(CI)F" >nul 2>&1
del /q "%PDM_RUNTIME%\engine_*.ps1" >nul 2>&1

set "PDM_TMP=%PDM_RUNTIME%\engine_%RANDOM%_%RANDOM%.ps1"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$self=$env:PDM_SELF;$marker='###__POWERSHELL_PAYLOAD__###';$lines=[IO.File]::ReadAllLines($self);$idx=[Array]::IndexOf($lines,$marker);if($idx -lt 0){exit 99};[IO.File]::WriteAllLines($env:PDM_TMP,$lines[($idx+1)..($lines.Length-1)],(New-Object Text.UTF8Encoding($true)))"
if errorlevel 1 (
    echo ERROR: Could not extract the embedded engine. / No se pudo extraer el motor interno.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PDM_TMP%" -Lang "%PDM_LANG%" -SourceBat "%PDM_SELF%"
set "PDM_CODE=%ERRORLEVEL%"
del /q "%PDM_TMP%" >nul 2>&1
exit /b %PDM_CODE%

###__POWERSHELL_PAYLOAD__###
# Portable DNS Manager v1.0.0
# Windows 10/11 release. Windows 11 is recommended for native DoH.
# Copyright (c) 2026 zaper3. All rights reserved unless a repository license says otherwise.

param([ValidateSet('en','es')][string]$Lang='en',[string]$SourceBat='')

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
try { cmd /c 'chcp 65001 >nul 2>nul' | Out-Null } catch {}

$script:Version = '1.0.0'
$script:Lang = if ($Lang -eq 'es') { 'es' } else { 'en' }
$script:SelectedInterfaceIndex = $null
$script:DoHPolicy = 'preferred' # preferred | strict | plain
$script:ExternalNoticeAccepted = $false
$script:LastBenchmark = @()
$script:CatalogReviewed = 'August 2026 / Agosto 2026'
$script:RepoUrl = 'https://github.com/zaper3/Portable-DNS-Manager'
$script:RepoPublished = $true
$script:SourceBat = $SourceBat
$script:HostsStart = '# >>> Portable DNS Manager managed block >>>'
$script:HostsEnd = '# <<< Portable DNS Manager managed block <<<'

# ---------------------------------------------------------------------------
# Translations
# ---------------------------------------------------------------------------
$script:Text = @{
    en = @{
        language='Language'; spanish='Español'; english='English'; exit='Exit'; back='Back'; press='Press ENTER to continue';
        welcome='PORTABLE DNS MANAGER';
        currentInterface='Current interface'; currentDns='Current DNS'; dnsMode='DNS mode'; ipv6='IPv6'; encryptedDns='Encrypted DNS';
        automatic='Automatic (DHCP/RA)'; manual='Manual'; active='Active'; inactive='Inactive'; detected='Detected'; notDetected='Not detected'; unavailable='Unavailable';
        chooseMode='How do you want to use Portable DNS Manager?'; simple='SIMPLE MODE'; simpleDesc='Quickly switch to a recommended DNS profile.';
        advanced='ADVANCED MODE'; advancedDesc='Full configuration, testing and diagnostic tools.';
        simpleTitle='SIMPLE MODE'; advancedTitle='ADVANCED MODE';
        chooseGoal='Choose what you want from your DNS:';
        privacy='Fast / general purpose'; security='Security'; adblock='Ad and tracker blocking'; family='Family protection'; google='Google Public DNS'; custom='Custom DNS';
        publicIp='Public IP / region / VPN'; restore='Restore previous DNS'; reset='Reset to Automatic / DHCP';
        providerMenu='DNS PROVIDERS'; config='CONFIGURATION'; diagnostics='DIAGNOSTICS'; networkPrivacy='NETWORK AND PRIVACY'; restoration='RESTORATION'; tools='TOOLS';
        changeProvider='Change DNS provider'; customDns='Configure custom DNS'; selectInterface='Select network interface'; dohPolicy='Encrypted DNS policy (DoH)';
        benchmark='Test DNS providers'; testCurrent='Test current DNS'; showFull='Show full network / DNS configuration'; flush='Flush DNS cache';
        interfaceInfo='Interface information'; connectionDiag='Public IP, region and VPN indicators';
        restorePrevious='Restore previous DNS configuration'; resetAuto='Reset DNS to Automatic / DHCP'; languageChange='Change language';
        select='Select an option'; invalid='Invalid option.'; applying='Applying'; applied='DNS configuration applied successfully.'; failed='Operation failed';
        backupSaved='Previous DNS configuration saved'; verificationOk='DNS resolution verified successfully'; verificationFail='DNS resolution could not be verified';
        provider='Provider'; interface='Interface'; status='Status'; latency='Latency'; result='Result';
        externalTitle='External connection required'; externalNotice='This tool contacts an external IP geolocation service. Portable DNS Manager does not operate its own telemetry server and does not store this response remotely. IP geolocation is approximate.';
        continueQuestion='Continue? [Y/N]'; publicIpTitle='PUBLIC IP / REGION / VPN'; ip='Public IP'; type='Type'; country='Country'; region='Region (approx.)'; city='City (approx.)'; isp='ISP'; asn='ASN'; organization='Organization'; timezone='Time zone';
        vpnIndicators='VPN / tunnel indicators'; vpnLikely='VPN/tunnel likely active'; vpnNo='No local VPN/tunnel indicator detected'; vpnUncertain='This is an estimate, not proof. A VPN can be present without a recognizable adapter.';
        interfacesTitle='NETWORK INTERFACES'; alias='Alias'; description='Description'; localIPv4='Local IPv4'; localIPv6='Local IPv6'; gateway='Gateway'; metric='Metric';
        selectInterfacePrompt='Enter the number of the interface to use'; autoInterface='Use automatically detected primary interface';
        benchmarkTitle='DNS PROVIDER TEST'; benchmarkInfo='Real DNS queries are sent to each resolver. Results depend on your current network and may vary.';
        fastest='Lowest measured time in this test'; applyFastest='Apply the fastest result'; repeat='Repeat test'; noResult='No provider returned a successful test result.';
        dnsTestDomain='Test domain'; currentTest='CURRENT DNS TEST';
        dohPreferred='Preferred: use DoH when available, allow plain-DNS fallback'; dohStrict='Strict: use DoH when available, no plain-DNS fallback'; dohPlain='Plain DNS only: do not enable DoH automatically'; dohUnsupported='Native DoH configuration is not available on this Windows installation.';
        dohEncryptedOnly='This provider is encrypted-DNS-only and requires Windows native DoH support.';
        enterDns='Enter one or more DNS IP addresses separated by spaces or commas'; enterDoh='Optional DoH URL (leave blank for plain DNS)'; invalidIp='One or more DNS addresses are invalid.';
        autoResetDone='DNS reset to automatic configuration.'; restoreDone='Previous DNS configuration restored.'; noBackup='No previous DNS backup was found.';
        cacheDone='DNS cache cleared.'; headerSelected='Selected'; headerAuto='Auto';
        simpleCloudflare='Cloudflare - general purpose, no content filtering'; simpleQuad9='Quad9 Secure - blocks known malicious domains'; simpleAdguard='AdGuard DNS - blocks ads and trackers'; simpleFamily='Cloudflare Family - malware + adult-content filtering';
        warningVpnDns='Note: VPN software or browser Secure DNS/DoH settings can override the operating-system DNS configuration.';
        changeSucceededBut='The configured addresses were written, but the verification lookup failed. You can restore the previous configuration from the menu.';
        confirmApply='Apply this DNS profile? [Y/N]'; yes='Y';
        simplePublic='Check public IP, region and VPN indicators';
        advancedNote='Advanced mode exposes lower-level controls. Changes still use the same backup and verification engine as Simple Mode.';
        configFolder='Backup folder'; backupFile='Latest backup';
        dnsAddresses='DNS addresses'; familyType='Address family'; source='Source';
        windowsVersion='Windows version'; powershellVersion='PowerShell version'; admin='Administrator'; yesWord='Yes'; noWord='No';
    };
    es = @{
        language='Idioma'; spanish='Español'; english='English'; exit='Salir'; back='Volver'; press='Pulsa ENTER para continuar';
        welcome='PORTABLE DNS MANAGER';
        currentInterface='Interfaz actual'; currentDns='DNS actual'; dnsMode='Modo DNS'; ipv6='IPv6'; encryptedDns='DNS cifrado';
        automatic='Automático (DHCP/RA)'; manual='Manual'; active='Activo'; inactive='Inactivo'; detected='Detectado'; notDetected='No detectado'; unavailable='No disponible';
        chooseMode='¿Cómo quieres utilizar Portable DNS Manager?'; simple='MODO SIMPLE'; simpleDesc='Cambiar rápidamente a un perfil DNS recomendado.';
        advanced='MODO AVANZADO'; advancedDesc='Configuración completa, pruebas y herramientas de diagnóstico.';
        simpleTitle='MODO SIMPLE'; advancedTitle='MODO AVANZADO';
        chooseGoal='Elige qué quieres obtener de tu DNS:';
        privacy='Rápido / uso general'; security='Seguridad'; adblock='Bloqueo de anuncios y rastreadores'; family='Protección familiar'; google='Google Public DNS'; custom='DNS personalizado';
        publicIp='IP pública / región / VPN'; restore='Restaurar DNS anterior'; reset='Volver a Automático / DHCP';
        providerMenu='PROVEEDORES DNS'; config='CONFIGURACIÓN'; diagnostics='DIAGNÓSTICO'; networkPrivacy='RED Y PRIVACIDAD'; restoration='RESTAURACIÓN'; tools='HERRAMIENTAS';
        changeProvider='Cambiar proveedor DNS'; customDns='Configurar DNS personalizado'; selectInterface='Seleccionar interfaz de red'; dohPolicy='Política de DNS cifrado (DoH)';
        benchmark='Probar proveedores DNS'; testCurrent='Probar DNS actual'; showFull='Mostrar configuración completa de red / DNS'; flush='Vaciar caché DNS';
        interfaceInfo='Información de interfaces'; connectionDiag='IP pública, región e indicadores de VPN';
        restorePrevious='Restaurar configuración DNS anterior'; resetAuto='Restaurar DNS Automático / DHCP'; languageChange='Cambiar idioma';
        select='Selecciona una opción'; invalid='Opción no válida.'; applying='Aplicando'; applied='Configuración DNS aplicada correctamente.'; failed='La operación ha fallado';
        backupSaved='Configuración DNS anterior guardada'; verificationOk='Resolución DNS verificada correctamente'; verificationFail='No se pudo verificar la resolución DNS';
        provider='Proveedor'; interface='Interfaz'; status='Estado'; latency='Latencia'; result='Resultado';
        externalTitle='Se requiere conexión externa'; externalNotice='Esta herramienta contacta un servicio externo de geolocalización IP. Portable DNS Manager no opera servidores propios de telemetría ni almacena remotamente esta respuesta. La geolocalización IP es aproximada.';
        continueQuestion='¿Continuar? [S/N]'; publicIpTitle='IP PÚBLICA / REGIÓN / VPN'; ip='IP pública'; type='Tipo'; country='País'; region='Región (aprox.)'; city='Ciudad (aprox.)'; isp='ISP'; asn='ASN'; organization='Organización'; timezone='Zona horaria';
        vpnIndicators='Indicadores de VPN / túnel'; vpnLikely='VPN/túnel probablemente activo'; vpnNo='No se detectó un indicador local de VPN/túnel'; vpnUncertain='Es una estimación, no una prueba. Puede existir una VPN sin un adaptador reconocible.';
        interfacesTitle='INTERFACES DE RED'; alias='Alias'; description='Descripción'; localIPv4='IPv4 local'; localIPv6='IPv6 local'; gateway='Puerta de enlace'; metric='Métrica';
        selectInterfacePrompt='Introduce el número de la interfaz que deseas utilizar'; autoInterface='Usar interfaz principal detectada automáticamente';
        benchmarkTitle='PRUEBA DE PROVEEDORES DNS'; benchmarkInfo='Se envían consultas DNS reales a cada resolvedor. Los resultados dependen de tu red actual y pueden variar.';
        fastest='Menor tiempo medido en esta prueba'; applyFastest='Aplicar el resultado más rápido'; repeat='Repetir prueba'; noResult='Ningún proveedor devolvió una prueba correcta.';
        dnsTestDomain='Dominio de prueba'; currentTest='PRUEBA DEL DNS ACTUAL';
        dohPreferred='Preferido: usar DoH cuando esté disponible y permitir fallback a DNS normal'; dohStrict='Estricto: usar DoH cuando esté disponible y no permitir fallback a DNS normal'; dohPlain='Solo DNS normal: no activar DoH automáticamente'; dohUnsupported='La configuración DoH nativa no está disponible en esta instalación de Windows.';
        dohEncryptedOnly='Este proveedor solo admite DNS cifrado y requiere soporte DoH nativo de Windows.';
        enterDns='Introduce una o más IP DNS separadas por espacios o comas'; enterDoh='URL DoH opcional (déjala vacía para DNS normal)'; invalidIp='Una o más direcciones DNS no son válidas.';
        autoResetDone='DNS restaurado a configuración automática.'; restoreDone='Configuración DNS anterior restaurada.'; noBackup='No se encontró una copia anterior de la configuración DNS.';
        cacheDone='Caché DNS vaciada.'; headerSelected='Seleccionada'; headerAuto='Auto';
        simpleCloudflare='Cloudflare - uso general, sin filtrado de contenido'; simpleQuad9='Quad9 Secure - bloquea dominios maliciosos conocidos'; simpleAdguard='AdGuard DNS - bloquea anuncios y rastreadores'; simpleFamily='Cloudflare Family - malware + contenido adulto';
        warningVpnDns='Nota: una VPN o el DNS seguro/DoH del navegador puede sustituir la configuración DNS del sistema operativo.';
        changeSucceededBut='Las direcciones se configuraron, pero falló la comprobación de resolución. Puedes restaurar la configuración anterior desde el menú.';
        confirmApply='¿Aplicar este perfil DNS? [S/N]'; yes='S';
        simplePublic='Consultar IP pública, región e indicadores de VPN';
        advancedNote='El modo avanzado expone controles de bajo nivel. Los cambios siguen usando el mismo motor de copia y verificación que el Modo Simple.';
        configFolder='Carpeta de copias'; backupFile='Última copia';
        dnsAddresses='Direcciones DNS'; familyType='Familia'; source='Origen';
        windowsVersion='Versión de Windows'; powershellVersion='Versión de PowerShell'; admin='Administrador'; yesWord='Sí'; noWord='No';
    }
}

function T([string]$Key) {
    $value = $script:Text[$script:Lang][$Key]
    if ($null -eq $value) { return $Key }
    return $value
}

function L([string]$En,[string]$Es) { if($script:Lang -eq 'es'){return $Es}else{return $En} }

function Pause-PDM { Write-Host ''; [void](Read-Host (T 'press')) }
function Clear-PDM { Clear-Host }
function Write-Line { Write-Host ('=' * 68) }
function Write-SubLine { Write-Host ('-' * 68) }


function Get-SafeProperty([object]$Object,[string]$Name,$Default=$null) {
    if ($null -eq $Object) { return $Default }
    try {
        $p = $Object.PSObject.Properties[$Name]
        if ($null -ne $p) { return $p.Value }
    } catch {}
    return $Default
}

function Join-OrDash($Value,[string]$Separator=', ') {
    $items = @($Value | Where-Object { $null -ne $_ -and -not [string]::IsNullOrWhiteSpace([string]$_) })
    if (@($items).Count -eq 0) { return '-' }
    return (($items | ForEach-Object { [string]$_ }) -join $Separator)
}

function Get-IPv4PairText([object]$Provider) {
    $v4 = @($Provider.IPv4)
    if (@($v4).Count -eq 0) { return (L 'DoH only / no plain IPv4' 'Solo DoH / sin IPv4 convencional') }
    $first = [string]$v4[0]
    $second = if (@($v4).Count -gt 1) { [string]$v4[1] } else { '-' }
    return ($first + ' / ' + $second)
}

# ---------------------------------------------------------------------------
# Provider catalog - reviewed August 2026 from current provider documentation.
# The catalog is intentionally curated: obsolete/unsupported legacy entries are
# not kept merely because older DNS switchers listed them.
# ---------------------------------------------------------------------------
function New-PdmProvider {
    param([string]$Id,[string]$Provider,[string]$Name,[string]$Category,[string[]]$IPv4,[string[]]$IPv6,[string]$DoH,[bool]$EncryptedOnly,[bool]$Benchmark,[string[]]$Tags,[string[]]$Features,[string]$SummaryEn,[string]$SummaryEs)
    return [pscustomobject]@{Id=$Id;Provider=$Provider;Name=$Name;Category=$Category;IPv4=@($IPv4);IPv6=@($IPv6);DoH=$DoH;EncryptedOnly=$EncryptedOnly;Benchmark=$Benchmark;Tags=@($Tags);Features=@($Features);SummaryEn=$SummaryEn;SummaryEs=$SummaryEs}
}
$script:Providers = [ordered]@{}
function Add-PdmProvider([object]$P) { $script:Providers[$P.Id] = $P }

Add-PdmProvider (New-PdmProvider 'cloudflare' 'Cloudflare' 'Cloudflare Standard' 'standard' @('1.1.1.1','1.0.0.1') @('2606:4700:4700::1111','2606:4700:4700::1001') 'https://cloudflare-dns.com/dns-query' $false $true @('general','privacy','encrypted') @() 'General-purpose resolver with no content filtering.' 'Resolvedor de uso general sin filtrado de contenido.')
Add-PdmProvider (New-PdmProvider 'cloudflare_malware' 'Cloudflare' 'Cloudflare Malware Protection' 'security' @('1.1.1.2','1.0.0.2') @('2606:4700:4700::1112','2606:4700:4700::1002') 'https://security.cloudflare-dns.com/dns-query' $false $true @('security','encrypted') @('malware','phishing') 'Blocks known malware and phishing domains.' 'Bloquea dominios conocidos de malware y phishing.')
Add-PdmProvider (New-PdmProvider 'cloudflare_family' 'Cloudflare' 'Cloudflare Family' 'family' @('1.1.1.3','1.0.0.3') @('2606:4700:4700::1113','2606:4700:4700::1003') 'https://family.cloudflare-dns.com/dns-query' $false $true @('family','adult','security','encrypted') @('malware','phishing','adult') 'Blocks malware, phishing and adult content.' 'Bloquea malware, phishing y contenido adulto.')
Add-PdmProvider (New-PdmProvider 'google' 'Google' 'Google Public DNS' 'standard' @('8.8.8.8','8.8.4.4') @('2001:4860:4860::8888','2001:4860:4860::8844') 'https://dns.google/dns-query' $false $true @('general','encrypted') @() 'Global public DNS resolver with no category filtering.' 'Resolvedor DNS público global sin filtrado por categorías.')
Add-PdmProvider (New-PdmProvider 'opendns' 'Cisco' 'Cisco OpenDNS / Umbrella' 'standard' @('208.67.222.222','208.67.220.220') @('2620:119:35::35','2620:119:53::53') 'https://dns.opendns.com/dns-query' $false $true @('general','security','encrypted') @() 'Public Cisco OpenDNS/Umbrella resolver; custom policy features require an account.' 'Resolvedor público Cisco OpenDNS/Umbrella; las políticas personalizadas requieren cuenta.')
Add-PdmProvider (New-PdmProvider 'opendns_family' 'Cisco' 'OpenDNS FamilyShield' 'family' @('208.67.222.123','208.67.220.123') @('2620:119:35::123','2620:119:53::123') 'https://familyshield.opendns.com/dns-query' $false $true @('family','adult','encrypted') @('adult') 'FamilyShield preset for adult-content blocking.' 'Perfil FamilyShield para bloquear contenido adulto.')
Add-PdmProvider (New-PdmProvider 'quad9_secure' 'Quad9' 'Quad9 Secure' 'security' @('9.9.9.9','149.112.112.112') @('2620:fe::fe','2620:fe::9') 'https://dns.quad9.net/dns-query' $false $true @('security','privacy','encrypted') @('malware','phishing') 'Privacy-oriented resolver with threat blocking.' 'Resolvedor orientado a privacidad con bloqueo de amenazas.')
Add-PdmProvider (New-PdmProvider 'quad9_secure_ecs' 'Quad9' 'Quad9 Secure + ECS' 'security' @('9.9.9.11','149.112.112.11') @('2620:fe::11','2620:fe::fe:11') 'https://dns11.quad9.net/dns-query' $false $true @('security','encrypted','ecs') @('malware','phishing') 'Threat blocking with ECS for CDN routing in networks where it helps.' 'Bloqueo de amenazas con ECS para mejorar el enrutamiento CDN donde resulte útil.')
Add-PdmProvider (New-PdmProvider 'quad9_unfiltered' 'Quad9' 'Quad9 Unfiltered' 'standard' @('9.9.9.10','149.112.112.10') @('2620:fe::10','2620:fe::fe:10') 'https://dns10.quad9.net/dns-query' $false $true @('general','privacy','encrypted') @() 'Privacy-oriented Quad9 resolution without threat blocking.' 'Resolución Quad9 orientada a privacidad sin bloqueo de amenazas.')
Add-PdmProvider (New-PdmProvider 'quad9_unfiltered_ecs' 'Quad9' 'Quad9 Unfiltered + ECS' 'standard' @('9.9.9.12','149.112.112.12') @('2620:fe::12','2620:fe::fe:12') 'https://dns12.quad9.net/dns-query' $false $true @('general','encrypted','ecs') @() 'Unfiltered Quad9 resolution with ECS.' 'Resolución Quad9 sin filtrado con ECS.')
Add-PdmProvider (New-PdmProvider 'yandex_basic' 'Yandex' 'Yandex DNS Basic' 'standard' @('77.88.8.8','77.88.8.1') @('2a02:6b8::feed:0ff','2a02:6b8:0:1::feed:0ff') 'https://common.dot.dns.yandex.net/dns-query' $false $true @('general','encrypted') @() 'Yandex general-purpose DNS mode.' 'Modo DNS de uso general de Yandex.')
Add-PdmProvider (New-PdmProvider 'yandex_safe' 'Yandex' 'Yandex DNS Safe' 'security' @('77.88.8.88','77.88.8.2') @('2a02:6b8::feed:bad','2a02:6b8:0:1::feed:bad') 'https://safe.dot.dns.yandex.net/dns-query' $false $true @('security','encrypted') @('malware','phishing','botnet') 'Blocks dangerous and fraudulent websites and botnet infrastructure.' 'Bloquea sitios peligrosos y fraudulentos e infraestructura de botnets.')
Add-PdmProvider (New-PdmProvider 'yandex_family' 'Yandex' 'Yandex DNS Family' 'family' @('77.88.8.7','77.88.8.3') @('2a02:6b8::feed:a11','2a02:6b8:0:1::feed:a11') 'https://family.dot.dns.yandex.net/dns-query' $false $true @('family','adult','security','encrypted') @('malware','phishing','botnet','adult','family-search') 'Adds adult-content filtering and Yandex family search to security protections.' 'Añade filtrado de contenido adulto y búsqueda familiar de Yandex a las protecciones de seguridad.')
Add-PdmProvider (New-PdmProvider 'adguard_default' 'AdGuard' 'AdGuard DNS Default' 'adblock' @('94.140.14.14','94.140.15.15') @('2a10:50c0::ad1:ff','2a10:50c0::ad2:ff') 'https://dns.adguard-dns.com/dns-query' $false $true @('ads','tracking','security','encrypted') @('ads','trackers','malware','phishing') 'Blocks ads and trackers; AdGuard also documents malware and phishing protection.' 'Bloquea anuncios y rastreadores; AdGuard también documenta protección contra malware y phishing.')
Add-PdmProvider (New-PdmProvider 'adguard_unfiltered' 'AdGuard' 'AdGuard DNS Unfiltered' 'standard' @('94.140.14.140','94.140.14.141') @('2a10:50c0::1:ff','2a10:50c0::2:ff') 'https://unfiltered.adguard-dns.com/dns-query' $false $true @('general','encrypted') @() 'AdGuard resolver without content filtering.' 'Resolvedor AdGuard sin filtrado de contenido.')
Add-PdmProvider (New-PdmProvider 'adguard_family' 'AdGuard' 'AdGuard DNS Family' 'family' @('94.140.14.15','94.140.15.16') @('2a10:50c0::bad1:ff','2a10:50c0::bad2:ff') 'https://family.adguard-dns.com/dns-query' $false $true @('family','adult','ads','tracking','security','encrypted') @('ads','trackers','malware','phishing','adult','safe-search') 'Blocks ads, trackers, adult content and enables Safe Search/Safe Mode where possible.' 'Bloquea anuncios, rastreadores y contenido adulto, y activa Búsqueda Segura/Modo Seguro cuando es posible.')
Add-PdmProvider (New-PdmProvider 'clean_security' 'CleanBrowsing' 'CleanBrowsing Security' 'security' @('185.228.168.9','185.228.169.9') @('2a0d:2a00:1::2','2a0d:2a00:2::2') 'https://doh.cleanbrowsing.org/doh/security-filter/' $false $true @('security','encrypted') @('malware','phishing','spam') 'Blocks phishing, spam, malware and malicious domains; does not block adult content.' 'Bloquea phishing, spam, malware y dominios maliciosos; no bloquea contenido adulto.')
Add-PdmProvider (New-PdmProvider 'clean_adult' 'CleanBrowsing' 'CleanBrowsing Adult' 'adult' @('185.228.168.10','185.228.169.11') @('2a0d:2a00:1::1','2a0d:2a00:2::1') 'https://doh.cleanbrowsing.org/doh/adult-filter/' $false $true @('adult','family','security','encrypted') @('malware','phishing','adult','safe-search') 'Blocks adult content plus malware/phishing and enables SafeSearch for Google/Bing.' 'Bloquea contenido adulto además de malware/phishing y activa SafeSearch en Google/Bing.')
Add-PdmProvider (New-PdmProvider 'clean_family' 'CleanBrowsing' 'CleanBrowsing Family' 'family' @('185.228.168.168','185.228.169.168') @('2a0d:2a00:1::','2a0d:2a00:2::') 'https://doh.cleanbrowsing.org/doh/family-filter/' $false $true @('family','adult','security','encrypted','strict') @('malware','phishing','adult','safe-search','proxy-vpn','mixed-content') 'Strict family filter: adult content, mixed-content sites and known proxy/VPN bypass domains, plus SafeSearch.' 'Filtro familiar estricto: contenido adulto, sitios de contenido mixto y dominios proxy/VPN usados para evadir filtros, además de SafeSearch.')
Add-PdmProvider (New-PdmProvider 'dns4eu_protective' 'DNS4EU' 'DNS4EU Protective' 'security' @('86.54.11.1','86.54.11.201') @('2a13:1001::86:54:11:1','2a13:1001::86:54:11:201') 'https://protective.joindns4.eu/dns-query' $false $true @('security','europe','encrypted') @('malware','phishing') 'European protective resolver against fraudulent or malicious websites.' 'Resolvedor protector europeo frente a sitios fraudulentos o maliciosos.')
Add-PdmProvider (New-PdmProvider 'dns4eu_child' 'DNS4EU' 'DNS4EU Protective + Child' 'family' @('86.54.11.12','86.54.11.212') @('2a13:1001::86:54:11:12','2a13:1001::86:54:11:212') 'https://child.joindns4.eu/dns-query' $false $true @('family','adult','security','europe','encrypted') @('malware','phishing','adult','violence','drugs') 'Protective DNS plus child-inappropriate content such as explicit content, violence or drugs.' 'DNS protector más contenido inapropiado para menores como contenido explícito, violencia o drogas.')
Add-PdmProvider (New-PdmProvider 'dns4eu_ads' 'DNS4EU' 'DNS4EU Protective + Ads' 'adblock' @('86.54.11.13','86.54.11.213') @('2a13:1001::86:54:11:13','2a13:1001::86:54:11:213') 'https://noads.joindns4.eu/dns-query' $false $true @('ads','security','europe','encrypted') @('malware','phishing','ads') 'Protective resolver plus website and in-app ad blocking.' 'Resolvedor protector más bloqueo de anuncios en webs y aplicaciones.')
Add-PdmProvider (New-PdmProvider 'dns4eu_child_ads' 'DNS4EU' 'DNS4EU Child + Ads' 'family' @('86.54.11.11','86.54.11.211') @('2a13:1001::86:54:11:11','2a13:1001::86:54:11:211') 'https://child-noads.joindns4.eu/dns-query' $false $true @('family','adult','ads','security','europe','encrypted') @('malware','phishing','adult','violence','drugs','ads') 'Combines protective DNS, child-content filtering and ad blocking.' 'Combina DNS protector, filtrado de contenido infantil y bloqueo de anuncios.')
Add-PdmProvider (New-PdmProvider 'dns4eu_unfiltered' 'DNS4EU' 'DNS4EU Unfiltered' 'standard' @('86.54.11.100','86.54.11.200') @('2a13:1001::86:54:11:100','2a13:1001::86:54:11:200') 'https://unfiltered.joindns4.eu/dns-query' $false $true @('general','privacy','europe','encrypted') @() 'European unfiltered resolver focused on reliable anonymised resolution.' 'Resolvedor europeo sin filtrado orientado a resolución fiable y anonimizada.')
Add-PdmProvider (New-PdmProvider 'controld_unfiltered' 'Control D' 'Control D Unfiltered' 'standard' @('76.76.2.0','76.76.10.0') @('2606:1a40::0','2606:1a40:1::0') 'https://freedns.controld.com/p0' $false $true @('general','encrypted') @() 'Control D free unfiltered community resolver.' 'Resolvedor comunitario gratuito de Control D sin filtrado.')
Add-PdmProvider (New-PdmProvider 'controld_malware' 'Control D' 'Control D Malware' 'security' @('76.76.2.1','76.76.10.1') @('2606:1a40::1','2606:1a40:1::1') 'https://freedns.controld.com/p1' $false $true @('security','encrypted') @('malware') 'Control D free malware-filtering preset.' 'Perfil gratuito de Control D para filtrado de malware.')
Add-PdmProvider (New-PdmProvider 'controld_ads' 'Control D' 'Control D Ads & Tracking' 'adblock' @('76.76.2.2','76.76.10.2') @('2606:1a40::2','2606:1a40:1::2') 'https://freedns.controld.com/p2' $false $true @('ads','tracking','encrypted') @('ads','trackers') 'Control D free ads and tracking preset.' 'Perfil gratuito de Control D para anuncios y rastreo.')
Add-PdmProvider (New-PdmProvider 'controld_social' 'Control D' 'Control D Social' 'special' @('76.76.2.3','76.76.10.3') @('2606:1a40::3','2606:1a40:1::3') 'https://freedns.controld.com/p3' $false $true @('social','encrypted') @('social') 'Control D preset focused on social-network blocking.' 'Perfil de Control D orientado al bloqueo de redes sociales.')
Add-PdmProvider (New-PdmProvider 'controld_family' 'Control D' 'Control D Family Friendly' 'family' @('76.76.2.4','76.76.10.4') @('2606:1a40::4','2606:1a40:1::4') 'https://freedns.controld.com/family' $false $true @('family','encrypted') @('family') 'Control D free family-friendly preset.' 'Perfil familiar gratuito de Control D.')
Add-PdmProvider (New-PdmProvider 'controld_uncensored' 'Control D' 'Control D Uncensored' 'standard' @('76.76.2.5','76.76.10.5') @('2606:1a40::5','2606:1a40:1::5') 'https://freedns.controld.com/uncensored' $false $true @('general','uncensored','encrypted') @() 'Control D free uncensored preset.' 'Perfil gratuito sin censura de Control D.')
Add-PdmProvider (New-PdmProvider 'vercara_unfiltered' 'Vercara' 'Vercara UltraDNS Unfiltered' 'standard' @('64.6.64.6','64.6.65.6') @('2620:74:1b::1:1','2620:74:1c::2:2') $null $false $true @('general') @() 'UltraDNS Public unfiltered resolution.' 'Resolución pública UltraDNS sin filtrado.')
Add-PdmProvider (New-PdmProvider 'vercara_threat' 'Vercara' 'Vercara UltraDNS Threat Protection' 'security' @('156.154.70.2','156.154.71.2') @('2610:a1:1018::2','2610:a1:1019::2') $null $false $true @('security') @('malware','phishing') 'Blocks malicious domains including malware and phishing.' 'Bloquea dominios maliciosos, incluidos malware y phishing.')
Add-PdmProvider (New-PdmProvider 'vercara_family' 'Vercara' 'Vercara UltraDNS Family Secure' 'family' @('156.154.70.3','156.154.71.3') @('2610:a1:1018::3','2610:a1:1019::3') $null $false $true @('family','adult','security') @('malware','phishing','adult','gambling','violence','hate') 'Threat protection plus gambling, pornography, violence and hate/discrimination categories.' 'Protección contra amenazas más categorías de apuestas, pornografía, violencia y odio/discriminación.')
Add-PdmProvider (New-PdmProvider 'oracle_dyn' 'Oracle OCI' 'Oracle OCI / Dyn Recursive DNS' 'standard' @('216.146.35.35','216.146.36.36') @() $null $false $true @('general') @() 'Free validating recursive DNS service provided by Oracle OCI.' 'Servicio DNS recursivo de validación gratuito de Oracle OCI.')
Add-PdmProvider (New-PdmProvider 'hurricane' 'Hurricane Electric' 'Hurricane Electric Public Recursor' 'standard' @('74.82.42.42') @('2001:470:20::2') 'https://ordns.he.net/dns-query' $false $true @('general','encrypted') @() 'Hurricane Electric anycast public recursor.' 'Resolvedor público anycast de Hurricane Electric.')
Add-PdmProvider (New-PdmProvider 'comodo' 'Comodo' 'Comodo Secure DNS' 'security' @('8.26.56.26','8.20.247.20') @() $null $false $true @('security') @('security') 'Comodo public Secure DNS resolver.' 'Resolvedor público Secure DNS de Comodo.')
Add-PdmProvider (New-PdmProvider 'safedns' 'SafeDNS' 'SafeDNS Service Resolvers' 'special' @('195.46.39.39','195.46.39.40') @('2001:67c:2778::3939','2001:67c:2778::3940') $null $false $true @('account','family','security') @() 'SafeDNS service addresses; filtering policies can depend on account/network registration.' 'Direcciones del servicio SafeDNS; las políticas de filtrado pueden depender del registro de cuenta/red.')
Add-PdmProvider (New-PdmProvider 'mullvad_plain' 'Mullvad' 'Mullvad Encrypted DNS - Unfiltered' 'encrypted' @('194.242.2.2') @('2a07:e340::2') 'https://dns.mullvad.net/dns-query' $true $false @('general','privacy','encrypted-only') @() 'Encrypted DNS only; no content blocking.' 'Solo DNS cifrado; sin bloqueo de contenido.')
Add-PdmProvider (New-PdmProvider 'mullvad_adblock' 'Mullvad' 'Mullvad Encrypted DNS - Ads & Trackers' 'encrypted' @('194.242.2.3') @('2a07:e340::3') 'https://adblock.dns.mullvad.net/dns-query' $true $false @('ads','tracking','encrypted-only') @('ads','trackers') 'Encrypted-only profile blocking ads and trackers.' 'Perfil solo cifrado que bloquea anuncios y rastreadores.')
Add-PdmProvider (New-PdmProvider 'mullvad_base' 'Mullvad' 'Mullvad Encrypted DNS - Base' 'encrypted' @('194.242.2.4') @('2a07:e340::4') 'https://base.dns.mullvad.net/dns-query' $true $false @('ads','tracking','security','encrypted-only') @('ads','trackers','malware') 'Encrypted-only profile blocking ads, trackers and malware.' 'Perfil solo cifrado que bloquea anuncios, rastreadores y malware.')
Add-PdmProvider (New-PdmProvider 'mullvad_extended' 'Mullvad' 'Mullvad Encrypted DNS - Extended' 'encrypted' @('194.242.2.5') @('2a07:e340::5') 'https://extended.dns.mullvad.net/dns-query' $true $false @('ads','tracking','security','social','encrypted-only') @('ads','trackers','malware','social') 'Base filtering plus social-media blocking.' 'Filtrado Base más bloqueo de redes sociales.')
Add-PdmProvider (New-PdmProvider 'mullvad_family' 'Mullvad' 'Mullvad Encrypted DNS - Family' 'encrypted' @('194.242.2.6') @('2a07:e340::6') 'https://family.dns.mullvad.net/dns-query' $true $false @('family','adult','ads','security','encrypted-only') @('ads','trackers','malware','adult','gambling') 'Encrypted-only family profile: ads, trackers, malware, adult content and gambling.' 'Perfil familiar solo cifrado: anuncios, rastreadores, malware, contenido adulto y apuestas.')
Add-PdmProvider (New-PdmProvider 'mullvad_all' 'Mullvad' 'Mullvad Encrypted DNS - All' 'encrypted' @('194.242.2.9') @('2a07:e340::9') 'https://all.dns.mullvad.net/dns-query' $true $false @('family','adult','ads','security','social','encrypted-only') @('ads','trackers','malware','adult','gambling','social') 'Mullvad broadest encrypted-only blocking profile.' 'Perfil solo cifrado con el filtrado más amplio de Mullvad.')

# ---------------------------------------------------------------------------
# Runtime / privilege helpers
# ---------------------------------------------------------------------------
function Test-IsAdministrator {
    try {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($id)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch { return $false }
}

function Ensure-Administrator {
    if (Test-IsAdministrator) { return $true }
    Write-Host ''
    if ($script:Lang -eq 'es') {
        Write-Host 'Se solicitarán permisos de Administrador para modificar la configuración DNS.' -ForegroundColor Yellow
    } else {
        Write-Host 'Administrator permission is required to modify DNS configuration.' -ForegroundColor Yellow
    }
    try {
        $arg = '/c "' + $env:PDM_SELF + '"'
        Start-Process -FilePath $env:ComSpec -ArgumentList $arg -Verb RunAs | Out-Null
        exit 0
    } catch {
        Write-Host ((T 'failed') + ': ' + $_.Exception.Message) -ForegroundColor Red
        Pause-PDM
        return $false
    }
}

function Get-StateFolder {
    $base = $null
    foreach ($candidateSource in @($script:SourceBat,$env:PDM_SELF)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$candidateSource)) {
            try {
                $candidateFull = [IO.Path]::GetFullPath([string]$candidateSource)
                $parent = Split-Path -Parent $candidateFull
                if (-not [string]::IsNullOrWhiteSpace($parent)) { $base = $parent; break }
            } catch {}
        }
    }

    # Elevated processes do not always retain caller-defined environment variables.
    # If the original BAT path is unavailable, use LocalAppData rather than failing.
    if ([string]::IsNullOrWhiteSpace($base)) {
        $fallback = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'PortableDNSManager'
        if (-not (Test-Path -LiteralPath $fallback)) { New-Item -ItemType Directory -Path $fallback -Force | Out-Null }
        return $fallback
    }

    $candidate = Join-Path $base '_PortableDNSManager'
    try {
        if (-not (Test-Path -LiteralPath $candidate)) { New-Item -ItemType Directory -Path $candidate -Force | Out-Null }
        $probe = Join-Path $candidate '.write_test'
        [IO.File]::WriteAllText($probe,'ok')
        Remove-Item -LiteralPath $probe -Force
        return $candidate
    } catch {
        $fallback = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'PortableDNSManager'
        if (-not (Test-Path -LiteralPath $fallback)) { New-Item -ItemType Directory -Path $fallback -Force | Out-Null }
        return $fallback
    }
}

function Get-InterfaceMetric([int]$Index) {
    try {
        $ipif = Get-NetIPInterface -InterfaceIndex $Index -AddressFamily IPv4 -ErrorAction Stop | Select-Object -First 1
        return [int]$ipif.InterfaceMetric
    } catch { return 9999 }
}

function Get-PrimaryInterface {
    try {
        $routes = Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' -ErrorAction Stop |
            Where-Object { $_.State -ne 'Unreachable' } |
            Sort-Object @{Expression={ [int]$_.RouteMetric + (Get-InterfaceMetric $_.InterfaceIndex) }}
        foreach ($route in $routes) {
            $a = Get-NetAdapter -InterfaceIndex $route.InterfaceIndex -ErrorAction SilentlyContinue
            if ($a -and $a.Status -eq 'Up') { return $a }
        }
    } catch {}
    try {
        $ipif = Get-NetIPInterface -AddressFamily IPv4 -ErrorAction Stop | Where-Object { $_.ConnectionState -eq 'Connected' } | Sort-Object InterfaceMetric | Select-Object -First 1
        if ($ipif) { return Get-NetAdapter -InterfaceIndex $ipif.InterfaceIndex -ErrorAction SilentlyContinue }
    } catch {}
    return Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
}

function Get-TargetInterface {
    if ($script:SelectedInterfaceIndex) {
        $a = Get-NetAdapter -InterfaceIndex $script:SelectedInterfaceIndex -ErrorAction SilentlyContinue
        if ($a -and $a.Status -eq 'Up') { return $a }
        $script:SelectedInterfaceIndex = $null
    }
    return Get-PrimaryInterface
}

function Get-DnsMode([object]$Adapter) {
    if ($null -eq $Adapter) { return (T 'unavailable') }
    try {
        $guid = [string](Get-SafeProperty $Adapter 'InterfaceGuid' '')
        if ([string]::IsNullOrWhiteSpace($guid)) { return (T 'unavailable') }
        $guid = $guid.Trim().Trim('{','}')
        $path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{$guid}"
        $p = Get-ItemProperty -LiteralPath $path -Name NameServer -ErrorAction SilentlyContinue
        $staticServers = if ($p) { [string](Get-SafeProperty $p 'NameServer' '') } else { '' }
        if (-not [string]::IsNullOrWhiteSpace($staticServers)) { return (T 'manual') }
        return (T 'automatic')
    } catch { return (T 'unavailable') }
}

function Get-InterfaceDns([int]$Index) {
    $rows = @(Get-DnsClientServerAddress -InterfaceIndex $Index -ErrorAction SilentlyContinue)
    $all = New-Object Collections.Generic.List[string]
    foreach ($r in $rows) {
        $servers = @(Get-SafeProperty $r 'ServerAddresses' @())
        foreach ($server in $servers) {
            if (-not [string]::IsNullOrWhiteSpace([string]$server)) { $all.Add([string]$server) }
        }
    }
    return @($all.ToArray() | Select-Object -Unique)
}

function Get-IPv6State([int]$Index) {
    try {
        $ip6 = Get-NetIPInterface -InterfaceIndex $Index -AddressFamily IPv6 -ErrorAction Stop
        if ($ip6.ConnectionState -eq 'Connected') { return (T 'active') }
        return (T 'inactive')
    } catch { return (T 'unavailable') }
}

function Get-DoHState([int]$Index) {
    if ( -not (Get-Command Get-DnsClientDohServerAddress -ErrorAction SilentlyContinue)) { return (T 'unavailable') }
    try {
        $dns = @(Get-InterfaceDns $Index)
        $entries = @(Get-DnsClientDohServerAddress -ErrorAction SilentlyContinue)
        foreach ($ip in $dns) {
            $e = $entries | Where-Object { $_.ServerAddress -eq $ip -and $_.AutoUpgrade -eq $true } | Select-Object -First 1
            if ($e) { return (T 'active') }
        }
        return (T 'notDetected')
    } catch { return (T 'unavailable') }
}

function Show-Header {
    Clear-PDM
    Write-Line
    Write-Host ('                 PORTABLE DNS MANAGER v' + $script:Version) -ForegroundColor Cyan
    Write-Line
    Write-Host (' ' + (L 'DNS catalog reviewed: August 2026' 'Catálogo DNS revisado: Agosto 2026')) -ForegroundColor DarkGray
    Write-Host (' ' + (L 'No telemetry - External diagnostics only on request' 'Sin telemetría - Diagnósticos externos solo bajo solicitud')) -ForegroundColor DarkGray
    Write-Host ''
    $a=Get-TargetInterface
    if($a){
        $dns=@(Get-InterfaceDns $a.ifIndex)
        Write-Host (' {0,-20}: {1}' -f (T 'currentInterface'),($a.Name + ' (#' + $a.ifIndex + ')'))
        Write-Host (' {0,-20}: {1}' -f (T 'currentDns'),$(if(@($dns).Count -gt 0){$dns -join ', '}else{'-'}))
        Write-Host (' {0,-20}: {1}' -f (T 'dnsMode'),(Get-DnsMode $a))
        Write-Host (' {0,-20}: {1}' -f (T 'ipv6'),(Get-IPv6State $a.ifIndex))
        Write-Host (' {0,-20}: {1}' -f (T 'encryptedDns'),(Get-DoHState $a.ifIndex))
    } else {
        Write-Host (' {0,-20}: {1}' -f (T 'currentInterface'),(T 'unavailable')) -ForegroundColor Yellow
    }
    Write-Host ''
}
# ---------------------------------------------------------------------------
# Backup / restore / mutation
# ---------------------------------------------------------------------------
function Get-BackupPath { return (Join-Path (Get-StateFolder) 'last_dns_backup.json') }

function Get-DohSnapshotForProvider([object]$Provider) {
    $result=@()
    if( -not $Provider -or  -not $Provider.DoH -or  -not (Get-Command Get-DnsClientDohServerAddress -ErrorAction SilentlyContinue)){return @()}
    foreach($ip in @($Provider.IPv4 + $Provider.IPv6)){
        $e=Get-DnsClientDohServerAddress -ServerAddress $ip -ErrorAction SilentlyContinue | Select-Object -First 1
        if($e){$result += [pscustomobject]@{ServerAddress=$ip;Existed=$true;DohTemplate=[string]$e.DohTemplate;AllowFallbackToUdp=[bool]$e.AllowFallbackToUdp;AutoUpgrade=[bool]$e.AutoUpgrade}}
        else{$result += [pscustomobject]@{ServerAddress=$ip;Existed=$false;DohTemplate=$null;AllowFallbackToUdp=$false;AutoUpgrade=$false}}
    }
    return @($result)
}

function Save-DnsBackup([object]$Adapter,[object]$NewProvider=$null) {
    $folder=Get-StateFolder
    $dns=@(Get-InterfaceDns $Adapter.ifIndex)
    $mode=Get-DnsMode $Adapter
    $obj=[ordered]@{
        schema=2;createdUtc=[DateTime]::UtcNow.ToString('o');interfaceIndex=$Adapter.ifIndex;interfaceAlias=$Adapter.Name;interfaceGuid=$Adapter.InterfaceGuid.ToString();
        automatic=($mode -eq (T 'automatic'));servers=@($dns);dohSnapshot=@(Get-DohSnapshotForProvider $NewProvider)
    }
    $json=$obj|ConvertTo-Json -Depth 8
    $last=Join-Path $folder 'last_dns_backup.json'
    $archive=Join-Path $folder ('dns_backup_'+(Get-Date -Format 'yyyyMMdd_HHmmss_fff')+'.json')
    [IO.File]::WriteAllText($last,$json,(New-Object Text.UTF8Encoding($true)))
    [IO.File]::WriteAllText($archive,$json,(New-Object Text.UTF8Encoding($true)))
    return $last
}

function Restore-DohSnapshot([object]$Backup){
    if( -not (Get-Command Get-DnsClientDohServerAddress -ErrorAction SilentlyContinue)){return}
    foreach($s in @($Backup.dohSnapshot)){
        if( -not $s){continue}
        try{
            $existing=Get-DnsClientDohServerAddress -ServerAddress ([string]$s.ServerAddress) -ErrorAction SilentlyContinue
            if([bool]$s.Existed){
                if($existing){Set-DnsClientDohServerAddress -ServerAddress ([string]$s.ServerAddress) -DohTemplate ([string]$s.DohTemplate) -AllowFallbackToUdp ([bool]$s.AllowFallbackToUdp) -AutoUpgrade ([bool]$s.AutoUpgrade) -ErrorAction Stop|Out-Null}
                else{Add-DnsClientDohServerAddress -ServerAddress ([string]$s.ServerAddress) -DohTemplate ([string]$s.DohTemplate) -AllowFallbackToUdp ([bool]$s.AllowFallbackToUdp) -AutoUpgrade ([bool]$s.AutoUpgrade) -ErrorAction Stop|Out-Null}
            } elseif($existing -and (Get-Command Remove-DnsClientDohServerAddress -ErrorAction SilentlyContinue)) {
                Remove-DnsClientDohServerAddress -ServerAddress ([string]$s.ServerAddress) -ErrorAction SilentlyContinue
            }
        }catch{}
    }
}

function Configure-DoH([object]$Provider) {
    if($script:DoHPolicy -eq 'plain' -or  -not $Provider.DoH){return $false}
    if( -not (Get-Command Add-DnsClientDohServerAddress -ErrorAction SilentlyContinue)){
        if($Provider.EncryptedOnly -or $script:DoHPolicy -eq 'strict'){throw (T 'dohUnsupported')}
        return $false
    }
    # Encrypted-only providers must never fall back to port 53 because that endpoint may be limited/non-general.
    $fallback=if($Provider.EncryptedOnly){$false}else{($script:DoHPolicy -eq 'preferred')}
    $configured=0
    foreach($ip in @($Provider.IPv4 + $Provider.IPv6)){
        try{
            $existing=Get-DnsClientDohServerAddress -ServerAddress $ip -ErrorAction SilentlyContinue
            if($existing){Set-DnsClientDohServerAddress -ServerAddress $ip -DohTemplate $Provider.DoH -AutoUpgrade $true -AllowFallbackToUdp $fallback -ErrorAction Stop|Out-Null}
            else{Add-DnsClientDohServerAddress -ServerAddress $ip -DohTemplate $Provider.DoH -AutoUpgrade $true -AllowFallbackToUdp $fallback -ErrorAction Stop|Out-Null}
            $configured++
        }catch{if($Provider.EncryptedOnly -or $script:DoHPolicy -eq 'strict'){throw}}
    }
    if(($Provider.EncryptedOnly -or $script:DoHPolicy -eq 'strict') -and $configured -lt 1){throw (T 'dohUnsupported')}
    return ($configured -gt 0)
}

function Verify-DnsResolution {
    try{$sw=[Diagnostics.Stopwatch]::StartNew();$r=Resolve-DnsName -Name 'example.com' -Type A -DnsOnly -ErrorAction Stop|Where-Object{$_.IPAddress}|Select-Object -First 1;$sw.Stop();return [pscustomobject]@{Success=($null -ne $r);Ms=$sw.ElapsedMilliseconds;Address=if($r){$r.IPAddress}else{$null}}}
    catch{return [pscustomobject]@{Success=$false;Ms=$null;Address=$null;Error=$_.Exception.Message}}
}

function Show-ProviderSummary([object]$Provider){
    Write-Host ((T 'provider')+': '+$Provider.Name) -ForegroundColor Cyan
    Write-Host ('  '+$(if($script:Lang -eq 'es'){$Provider.SummaryEs}else{$Provider.SummaryEn}))
    if(@($Provider.IPv4).Count -gt 0){Write-Host ('IPv4: '+($Provider.IPv4 -join ' / '))}
    if(@($Provider.IPv6).Count -gt 0){Write-Host ('IPv6: '+($Provider.IPv6 -join ' / '))}
    if($Provider.DoH){Write-Host ('DoH : '+$Provider.DoH)}
    if($Provider.EncryptedOnly){Write-Host ('  '+(L 'Encrypted DNS only (DoH required).' 'Solo DNS cifrado (requiere DoH).')) -ForegroundColor Yellow}
}

function Apply-Provider([object]$Provider,[bool]$Ask=$true){
    if($Ask){Show-Header;Show-ProviderSummary $Provider;Write-Host ''; $ans=(Read-Host (T 'confirmApply')).Trim().ToUpperInvariant();$yes=if($script:Lang -eq 'es'){@('S','SI','SÍ','Y','YES')}else{@('Y','YES','S','SI','SÍ')};if($yes -notcontains $ans){return}}
    $a=Get-TargetInterface;if( -not $a){throw (L 'No active network interface was found.' 'No se encontró una interfaz de red activa.')}
    if($Provider.EncryptedOnly -and $script:DoHPolicy -eq 'plain'){throw (T 'dohEncryptedOnly')}
    Show-Header;Write-Host ((T 'applying')+': '+$Provider.Name+' ...') -ForegroundColor Cyan
    $backup=Save-DnsBackup $a $Provider
    $addresses=@($Provider.IPv4+$Provider.IPv6)
    if(@($addresses).Count -eq 0){throw (L 'This profile has no usable IP addresses.' 'Este perfil no tiene direcciones IP utilizables.')}
    $doh=Configure-DoH $Provider
    Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses $addresses -ErrorAction Stop|Out-Null
    Clear-DnsClientCache -ErrorAction SilentlyContinue;Start-Sleep -Milliseconds 450
    $actual=@(Get-InterfaceDns $a.ifIndex);$missing=@($addresses|Where-Object{$actual -notcontains $_});if(@($missing).Count -gt 0){throw ('Configured DNS verification mismatch: '+($missing -join ', '))}
    $check=Verify-DnsResolution
    Write-Host '';Write-Host (T 'applied') -ForegroundColor Green;Write-Host ((T 'provider')+'      : '+$Provider.Name);Write-Host ((T 'interface')+'      : '+$a.Name)
    if(@($Provider.IPv4).Count -gt 0){Write-Host ('IPv4          : '+($Provider.IPv4 -join ' / '))};if(@($Provider.IPv6).Count -gt 0){Write-Host ('IPv6          : '+($Provider.IPv6 -join ' / '))}
    Write-Host ('DoH           : '+$(if($doh){T 'active'}else{if($script:DoHPolicy -eq 'plain'){T 'inactive'}else{T 'unavailable'}}));Write-Host ((T 'backupSaved')+': '+$backup)
    if($check.Success){Write-Host ((T 'verificationOk')+(' ({0} ms)' -f $check.Ms)) -ForegroundColor Green}else{Write-Host (T 'changeSucceededBut') -ForegroundColor Yellow}
    Write-Host '';Write-Host (T 'warningVpnDns') -ForegroundColor DarkYellow;Pause-PDM
}

function Apply-CustomDns {
    Show-Header;$raw=Read-Host (T 'enterDns');$items=@($raw -split '[,;\s]+'|Where-Object{$_});if(@($items).Count -eq 0){return}
    foreach($item in $items){$parsed=$null;if( -not [Net.IPAddress]::TryParse($item,[ref]$parsed)){Write-Host (T 'invalidIp') -ForegroundColor Red;Pause-PDM;return}}
    $doh=Read-Host (T 'enterDoh');if($doh -and  -not $doh.StartsWith('https://',[StringComparison]::OrdinalIgnoreCase)){Write-Host 'DoH URL must use HTTPS.' -ForegroundColor Red;Pause-PDM;return}
    $v4=@();$v6=@();foreach($item in $items){$ip=[Net.IPAddress]::Parse($item);if($ip.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetwork){$v4+=$item}else{$v6+=$item}}
    $p=New-PdmProvider 'custom' 'Custom' (L 'Custom DNS' 'DNS personalizado') 'custom' $v4 $v6 $(if($doh){$doh}else{$null}) $false $false @('custom') @() 'User-provided DNS addresses.' 'Direcciones DNS introducidas por el usuario.'
    Apply-Provider $p $true
}

function Configure-NextDns {
    Show-Header
    Write-Host (L 'NEXTDNS CUSTOM PROFILE' 'PERFIL PERSONALIZADO NEXTDNS') -ForegroundColor Cyan
    Write-Host (L 'NextDNS uses a configuration-specific ID. Use the exact IPs shown in your NextDNS Setup page; they can vary by configuration.' 'NextDNS usa un ID específico de configuración. Utiliza las IP exactas mostradas en tu página Setup de NextDNS; pueden variar según la configuración.') -ForegroundColor DarkYellow
    Write-Host ''
    $id=(Read-Host (L 'Configuration ID (for the DoH URL)' 'ID de configuración (para la URL DoH)')).Trim()
    if($id -notmatch '^[A-Za-z0-9]{4,32}$'){Write-Host (L 'Invalid configuration ID format.' 'Formato de ID de configuración no válido.') -ForegroundColor Red;Pause-PDM;return}
    $raw=Read-Host (L 'Paste the IPv4/IPv6 DNS addresses from your NextDNS Setup page, separated by spaces/commas' 'Pega las direcciones DNS IPv4/IPv6 de tu página Setup de NextDNS, separadas por espacios/comas')
    $items=@($raw -split '[,;\s]+'|Where-Object{$_});if(@($items).Count -eq 0){return}
    foreach($item in $items){$tmp=$null;if( -not [Net.IPAddress]::TryParse($item,[ref]$tmp)){Write-Host (T 'invalidIp') -ForegroundColor Red;Pause-PDM;return}}
    $v4=@();$v6=@();foreach($item in $items){$ip=[Net.IPAddress]::Parse($item);if($ip.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetwork){$v4+=$item}else{$v6+=$item}}
    $url='https://dns.nextdns.io/'+$id
    $p=New-PdmProvider 'nextdns_custom' 'NextDNS' 'NextDNS Custom Profile' 'custom' $v4 $v6 $url $true $false @('custom','encrypted-only') @() 'Custom NextDNS profile using your configuration ID.' 'Perfil NextDNS personalizado usando tu ID de configuración.'
    Apply-Provider $p $true
}

function Reset-DnsAutomatic {
    $a=Get-TargetInterface;if( -not $a){return};Save-DnsBackup $a $null|Out-Null;Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses -ErrorAction Stop|Out-Null;Clear-DnsClientCache -ErrorAction SilentlyContinue
    Write-Host '';Write-Host (T 'autoResetDone') -ForegroundColor Green;Pause-PDM
}

function Restore-PreviousDns {
    $path=Get-BackupPath;if( -not (Test-Path $path)){Write-Host '';Write-Host (T 'noBackup') -ForegroundColor Yellow;Pause-PDM;return}
    $b=Get-Content -LiteralPath $path -Raw -Encoding UTF8|ConvertFrom-Json;$a=Get-NetAdapter -InterfaceIndex ([int]$b.interfaceIndex) -ErrorAction SilentlyContinue;if( -not $a){$a=Get-TargetInterface};if( -not $a){throw (L 'Backup interface is unavailable and no active interface was found.' 'La interfaz de la copia no está disponible y no se encontró otra interfaz activa.')}
    if([bool]$b.automatic){Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses -ErrorAction Stop|Out-Null}elseif(@($b.servers).Count -gt 0){Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses @($b.servers) -ErrorAction Stop|Out-Null}else{Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses -ErrorAction Stop|Out-Null}
    Restore-DohSnapshot $b;Clear-DnsClientCache -ErrorAction SilentlyContinue;Write-Host '';Write-Host (T 'restoreDone') -ForegroundColor Green;Pause-PDM
}
# ---------------------------------------------------------------------------
# Diagnostics
# ---------------------------------------------------------------------------
function Test-Provider([object]$Provider) {
    if ($null -eq $Provider -or -not $Provider.Benchmark -or @($Provider.IPv4).Count -eq 0) { return $null }
    $servers = @($Provider.IPv4)
    $lastError = $null

    foreach ($server in $servers) {
        try {
            $times = @()
            foreach ($attempt in 1..2) {
                $sw = [Diagnostics.Stopwatch]::StartNew()
                $r = Resolve-DnsName -Name 'example.com' -Type A -Server ([string]$server) -DnsOnly -QuickTimeout -ErrorAction Stop |
                    Where-Object { $null -ne (Get-SafeProperty $_ 'IPAddress' $null) } | Select-Object -First 1
                $sw.Stop()
                if ($r) { $times += [double]$sw.Elapsed.TotalMilliseconds }
            }
            if (@($times).Count -gt 0) {
                $avg = [math]::Round([double](($times | Measure-Object -Average).Average),1)
                return [pscustomobject]@{
                    Id=$Provider.Id; ProviderObject=$Provider; ProviderName=$Provider.Name; Server=[string]$server;
                    Success=$true; LatencyMs=$avg; Error=$null
                }
            }
        } catch {
            $lastError = $_.Exception.Message
        }
    }

    return [pscustomobject]@{
        Id=$Provider.Id; ProviderObject=$Provider; ProviderName=$Provider.Name; Server=([string]$servers[0]);
        Success=$false; LatencyMs=$null; Error=$lastError
    }
}

function Get-ProvidersByFilter([string]$Filter){
    $all=@($script:Providers.Values)
    switch($Filter){
        'general'{return @($all|Where-Object{$_.Tags -contains 'general' -and $_.Benchmark})}
        'security'{return @($all|Where-Object{$_.Tags -contains 'security' -and $_.Benchmark})}
        'ads'{return @($all|Where-Object{$_.Tags -contains 'ads' -and $_.Benchmark})}
        'family'{return @($all|Where-Object{$_.Tags -contains 'family' -and $_.Benchmark})}
        'adult'{return @($all|Where-Object{$_.Tags -contains 'adult' -and $_.Benchmark})}
        'europe'{return @($all|Where-Object{$_.Tags -contains 'europe' -and $_.Benchmark})}
        default{return @($all|Where-Object{$_.Benchmark})}
    }
}

function Select-BenchmarkFilter {
    Show-Header;Write-Host (L 'WHAT DO YOU WANT TO BENCHMARK?' '¿QUÉ QUIERES COMPARAR?') -ForegroundColor Cyan;Write-Host ''
    Write-Host (L ' [1] All compatible profiles' ' [1] Todos los perfiles compatibles');Write-Host (L ' [2] General / unfiltered' ' [2] Uso general / sin filtrado');Write-Host (L ' [3] Security / malware' ' [3] Seguridad / malware');Write-Host (L ' [4] Ads / tracking' ' [4] Publicidad / rastreo');Write-Host (L ' [5] Family' ' [5] Protección familiar');Write-Host (L ' [6] Adult-content filtering' ' [6] Filtrado de contenido adulto');Write-Host (L ' [7] European profiles' ' [7] Perfiles europeos');Write-Host (' [B] '+(T 'back'))
    $c=(Read-Host (T 'select')).Trim().ToUpperInvariant();switch($c){'1'{return 'all'};'2'{return 'general'};'3'{return 'security'};'4'{return 'ads'};'5'{return 'family'};'6'{return 'adult'};'7'{return 'europe'};default{return $null}}
}

function Run-Benchmark([string]$Filter='ask') {
    if ($Filter -eq 'ask') { $Filter = Select-BenchmarkFilter; if (-not $Filter) { return } }
    $list = @(Get-ProvidersByFilter $Filter)
    if (@($list).Count -eq 0) { return }

    Show-Header
    Write-Host (T 'benchmarkTitle') -ForegroundColor Cyan
    Write-Host (T 'benchmarkInfo') -ForegroundColor DarkGray
    Write-Host ''

    $results = @()
    foreach ($p in $list) {
        Write-Host -NoNewline ((' {0,-42}' -f $p.Name))
        try { $r = Test-Provider $p } catch { $r = $null }
        if ($null -ne $r -and [bool]$r.Success) {
            Write-Host (' {0,6} ms  ({1})' -f $r.LatencyMs,$r.Server) -ForegroundColor Green
            $results += $r
        } else {
            Write-Host ' FAIL' -ForegroundColor DarkYellow
        }
    }

    $script:LastBenchmark = @($results | Sort-Object LatencyMs)
    Write-Host ''
    if (@($script:LastBenchmark).Count -eq 0) {
        Write-Host (T 'noResult') -ForegroundColor Yellow
        Pause-PDM
        return
    }

    $best = $script:LastBenchmark[0]
    Write-Host ((T 'fastest') + ': ' + $best.ProviderName + ' (' + $best.LatencyMs + ' ms)') -ForegroundColor Cyan
    Write-Host (L 'This only reports the lowest measured DNS-query time; it does not mean this profile is the best for security/privacy/filtering.' 'Esto solo indica el menor tiempo medido de consulta DNS; no significa que ese perfil sea el mejor en seguridad/privacidad/filtrado.') -ForegroundColor DarkYellow
    Write-Host ''
    Write-Host (L ' [1] Apply lowest-latency result' ' [1] Aplicar el resultado de menor latencia')
    Write-Host (L ' [2] Show sorted results' ' [2] Mostrar resultados ordenados')
    Write-Host (' [B] ' + (T 'back'))

    $c = (Read-Host (T 'select')).Trim().ToUpperInvariant()
    if ($c -eq '1') {
        Apply-Provider $best.ProviderObject $true
    } elseif ($c -eq '2') {
        Write-Host ''
        foreach ($x in $script:LastBenchmark) {
            Write-Host (' {0,-39} {1,6} ms  {2}' -f $x.ProviderName,$x.LatencyMs,$x.Server)
        }
        Pause-PDM
    }
}
function Test-CurrentDns {
    Show-Header
    Write-Host (T 'currentTest') -ForegroundColor Cyan
    Write-Host ''
    $check=Verify-DnsResolution
    if($check.Success){
        Write-Host ((T 'status') + ': OK') -ForegroundColor Green
        Write-Host ((T 'latency') + ': ' + $check.Ms + ' ms')
        Write-Host ('example.com -> ' + $check.Address)
    } else {
        Write-Host ((T 'status') + ': FAIL') -ForegroundColor Red
        if($check.PSObject.Properties['Error']){ Write-Host $check.Error }
    }
    Pause-PDM
}

function Show-InterfaceInfo {
    Show-Header
    Write-Host (T 'interfacesTitle') -ForegroundColor Cyan
    Write-Host ''

    $adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue |
        Where-Object { [string]$_.Status -ne 'Not Present' } |
        Sort-Object @{Expression={if ([string]$_.Status -eq 'Up') {0} else {1}}},Name)

    if (@($adapters).Count -eq 0) {
        Write-Host (L 'No network interfaces were returned by Windows.' 'Windows no devolvió interfaces de red.') -ForegroundColor Yellow
        Pause-PDM
        return
    }

    foreach ($a in $adapters) {
        try {
            $idx = [int]$a.ifIndex
            $ip4 = @(Get-NetIPAddress -InterfaceIndex $idx -AddressFamily IPv4 -ErrorAction SilentlyContinue |
                Where-Object {$_.IPAddress -notlike '169.254.*'} | Select-Object -ExpandProperty IPAddress)
            $ip6 = @(Get-NetIPAddress -InterfaceIndex $idx -AddressFamily IPv6 -ErrorAction SilentlyContinue |
                Where-Object {$_.IPAddress -and $_.IPAddress -notlike 'fe80:*'} | Select-Object -ExpandProperty IPAddress)
            $gw = @(Get-NetRoute -InterfaceIndex $idx -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
                Select-Object -ExpandProperty NextHop)
            $dns = @(Get-InterfaceDns $idx)

            Write-SubLine
            Write-Host ((T 'alias') + '       : ' + [string]$a.Name)
            Write-Host ('ifIndex     : ' + $idx)
            Write-Host ((T 'description') + ': ' + [string]$a.InterfaceDescription)
            Write-Host ((T 'status') + '      : ' + [string]$a.Status)
            Write-Host ((T 'localIPv4') + '  : ' + (Join-OrDash $ip4))
            Write-Host ((T 'localIPv6') + '  : ' + (Join-OrDash $ip6))
            Write-Host ((T 'gateway') + '     : ' + (Join-OrDash $gw))
            Write-Host ('DNS         : ' + (Join-OrDash $dns))
            Write-Host ((T 'metric') + '      : ' + (Get-InterfaceMetric $idx))
            $mac = [string](Get-SafeProperty $a 'MacAddress' '')
            if (-not [string]::IsNullOrWhiteSpace($mac)) { Write-Host ('MAC         : ' + $mac) }
            $speed = Get-SafeProperty $a 'LinkSpeed' $null
            if ($null -ne $speed) { Write-Host ('Link        : ' + [string]$speed) }
        } catch {
            Write-SubLine
            Write-Host ((L 'Could not inspect interface: ' 'No se pudo inspeccionar la interfaz: ') + [string]$a.Name) -ForegroundColor Yellow
            Write-Host ('  ' + $_.Exception.Message) -ForegroundColor DarkGray
        }
    }
    Write-Host ''
    Pause-PDM
}

function Get-VpnIndicators {
    $pattern='VPN|WireGuard|Wintun|TAP|TUN|OpenVPN|NordLynx|Mullvad|Proton|Surfshark|ExpressVPN|AnyConnect|GlobalProtect|Tailscale|ZeroTier|Cloudflare WARP|Fortinet'
    $hits=@(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and (($_.Name -match $pattern) -or ($_.InterfaceDescription -match $pattern)) })
    $primary=Get-PrimaryInterface
    $primaryLooksVpn=$false
    if($primary){ $primaryLooksVpn=(($primary.Name -match $pattern) -or ($primary.InterfaceDescription -match $pattern)) }
    return [pscustomobject]@{Hits=$hits;PrimaryLooksVpn=$primaryLooksVpn}
}

function Show-PublicIpVpn {
    if(-not $script:ExternalNoticeAccepted){
        Show-Header
        Write-Host (T 'externalTitle') -ForegroundColor Yellow
        Write-Host ''
        Write-Host (T 'externalNotice')
        Write-Host ''
        $a=(Read-Host (T 'continueQuestion')).Trim().ToUpperInvariant()
        $yes=if($script:Lang -eq 'es'){@('S','SI','SÍ','Y','YES')}else{@('Y','YES','S','SI','SÍ')}
        if($yes -notcontains $a){return}
        $script:ExternalNoticeAccepted=$true
    }

    Show-Header
    Write-Host (T 'publicIpTitle') -ForegroundColor Cyan
    Write-Host ''
    try {
        $geo=Invoke-RestMethod -Uri 'https://ipwho.is/' -Method Get -TimeoutSec 10 -Headers @{'User-Agent'='Portable-DNS-Manager/1.0'}
        $success=Get-SafeProperty $geo 'success' $true
        if($success -eq $false){throw (L 'The IP geolocation service returned an error.' 'El servicio de geolocalización IP devolvió un error.')}

        Write-Host ('{0,-22}: {1}' -f (T 'ip'),(Get-SafeProperty $geo 'ip' '-'))
        Write-Host ('{0,-22}: {1}' -f (T 'type'),(Get-SafeProperty $geo 'type' '-'))
        Write-Host ('{0,-22}: {1}' -f (T 'country'),(Get-SafeProperty $geo 'country' '-'))
        Write-Host ('{0,-22}: {1}' -f (T 'region'),(Get-SafeProperty $geo 'region' '-'))
        Write-Host ('{0,-22}: {1}' -f (T 'city'),(Get-SafeProperty $geo 'city' '-'))

        $conn=Get-SafeProperty $geo 'connection' $null
        if($conn){
            Write-Host ('{0,-22}: {1}' -f (T 'isp'),(Get-SafeProperty $conn 'isp' '-'))
            $asn=Get-SafeProperty $conn 'asn' '-'
            Write-Host ('{0,-22}: AS{1}' -f (T 'asn'),$asn)
            Write-Host ('{0,-22}: {1}' -f (T 'organization'),(Get-SafeProperty $conn 'org' '-'))
        }
        $tz=Get-SafeProperty $geo 'timezone' $null
        if($tz){Write-Host ('{0,-22}: {1}' -f (T 'timezone'),(Get-SafeProperty $tz 'id' '-'))}

        Write-Host ''
        $vpn=Get-VpnIndicators
        $hits=@(Get-SafeProperty $vpn 'Hits' @())
        $primaryLooksVpn=[bool](Get-SafeProperty $vpn 'PrimaryLooksVpn' $false)
        Write-Host ((T 'vpnIndicators') + ':') -ForegroundColor Cyan
        if(@($hits).Count -gt 0 -or $primaryLooksVpn){
            Write-Host ('  ' + (T 'vpnLikely')) -ForegroundColor Yellow
            foreach($h in $hits){Write-Host ('  - ' + [string]$h.Name + ' | ' + [string]$h.InterfaceDescription)}
        }else{
            Write-Host ('  ' + (T 'vpnNo'))
        }
        Write-Host ('  ' + (T 'vpnUncertain')) -ForegroundColor DarkYellow
        Write-Host ''
        Write-Host (T 'warningVpnDns') -ForegroundColor DarkYellow
    }catch{
        Write-Host ((T 'failed') + ': ' + $_.Exception.Message) -ForegroundColor Red
    }
    Pause-PDM
}

function Show-FullConfiguration {
    Show-Header
    Write-Host (L 'FULL NETWORK / DNS CONFIGURATION' 'CONFIGURACIÓN COMPLETA DE RED / DNS') -ForegroundColor Cyan
    Write-Host ''

    try {
        $folder = Get-StateFolder
        Write-Host ((T 'windowsVersion') + ': ' + [Environment]::OSVersion.VersionString)
        Write-Host ((T 'powershellVersion') + ': ' + $PSVersionTable.PSVersion)
        Write-Host ((T 'admin') + ': ' + $(if(Test-IsAdministrator){T 'yesWord'}else{T 'noWord'}))
        Write-Host ((T 'configFolder') + ': ' + $folder)
        Write-Host ((T 'backupFile') + ': ' + (Join-Path $folder 'last_dns_backup.json'))
    } catch {
        Write-Host ((L 'State/backup information unavailable: ' 'Información de estado/copias no disponible: ') + $_.Exception.Message) -ForegroundColor Yellow
    }

    Write-Host ''
    Write-Host (L 'ACTIVE / CONNECTED IP CONFIGURATION' 'CONFIGURACIÓN IP ACTIVA / CONECTADA') -ForegroundColor Cyan
    try {
        $configs = @(Get-NetIPConfiguration -Detailed -ErrorAction SilentlyContinue)
        if (@($configs).Count -eq 0) {
            Write-Host '-'
        } else {
            foreach ($cfg in $configs) {
                Write-SubLine
                $alias = [string](Get-SafeProperty $cfg 'InterfaceAlias' '-')
                $idx = Get-SafeProperty $cfg 'InterfaceIndex' '-'
                Write-Host ('Interfaz / Interface : ' + $alias + ' (#' + $idx + ')')

                $v4objs = @(Get-SafeProperty $cfg 'IPv4Address' @())
                $v6objs = @(Get-SafeProperty $cfg 'IPv6Address' @())
                $v4 = @($v4objs | ForEach-Object { Get-SafeProperty $_ 'IPAddress' $null } | Where-Object {$_})
                $v6 = @($v6objs | ForEach-Object { Get-SafeProperty $_ 'IPAddress' $null } | Where-Object {$_})
                $gwobjs = @(Get-SafeProperty $cfg 'IPv4DefaultGateway' @())
                $gw = @($gwobjs | ForEach-Object { Get-SafeProperty $_ 'NextHop' $null } | Where-Object {$_})
                $dnsobjs = @(Get-SafeProperty $cfg 'DNSServer' @())
                $dns = @($dnsobjs | ForEach-Object { @(Get-SafeProperty $_ 'ServerAddresses' @()) } | Where-Object {$_})
                Write-Host ('IPv4                : ' + (Join-OrDash $v4))
                Write-Host ('IPv6                : ' + (Join-OrDash $v6))
                Write-Host ((T 'gateway') + '             : ' + (Join-OrDash $gw))
                Write-Host ('DNS                 : ' + (Join-OrDash $dns))
            }
        }
    } catch {
        Write-Host ((L 'IP configuration section failed: ' 'Falló la sección de configuración IP: ') + $_.Exception.Message) -ForegroundColor Yellow
    }

    Write-Host ''
    Write-Host 'DNS / DoH:' -ForegroundColor Cyan
    try {
        $a = Get-TargetInterface
        if ($a) {
            $dns = @(Get-InterfaceDns $a.ifIndex)
            Write-Host ((T 'currentInterface') + ': ' + $a.Name + ' (#' + $a.ifIndex + ')')
            Write-Host ((T 'currentDns') + ': ' + (Join-OrDash $dns))
            Write-Host ((T 'dnsMode') + ': ' + (Get-DnsMode $a))
            Write-Host ((T 'encryptedDns') + ': ' + (Get-DoHState $a.ifIndex))
        }

        if (Get-Command Get-DnsClientDohServerAddress -ErrorAction SilentlyContinue) {
            $dohEntries = @(Get-DnsClientDohServerAddress -ErrorAction SilentlyContinue | Where-Object { [bool](Get-SafeProperty $_ 'AutoUpgrade' $false) })
            if (@($dohEntries).Count -gt 0) {
                Write-Host ''
                foreach ($d in $dohEntries) {
                    Write-Host ('  {0} -> {1} | fallback UDP: {2}' -f (Get-SafeProperty $d 'ServerAddress' '-'),(Get-SafeProperty $d 'DohTemplate' '-'),(Get-SafeProperty $d 'AllowFallbackToUdp' '-'))
                }
            } else {
                Write-Host (L '  No active AutoUpgrade DoH entries detected.' '  No se detectaron entradas DoH AutoUpgrade activas.')
            }
        } else {
            Write-Host (L '  Native Windows DoH cmdlets are unavailable on this system.' '  Los cmdlets DoH nativos de Windows no están disponibles en este sistema.')
        }
    } catch {
        Write-Host ((L 'DNS/DoH section failed: ' 'Falló la sección DNS/DoH: ') + $_.Exception.Message) -ForegroundColor Yellow
    }

    Write-Host ''
    Pause-PDM
}

function Select-NetworkInterface {
    Show-Header
    $adapters=@(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq 'Up'} | Sort-Object @{Expression={Get-InterfaceMetric $_.ifIndex}})
    Write-Host ('[0] ' + (T 'autoInterface'))
    for($i=0;$i -lt @($adapters).Count;$i++){
        Write-Host ('[{0}] {1} | {2} | metric {3}' -f ($i+1),$adapters[$i].Name,$adapters[$i].InterfaceDescription,(Get-InterfaceMetric $adapters[$i].ifIndex))
    }
    Write-Host ''
    $c=Read-Host (T 'selectInterfacePrompt')
    $n=0
    if( -not [int]::TryParse($c,[ref]$n)){return}
    if($n -eq 0){$script:SelectedInterfaceIndex=$null;return}
    if($n -ge 1 -and $n -le @($adapters).Count){$script:SelectedInterfaceIndex=$adapters[$n-1].ifIndex}
}

function Select-DoHPolicy {
    Show-Header
    Write-Host ('[1] ' + (T 'dohPreferred'))
    Write-Host ('[2] ' + (T 'dohStrict'))
    Write-Host ('[3] ' + (T 'dohPlain'))
    Write-Host ''
    $c=(Read-Host (T 'select')).Trim()
    switch($c){'1'{$script:DoHPolicy='preferred'};'2'{$script:DoHPolicy='strict'};'3'{$script:DoHPolicy='plain'}}
}


# ---------------------------------------------------------------------------
# Help, provider discovery and local domain blocking
# ---------------------------------------------------------------------------
function Show-QuickGuide {
    Show-Header;Write-Host (L 'QUICK GUIDE' 'MINI GUÍA') -ForegroundColor Cyan;Write-Host ''
    if($script:Lang -eq 'es'){
        Write-Host 'DNS convierte nombres como example.com en direcciones que los equipos pueden utilizar.'
        Write-Host '';Write-Host 'USO NORMAL        -> estabilidad, privacidad y rendimiento sin filtrado por categorías.';Write-Host 'SEGURIDAD         -> bloquea dominios asociados a malware, phishing u otras amenazas.';Write-Host 'PUBLICIDAD        -> bloquea muchos dominios publicitarios y/o rastreadores.';Write-Host 'CONTENIDO ADULTO  -> bloquea categorías explícitas; el alcance depende del proveedor.';Write-Host 'FAMILIAR          -> combina filtros para menores; algunos añaden SafeSearch o anti-evasión.'
        Write-Host '';Write-Host 'IMPORTANTE:' -ForegroundColor Yellow;Write-Host '- Un DNS no es una VPN.';Write-Host '- El filtrado DNS no puede bloquear todo el contenido dentro de una web permitida.';Write-Host '- El DNS seguro del navegador, una VPN o permisos de administrador pueden eludir la configuración del sistema.';Write-Host '- Para niños, esto es una capa adicional y no sustituye un control parental completo.'
    }else{
        Write-Host 'DNS translates names such as example.com into addresses computers can use.'
        Write-Host '';Write-Host 'GENERAL USE       -> stability, privacy and performance without category filtering.';Write-Host 'SECURITY          -> blocks domains associated with malware, phishing or other threats.';Write-Host 'ADS/TRACKING      -> blocks many advertising and/or tracking domains.';Write-Host 'ADULT CONTENT     -> blocks explicit categories; scope depends on the provider.';Write-Host 'FAMILY            -> combines child-oriented filters; some add SafeSearch or anti-bypass rules.'
        Write-Host '';Write-Host 'IMPORTANT:' -ForegroundColor Yellow;Write-Host '- DNS is not a VPN.';Write-Host '- DNS filtering cannot block every piece of content hosted inside an allowed website.';Write-Host '- Browser Secure DNS, VPN software or administrator rights can bypass system DNS settings.';Write-Host '- For children, this is an additional protection layer, not a complete parental-control system.'
    }
    Pause-PDM
}

function Show-Documentation {
    Show-Header;Write-Host (L 'DOCUMENTATION / OFFICIAL SOURCE' 'DOCUMENTACIÓN / FUENTE OFICIAL') -ForegroundColor Cyan;Write-Host ''
    Write-Host $script:RepoUrl -ForegroundColor White;Write-Host ''
    if($script:RepoPublished){$c=(Read-Host (L 'Open the official repository in your browser? [Y/N]' '¿Abrir el repositorio oficial en el navegador? [S/N]')).Trim().ToUpperInvariant();if(@('Y','YES','S','SI','SÍ') -contains $c){Start-Process $script:RepoUrl}}
    else{Write-Host (L 'RC notice: the repository has not been published yet. This URL is reserved for the final release after validation.' 'Aviso RC: el repositorio todavía no se ha publicado. Esta URL queda reservada para la release final tras la validación.') -ForegroundColor Yellow;Pause-PDM}
}

function Show-FamilyComparison {
    Show-Header;Write-Host (L 'FAMILY FILTER COMPARISON' 'COMPARATIVA DE PROTECCIÓN FAMILIAR') -ForegroundColor Cyan
    Write-Host (L 'Features below are limited to what each provider explicitly documents; a dash means not claimed here, not necessarily impossible.' 'Las funciones se limitan a lo que cada proveedor documenta explícitamente; un guion significa que no se afirma aquí, no necesariamente que sea imposible.') -ForegroundColor DarkGray;Write-Host ''
    $rows=@(
        [pscustomobject]@{Name='DNS4EU Child + Ads';Threat='Y';Adult='Y';Ads='Y';Safe='-';Extra=(L 'violence, drugs' 'violencia, drogas')},
        [pscustomobject]@{Name='CleanBrowsing Family';Threat='Y';Adult='Y';Ads='-';Safe='Y';Extra=(L 'proxy/VPN domains, mixed content' 'dominios proxy/VPN, contenido mixto')},
        [pscustomobject]@{Name='AdGuard Family';Threat='Y';Adult='Y';Ads='Y';Safe='Y';Extra=(L 'trackers' 'rastreadores')},
        [pscustomobject]@{Name='Cloudflare Family';Threat='Y';Adult='Y';Ads='-';Safe='-';Extra='-'},
        [pscustomobject]@{Name='Vercara Family Secure';Threat='Y';Adult='Y';Ads='-';Safe='-';Extra=(L 'gambling, violence, hate' 'apuestas, violencia, odio')},
        [pscustomobject]@{Name='Mullvad Family (DoH)';Threat='Y';Adult='Y';Ads='Y';Safe='-';Extra=(L 'trackers, gambling' 'rastreadores, apuestas')}
    )
    Write-Host (' {0,-27} {1,-7} {2,-7} {3,-5} {4,-9} {5}' -f (L 'Profile' 'Perfil'),(L 'Threats' 'Amenaz.'),(L 'Adult' 'Adulto'),'Ads',(L 'SafeSrch' 'SafeSrch'),(L 'Extra' 'Extra'))
    Write-SubLine;foreach($r in $rows){Write-Host (' {0,-27} {1,-7} {2,-7} {3,-5} {4,-9} {5}' -f $r.Name,$r.Threat,$r.Adult,$r.Ads,$r.Safe,$r.Extra)}
    Write-Host '';Write-Host (L 'For stronger child protection, also use a non-administrator child account and configure protection at the router/parental-control layer.' 'Para una protección infantil más resistente, usa también una cuenta infantil sin permisos de administrador y configura protección en el router/control parental.') -ForegroundColor DarkYellow;Pause-PDM
}

function Show-ProvidersAndChoose([string]$Filter){
    do {
        Show-Header
        $list = @($script:Providers.Values)
        switch($Filter){
            'general'{$list=@($list|Where-Object{$_.Tags -contains 'general'})}
            'security'{$list=@($list|Where-Object{$_.Tags -contains 'security'})}
            'ads'{$list=@($list|Where-Object{$_.Tags -contains 'ads'})}
            'family'{$list=@($list|Where-Object{$_.Tags -contains 'family'})}
            'adult'{$list=@($list|Where-Object{$_.Tags -contains 'adult'})}
            'encrypted'{$list=@($list|Where-Object{$_.DoH})}
            'europe'{$list=@($list|Where-Object{$_.Tags -contains 'europe'})}
        }

        Write-Host (L 'DNS PROFILES' 'PERFILES DNS') -ForegroundColor Cyan
        Write-Host (L 'DNS1 / DNS2 shown below are IPv4 endpoints. IPv6 and DoH remain available in profile details.' 'DNS1 / DNS2 mostrados abajo son endpoints IPv4. IPv6 y DoH siguen disponibles en los detalles del perfil.') -ForegroundColor DarkGray
        Write-Host ''
        for($i=0; $i -lt @($list).Count; $i++) {
            $p = $list[$i]
            $mark = if($p.EncryptedOnly){' [DoH-only]'}elseif($p.DoH){' [DoH]'}else{''}
            $pair = Get-IPv4PairText $p
            Write-Host (' [{0,2}] {1,-39} {2,-34}{3}' -f ($i+1),$p.Name,$pair,$mark)
        }

        Write-Host ''
        Write-Host (' [I] ' + (L 'Show details for a profile' 'Ver detalles de un perfil'))
        Write-Host (' [B] ' + (T 'back'))
        $c = (Read-Host (T 'select')).Trim().ToUpperInvariant()
        if($c -eq 'B'){return}
        if($c -eq 'I'){
            $n=0
            $x=Read-Host (L 'Profile number' 'Número de perfil')
            if([int]::TryParse($x,[ref]$n) -and $n -ge 1 -and $n -le @($list).Count){
                Show-Header
                Show-ProviderSummary $list[$n-1]
                Pause-PDM
            }
            continue
        }
        $n=0
        if([int]::TryParse($c,[ref]$n) -and $n -ge 1 -and $n -le @($list).Count){ Apply-Provider $list[$n-1] $true }
    } while($true)
}

function Provider-FilterMenu {
    do{Show-Header;Write-Host (L 'FILTER DNS CATALOG' 'FILTRAR CATÁLOGO DNS') -ForegroundColor Cyan;Write-Host '';Write-Host (L ' [1] All profiles' ' [1] Todos los perfiles');Write-Host (L ' [2] General / no category filtering' ' [2] Uso general / sin filtrado por categorías');Write-Host (L ' [3] Security / malware' ' [3] Seguridad / malware');Write-Host (L ' [4] Ads / tracking' ' [4] Publicidad / rastreo');Write-Host (L ' [5] Family protection' ' [5] Protección familiar');Write-Host (L ' [6] Adult-content filtering' ' [6] Filtrado de contenido adulto');Write-Host (L ' [7] Profiles with DoH' ' [7] Perfiles con DoH');Write-Host (L ' [8] European profiles' ' [8] Perfiles europeos');Write-Host (' [N] '+(L 'Configure NextDNS profile' 'Configurar perfil NextDNS'));Write-Host (' [C] '+(T 'customDns'));Write-Host (' [B] '+(T 'back'))
        $c=(Read-Host (T 'select')).Trim().ToUpperInvariant();switch($c){'1'{Show-ProvidersAndChoose 'all'};'2'{Show-ProvidersAndChoose 'general'};'3'{Show-ProvidersAndChoose 'security'};'4'{Show-ProvidersAndChoose 'ads'};'5'{Show-ProvidersAndChoose 'family'};'6'{Show-ProvidersAndChoose 'adult'};'7'{Show-ProvidersAndChoose 'encrypted'};'8'{Show-ProvidersAndChoose 'europe'};'N'{Configure-NextDns};'C'{Apply-CustomDns};'B'{return}}
    }while($true)
}

function Normalize-Domain([string]$Raw){
    if([string]::IsNullOrWhiteSpace($Raw)){return $null};$s=$Raw.Trim();$s=$s -replace '^[a-zA-Z][a-zA-Z0-9+.-]*://','';$s=($s -split '[/?#]')[0];if($s.Contains('@')){$s=($s -split '@')[-1]};$s=$s.Trim().TrimEnd('.').ToLowerInvariant();if($s.Contains(':')){$s=($s -split ':')[0]};if($s.StartsWith('www.')){$s=$s.Substring(4)}
    try{$idn=New-Object Globalization.IdnMapping;$labels=@();foreach($label in $s.Split('.')){$labels+=$idn.GetAscii($label)};$s=$labels -join '.'}catch{return $null}
    if($s.Length -gt 253 -or $s -notmatch '^(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])$'){return $null};$ip=$null;if([Net.IPAddress]::TryParse($s,[ref]$ip)){return $null};return $s
}
function Get-HostsPath{return (Join-Path $env:SystemRoot 'System32\drivers\etc\hosts')}
function Backup-HostsFile{$p=Get-HostsPath;$dir=Get-StateFolder;$dest=Join-Path $dir ('hosts_backup_'+(Get-Date -Format 'yyyyMMdd_HHmmss_fff')+'.txt');Copy-Item -LiteralPath $p -Destination $dest -Force;Copy-Item -LiteralPath $p -Destination (Join-Path $dir 'last_hosts_backup.txt') -Force;return $dest}
function Get-ManagedDomains{
    $p=Get-HostsPath;if( -not (Test-Path $p)){return @()};$lines=[IO.File]::ReadAllLines($p,[Text.Encoding]::Default);$inside=$false;$out=@();foreach($line in $lines){if($line.Trim() -eq $script:HostsStart){$inside=$true;continue};if($line.Trim() -eq $script:HostsEnd){$inside=$false;continue};if($inside -and $line -match '^\s*0\.0\.0\.0\s+([^\s#]+)'){$h=$matches[1].ToLowerInvariant();if( -not $h.StartsWith('www.')){$out+=$h}}};return @($out|Sort-Object -Unique)
}
function Write-ManagedDomains([string[]]$Domains){
    $p=Get-HostsPath;$lines=[IO.File]::ReadAllLines($p,[Text.Encoding]::Default);$new=New-Object Collections.Generic.List[string];$inside=$false;foreach($line in $lines){if($line.Trim() -eq $script:HostsStart){$inside=$true;continue};if($line.Trim() -eq $script:HostsEnd){$inside=$false;continue};if( -not $inside){$new.Add($line)}}
    $clean=@($Domains|Where-Object{$_}|Sort-Object -Unique);if(@($clean).Count -gt 0){$new.Add('');$new.Add($script:HostsStart);$new.Add('# Entries below are managed by Portable DNS Manager.');foreach($d in $clean){$new.Add('0.0.0.0 '+$d);$new.Add('0.0.0.0 www.'+$d);$new.Add(':: '+$d);$new.Add(':: www.'+$d)};$new.Add($script:HostsEnd)}
    [IO.File]::WriteAllLines($p,$new.ToArray(),[Text.Encoding]::Default);Clear-DnsClientCache -ErrorAction SilentlyContinue
}
function Add-BlockedDomain{
    Show-Header;$raw=Read-Host (L 'Website/domain to block (example: instagram.com)' 'Sitio/dominio que deseas bloquear (ejemplo: instagram.com)');$d=Normalize-Domain $raw;if( -not $d){Write-Host (L 'That is not a valid website domain.' 'No es un dominio web válido.') -ForegroundColor Red;Pause-PDM;return};$domains=@(Get-ManagedDomains);if($domains -contains $d){Write-Host (L 'That domain is already managed as blocked.' 'Ese dominio ya está gestionado como bloqueado.') -ForegroundColor Yellow;Pause-PDM;return}
    Write-Host '';Write-Host (L 'This will add local hosts entries for:' 'Se añadirán entradas locales hosts para:');Write-Host ('  '+$d);Write-Host ('  www.'+$d);Write-Host (L 'It cannot automatically block every possible subdomain, app endpoint, VPN/proxy or browser-specific bypass.' 'No puede bloquear automáticamente todos los subdominios, endpoints de aplicaciones, VPN/proxy o evasiones específicas del navegador.') -ForegroundColor DarkYellow;$a=(Read-Host (L 'Continue? [Y/N]' '¿Continuar? [S/N]')).Trim().ToUpperInvariant();if(@('Y','YES','S','SI','SÍ') -notcontains $a){return};$backup=Backup-HostsFile;Write-ManagedDomains @($domains+$d);Write-Host '';Write-Host ('OK: '+$d) -ForegroundColor Green;Write-Host ((L 'Hosts backup: ' 'Copia de hosts: ')+$backup);Pause-PDM
}
function Remove-BlockedDomain{
    $domains=@(Get-ManagedDomains);Show-Header;if(@($domains).Count -eq 0){Write-Host (L 'No domains are currently managed by Portable DNS Manager.' 'No hay dominios gestionados actualmente por Portable DNS Manager.');Pause-PDM;return};Write-Host (L 'MANAGED BLOCKED DOMAINS' 'DOMINIOS BLOQUEADOS GESTIONADOS') -ForegroundColor Cyan;for($i=0;$i -lt @($domains).Count;$i++){Write-Host (' [{0}] {1}' -f ($i+1),$domains[$i])};Write-Host (' [B] '+(T 'back'));$c=(Read-Host (T 'select')).Trim();if($c -eq 'B'){return};$n=0;if([int]::TryParse($c,[ref]$n) -and $n -ge 1 -and $n -le @($domains).Count){$backup=Backup-HostsFile;$target=$domains[$n-1];$remaining=@($domains|Where-Object{$_ -ne $target});Write-ManagedDomains $remaining;Write-Host '';Write-Host ((L 'Unblocked: ' 'Desbloqueado: ')+$target) -ForegroundColor Green;Write-Host ((L 'Hosts backup: ' 'Copia de hosts: ')+$backup);Pause-PDM}
}
function List-BlockedDomains{Show-Header;$domains=@(Get-ManagedDomains);Write-Host (L 'MANAGED BLOCKED DOMAINS' 'DOMINIOS BLOQUEADOS GESTIONADOS') -ForegroundColor Cyan;Write-Host '';if(@($domains).Count -gt 0){foreach($d in $domains){Write-Host (' - '+$d)}}else{Write-Host (L 'None.' 'Ninguno.')};Write-Host '';Write-Host (L 'Only the marked Portable DNS Manager section of the Windows hosts file is managed; other hosts entries are preserved.' 'Solo se gestiona la sección marcada de Portable DNS Manager en el archivo hosts de Windows; las demás entradas se conservan.') -ForegroundColor DarkGray;Pause-PDM}
function Restore-HostsBackup{Show-Header;$last=Join-Path (Get-StateFolder) 'last_hosts_backup.txt';if( -not (Test-Path $last)){Write-Host (L 'No hosts backup is available.' 'No hay una copia de hosts disponible.') -ForegroundColor Yellow;Pause-PDM;return};$a=(Read-Host (L 'Restore the last hosts backup? This may undo the latest hosts change. [Y/N]' '¿Restaurar la última copia de hosts? Esto puede deshacer el último cambio de hosts. [S/N]')).Trim().ToUpperInvariant();if(@('Y','YES','S','SI','SÍ') -contains $a){Copy-Item -LiteralPath $last -Destination (Get-HostsPath) -Force;Clear-DnsClientCache -ErrorAction SilentlyContinue;Write-Host (L 'Hosts file restored.' 'Archivo hosts restaurado.') -ForegroundColor Green;Pause-PDM}}
function Domain-BlockerMenu{
    do{Show-Header;Write-Host (L 'LOCAL DOMAIN BLOCKER' 'BLOQUEO LOCAL DE DOMINIOS') -ForegroundColor Cyan;Write-Host (L 'Simple local blocking through the Windows hosts file. This is useful for specific domains but is not a tamper-proof parental-control system.' 'Bloqueo local sencillo mediante el archivo hosts de Windows. Es útil para dominios concretos, pero no es un control parental resistente a manipulaciones.') -ForegroundColor DarkGray;Write-Host '';Write-Host (L ' [1] Block a website/domain' ' [1] Bloquear un sitio/dominio');Write-Host (L ' [2] Unblock a managed domain' ' [2] Desbloquear un dominio gestionado');Write-Host (L ' [3] List managed blocked domains' ' [3] Ver dominios bloqueados gestionados');Write-Host (L ' [4] Restore last hosts backup' ' [4] Restaurar última copia de hosts');Write-Host (' [B] '+(T 'back'));$c=(Read-Host (T 'select')).Trim().ToUpperInvariant();switch($c){'1'{Add-BlockedDomain};'2'{Remove-BlockedDomain};'3'{List-BlockedDomains};'4'{Restore-HostsBackup};'B'{return}}}while($true)
}

function Show-SimpleRecommendations([string]$Goal){
    switch($Goal){
        'general'{Show-ProvidersAndChoose 'general'};'security'{Show-ProvidersAndChoose 'security'};'ads'{Show-ProvidersAndChoose 'ads'};'adult'{Show-ProvidersAndChoose 'adult'};'family'{do{Show-Header;Write-Host (L 'FAMILY PROTECTION' 'PROTECCIÓN FAMILIAR') -ForegroundColor Cyan;Write-Host '';Write-Host (L ' [1] Choose a family DNS profile' ' [1] Elegir un perfil DNS familiar');Write-Host (L ' [2] Compare key family profiles' ' [2] Comparar perfiles familiares principales');Write-Host (L ' [3] Local domain blocker (add specific sites)' ' [3] Bloqueo local (añadir sitios concretos)');Write-Host (' [B] '+(T 'back'));$c=(Read-Host (T 'select')).Trim().ToUpperInvariant();switch($c){'1'{Show-ProvidersAndChoose 'family'};'2'{Show-FamilyComparison};'3'{Domain-BlockerMenu};'B'{return}}}while($true)}
    }
}

function Help-Me-Choose{
    Show-Header;Write-Host (L 'HELP ME CHOOSE' 'AYÚDAME A ELEGIR') -ForegroundColor Cyan;Write-Host '';Write-Host (L 'Pick the goal that matters most. You can always change it later.' 'Elige el objetivo que más te importa. Siempre puedes cambiarlo después.');Write-Host '';Write-Host (L ' [1] Everyday use without content filtering' ' [1] Uso diario sin filtrado de contenido');Write-Host (L ' [2] Stronger protection against malicious domains' ' [2] Más protección contra dominios maliciosos');Write-Host (L ' [3] Reduce ads and tracking' ' [3] Reducir publicidad y rastreo');Write-Host (L ' [4] Protect children / family filtering' ' [4] Proteger a menores / filtrado familiar');Write-Host (L ' [5] Primarily block adult content' ' [5] Principalmente bloquear contenido adulto');Write-Host (L ' [6] Find the lowest DNS-query latency for general profiles' ' [6] Buscar la menor latencia DNS entre perfiles generales');Write-Host (' [B] '+(T 'back'));$c=(Read-Host (T 'select')).Trim().ToUpperInvariant();switch($c){'1'{Show-SimpleRecommendations 'general'};'2'{Show-SimpleRecommendations 'security'};'3'{Show-SimpleRecommendations 'ads'};'4'{Show-SimpleRecommendations 'family'};'5'{Show-SimpleRecommendations 'adult'};'6'{Run-Benchmark 'general'}}
}

# ---------------------------------------------------------------------------
# Menus
# ---------------------------------------------------------------------------
function Choose-Language {
    Show-Header;Write-Host (L 'LANGUAGE / IDIOMA' 'IDIOMA / LANGUAGE') -ForegroundColor Cyan;Write-Host '';Write-Host ' [1] English';Write-Host ' [2] Español';Write-Host (' [B] '+(T 'back'));$c=(Read-Host (T 'select')).Trim().ToUpperInvariant();if($c -eq '1'){$script:Lang='en'}elseif($c -eq '2'){$script:Lang='es'}
}

function Simple-Menu {
    do{Show-Header;Write-Host ('                     '+(T 'simpleTitle')) -ForegroundColor Green;Write-SubLine;Write-Host (L 'WHAT DO YOU WANT TO ACHIEVE?' '¿QUÉ QUIERES CONSEGUIR?');Write-Host ''
        Write-Host (L ' [1] GENERAL USE            Stable DNS without category filtering' ' [1] USO NORMAL             DNS estable sin filtrado por categorías');Write-Host (L ' [2] MORE SECURITY          Malware / phishing / malicious domains' ' [2] MÁS SEGURIDAD           Malware / phishing / dominios maliciosos');Write-Host (L ' [3] LESS ADS & TRACKING    Filtering-oriented profiles' ' [3] MENOS PUBLICIDAD        Perfiles orientados a anuncios/rastreo');Write-Host (L ' [4] FAMILY PROTECTION      Choose child-oriented filtering profiles' ' [4] PROTECCIÓN FAMILIAR     Elegir perfiles de filtrado para menores');Write-Host (L ' [5] COMPARE FAMILY DNS     See what the main family profiles protect' ' [5] COMPARAR DNS FAMILIAR   Ver qué protege cada perfil familiar');Write-Host (L ' [6] BLOCK ADULT CONTENT    Adult-focused filtering choices' ' [6] BLOQUEAR ADULTOS        Opciones centradas en contenido adulto');Write-Host (L ' [7] CHOOSE A DNS           Browse the complete catalog with filters' ' [7] ELEGIR UN DNS           Catálogo completo con filtros');Write-Host ''
        Write-Host (L ' [8] Public IP / region / VPN indicators' ' [8] IP pública / región / indicadores VPN');Write-Host (L ' [9] Block / unblock a specific website locally' ' [9] Bloquear / desbloquear un sitio concreto localmente');Write-Host (L '[10] Restore previous DNS configuration' '[10] Restaurar configuración DNS anterior');Write-Host (L '[11] Reset DNS to Automatic / DHCP' '[11] Restaurar DNS Automático / DHCP');Write-Host '';Write-Host (L ' [?] Help me choose' ' [?] Ayúdame a elegir');Write-Host (L ' [H] Quick guide' ' [H] Mini guía');Write-Host (L ' [D] Documentation / GitHub' ' [D] Documentación / GitHub');Write-Host (L ' [A] Advanced Mode' ' [A] Modo Avanzado');Write-Host (' [0] '+(T 'exit'));Write-Host ''
        $c=(Read-Host (T 'select')).Trim().ToUpperInvariant();try{switch($c){'1'{Show-SimpleRecommendations 'general'};'2'{Show-SimpleRecommendations 'security'};'3'{Show-SimpleRecommendations 'ads'};'4'{Show-SimpleRecommendations 'family'};'5'{Show-FamilyComparison};'6'{Show-SimpleRecommendations 'adult'};'7'{Provider-FilterMenu};'8'{Show-PublicIpVpn};'9'{Domain-BlockerMenu};'10'{Restore-PreviousDns};'11'{Reset-DnsAutomatic};'?' {Help-Me-Choose};'H'{Show-QuickGuide};'D'{Show-Documentation};'A'{if( -not (Advanced-Menu)){return $false}};'0'{return $false};default{Write-Host (T 'invalid') -ForegroundColor Yellow;Start-Sleep -Milliseconds 600}}}catch{Write-Host ((T 'failed')+': '+$_.Exception.Message) -ForegroundColor Red;Pause-PDM}
    }while($true)
}

function Advanced-Menu {
    do{Show-Header;Write-Host ('                    '+(T 'advancedTitle')) -ForegroundColor Cyan;Write-Host (T 'advancedNote') -ForegroundColor DarkGray;Write-Host ''
        Write-Host (' '+(T 'config')) -ForegroundColor Cyan;Write-Host (L ' [1] DNS catalog / filters / apply profile' ' [1] Catálogo DNS / filtros / aplicar perfil');Write-Host (' [2] '+(T 'customDns'));Write-Host (L ' [3] Configure NextDNS custom profile' ' [3] Configurar perfil NextDNS personalizado');Write-Host (' [4] '+(T 'selectInterface'));Write-Host (' [5] '+(T 'dohPolicy'));Write-Host ''
        Write-Host (' '+(T 'diagnostics')) -ForegroundColor Cyan;Write-Host (' [6] '+(T 'benchmark'));Write-Host (' [7] '+(T 'testCurrent'));Write-Host (' [8] '+(T 'showFull'));Write-Host (' [9] '+(T 'flush'));Write-Host ''
        Write-Host (' '+(T 'networkPrivacy')) -ForegroundColor Cyan;Write-Host ('[10] '+(T 'interfaceInfo'));Write-Host ('[11] '+(T 'connectionDiag'));Write-Host ''
        Write-Host (L ' LOCAL CONTROL' ' CONTROL LOCAL') -ForegroundColor Cyan;Write-Host (L '[12] Local domain blocker / hosts manager' '[12] Bloqueo local de dominios / gestor hosts');Write-Host ''
        Write-Host (' '+(T 'restoration')) -ForegroundColor Cyan;Write-Host ('[13] '+(T 'restorePrevious'));Write-Host ('[14] '+(T 'resetAuto'));Write-Host ''
        Write-Host (L '[15] Family-filter comparison' '[15] Comparativa de filtrado familiar');Write-Host (L '[16] Quick guide' '[16] Mini guía');Write-Host (L '[17] Documentation / GitHub' '[17] Documentación / GitHub');Write-Host ('[18] '+(T 'languageChange'));Write-Host (' [B] '+(T 'back'));Write-Host (' [0] '+(T 'exit'));Write-Host ''
        $c=(Read-Host (T 'select')).Trim().ToUpperInvariant();try{switch($c){'1'{Provider-FilterMenu};'2'{Apply-CustomDns};'3'{Configure-NextDns};'4'{Select-NetworkInterface};'5'{Select-DoHPolicy};'6'{Run-Benchmark 'ask'};'7'{Test-CurrentDns};'8'{Show-FullConfiguration};'9'{Clear-DnsClientCache -ErrorAction Stop;Write-Host '';Write-Host (T 'cacheDone') -ForegroundColor Green;Pause-PDM};'10'{Show-InterfaceInfo};'11'{Show-PublicIpVpn};'12'{Domain-BlockerMenu};'13'{Restore-PreviousDns};'14'{Reset-DnsAutomatic};'15'{Show-FamilyComparison};'16'{Show-QuickGuide};'17'{Show-Documentation};'18'{Choose-Language};'B'{return $true};'0'{return $false};default{Write-Host (T 'invalid') -ForegroundColor Yellow;Start-Sleep -Milliseconds 600}}}catch{Write-Host ((T 'failed')+': '+$_.Exception.Message) -ForegroundColor Red;Pause-PDM}
    }while($true)
}

function Mode-Menu {
    do{Show-Header;Write-Host (T 'chooseMode');Write-Host '';Write-Host (' [1] '+(T 'simple')) -ForegroundColor Green;Write-Host ('     '+(L 'Goal-based menus for everyday users.' 'Menús por objetivos para usuarios cotidianos.'));Write-Host '';Write-Host (' [2] '+(T 'advanced')) -ForegroundColor Cyan;Write-Host ('     '+(T 'advancedDesc'));Write-Host '';Write-Host (L ' [3] Public IP / region / VPN indicators' ' [3] IP pública / región / indicadores VPN');Write-Host (L ' [4] Local website/domain blocker' ' [4] Bloqueo local de sitios/dominios');Write-Host (L ' [5] Compare family DNS protection' ' [5] Comparar protección DNS familiar');Write-Host '';Write-Host (L ' [H] Quick guide' ' [H] Mini guía');Write-Host (L ' [D] Documentation / GitHub' ' [D] Documentación / GitHub');Write-Host (' [0] '+(T 'exit'));Write-Host ''; $c=(Read-Host (T 'select')).Trim().ToUpperInvariant();try{switch($c){'1'{if( -not (Simple-Menu)){return}};'2'{if( -not (Advanced-Menu)){return}};'3'{Show-PublicIpVpn};'4'{Domain-BlockerMenu};'5'{Show-FamilyComparison};'H'{Show-QuickGuide};'D'{Show-Documentation};'0'{return}}}catch{Write-Host ((T 'failed')+': '+$_.Exception.Message) -ForegroundColor Red;Pause-PDM}}while($true)
}
# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
try {
    Mode-Menu
    exit 0
} catch {
    Write-Host ''
    Write-Host ('FATAL: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    Pause-PDM
    exit 1
}
