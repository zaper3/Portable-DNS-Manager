#!/usr/bin/env bash
# Portable DNS Manager v1.0.0 - GNU/Linux
# NetworkManager edition. No packages, services, proxies or daemons are installed.
# Copyright (c) 2026 zaper3.
set -u

VERSION="1.0.0"
LANG_UI="en"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/portable-dns-manager"
BACKUP_FILE="$STATE_DIR/last_dns_backup.tsv"
HOSTS_BACKUP="$STATE_DIR/last_hosts_backup.txt"
EXTERNAL_NOTICE=0
REPO_URL="https://github.com/zaper3/Portable-DNS-Manager"
HOSTS_START="# >>> Portable DNS Manager managed block >>>"
HOSTS_END="# <<< Portable DNS Manager managed block <<<"

PROVIDERS=(
"cloudflare|Cloudflare Standard|standard|1.1.1.1 1.0.0.1|2606:4700:4700::1111 2606:4700:4700::1001|https://cloudflare-dns.com/dns-query|0|general,privacy,encrypted|General-purpose resolver with no content filtering.|Resolvedor de uso general sin filtrado de contenido."
"cloudflare_malware|Cloudflare Malware Protection|security|1.1.1.2 1.0.0.2|2606:4700:4700::1112 2606:4700:4700::1002|https://security.cloudflare-dns.com/dns-query|0|security,encrypted|Blocks known malware and phishing domains.|Bloquea dominios conocidos de malware y phishing."
"cloudflare_family|Cloudflare Family|family|1.1.1.3 1.0.0.3|2606:4700:4700::1113 2606:4700:4700::1003|https://family.cloudflare-dns.com/dns-query|0|family,adult,security,encrypted|Blocks malware, phishing and adult content.|Bloquea malware, phishing y contenido adulto."
"google|Google Public DNS|standard|8.8.8.8 8.8.4.4|2001:4860:4860::8888 2001:4860:4860::8844|https://dns.google/dns-query|0|general,encrypted|Global public DNS resolver with no category filtering.|Resolvedor DNS público global sin filtrado por categorías."
"opendns|Cisco OpenDNS / Umbrella|standard|208.67.222.222 208.67.220.220|2620:119:35::35 2620:119:53::53|https://dns.opendns.com/dns-query|0|general,security,encrypted|Public Cisco OpenDNS/Umbrella resolver; custom policy features require an account.|Resolvedor público Cisco OpenDNS/Umbrella; las políticas personalizadas requieren cuenta."
"opendns_family|OpenDNS FamilyShield|family|208.67.222.123 208.67.220.123|2620:119:35::123 2620:119:53::123|https://familyshield.opendns.com/dns-query|0|family,adult,encrypted|FamilyShield preset for adult-content blocking.|Perfil FamilyShield para bloquear contenido adulto."
"quad9_secure|Quad9 Secure|security|9.9.9.9 149.112.112.112|2620:fe::fe 2620:fe::9|https://dns.quad9.net/dns-query|0|security,privacy,encrypted|Privacy-oriented resolver with threat blocking.|Resolvedor orientado a privacidad con bloqueo de amenazas."
"quad9_secure_ecs|Quad9 Secure + ECS|security|9.9.9.11 149.112.112.11|2620:fe::11 2620:fe::fe:11|https://dns11.quad9.net/dns-query|0|security,encrypted,ecs|Threat blocking with ECS for CDN routing in networks where it helps.|Bloqueo de amenazas con ECS para mejorar el enrutamiento CDN donde resulte útil."
"quad9_unfiltered|Quad9 Unfiltered|standard|9.9.9.10 149.112.112.10|2620:fe::10 2620:fe::fe:10|https://dns10.quad9.net/dns-query|0|general,privacy,encrypted|Privacy-oriented Quad9 resolution without threat blocking.|Resolución Quad9 orientada a privacidad sin bloqueo de amenazas."
"quad9_unfiltered_ecs|Quad9 Unfiltered + ECS|standard|9.9.9.12 149.112.112.12|2620:fe::12 2620:fe::fe:12|https://dns12.quad9.net/dns-query|0|general,encrypted,ecs|Unfiltered Quad9 resolution with ECS.|Resolución Quad9 sin filtrado con ECS."
"yandex_basic|Yandex DNS Basic|standard|77.88.8.8 77.88.8.1|2a02:6b8::feed:0ff 2a02:6b8:0:1::feed:0ff|https://common.dot.dns.yandex.net/dns-query|0|general,encrypted|Yandex general-purpose DNS mode.|Modo DNS de uso general de Yandex."
"yandex_safe|Yandex DNS Safe|security|77.88.8.88 77.88.8.2|2a02:6b8::feed:bad 2a02:6b8:0:1::feed:bad|https://safe.dot.dns.yandex.net/dns-query|0|security,encrypted|Blocks dangerous and fraudulent websites and botnet infrastructure.|Bloquea sitios peligrosos y fraudulentos e infraestructura de botnets."
"yandex_family|Yandex DNS Family|family|77.88.8.7 77.88.8.3|2a02:6b8::feed:a11 2a02:6b8:0:1::feed:a11|https://family.dot.dns.yandex.net/dns-query|0|family,adult,security,encrypted|Adds adult-content filtering and Yandex family search to security protections.|Añade filtrado de contenido adulto y búsqueda familiar de Yandex a las protecciones de seguridad."
"adguard_default|AdGuard DNS Default|adblock|94.140.14.14 94.140.15.15|2a10:50c0::ad1:ff 2a10:50c0::ad2:ff|https://dns.adguard-dns.com/dns-query|0|ads,tracking,security,encrypted|Blocks ads and trackers; AdGuard also documents malware and phishing protection.|Bloquea anuncios y rastreadores; AdGuard también documenta protección contra malware y phishing."
"adguard_unfiltered|AdGuard DNS Unfiltered|standard|94.140.14.140 94.140.14.141|2a10:50c0::1:ff 2a10:50c0::2:ff|https://unfiltered.adguard-dns.com/dns-query|0|general,encrypted|AdGuard resolver without content filtering.|Resolvedor AdGuard sin filtrado de contenido."
"adguard_family|AdGuard DNS Family|family|94.140.14.15 94.140.15.16|2a10:50c0::bad1:ff 2a10:50c0::bad2:ff|https://family.adguard-dns.com/dns-query|0|family,adult,ads,tracking,security,encrypted|Blocks ads, trackers, adult content and enables Safe Search/Safe Mode where possible.|Bloquea anuncios, rastreadores y contenido adulto, y activa Búsqueda Segura/Modo Seguro cuando es posible."
"clean_security|CleanBrowsing Security|security|185.228.168.9 185.228.169.9|2a0d:2a00:1::2 2a0d:2a00:2::2|https://doh.cleanbrowsing.org/doh/security-filter/|0|security,encrypted|Blocks phishing, spam, malware and malicious domains; does not block adult content.|Bloquea phishing, spam, malware y dominios maliciosos; no bloquea contenido adulto."
"clean_adult|CleanBrowsing Adult|adult|185.228.168.10 185.228.169.11|2a0d:2a00:1::1 2a0d:2a00:2::1|https://doh.cleanbrowsing.org/doh/adult-filter/|0|adult,family,security,encrypted|Blocks adult content plus malware/phishing and enables SafeSearch for Google/Bing.|Bloquea contenido adulto además de malware/phishing y activa SafeSearch en Google/Bing."
"clean_family|CleanBrowsing Family|family|185.228.168.168 185.228.169.168|2a0d:2a00:1:: 2a0d:2a00:2::|https://doh.cleanbrowsing.org/doh/family-filter/|0|family,adult,security,encrypted,strict|Strict family filter: adult content, mixed-content sites and known proxy/VPN bypass domains, plus SafeSearch.|Filtro familiar estricto: contenido adulto, sitios de contenido mixto y dominios proxy/VPN usados para evadir filtros, además de SafeSearch."
"dns4eu_protective|DNS4EU Protective|security|86.54.11.1 86.54.11.201|2a13:1001::86:54:11:1 2a13:1001::86:54:11:201|https://protective.joindns4.eu/dns-query|0|security,europe,encrypted|European protective resolver against fraudulent or malicious websites.|Resolvedor protector europeo frente a sitios fraudulentos o maliciosos."
"dns4eu_child|DNS4EU Protective + Child|family|86.54.11.12 86.54.11.212|2a13:1001::86:54:11:12 2a13:1001::86:54:11:212|https://child.joindns4.eu/dns-query|0|family,adult,security,europe,encrypted|Protective DNS plus child-inappropriate content such as explicit content, violence or drugs.|DNS protector más contenido inapropiado para menores como contenido explícito, violencia o drogas."
"dns4eu_ads|DNS4EU Protective + Ads|adblock|86.54.11.13 86.54.11.213|2a13:1001::86:54:11:13 2a13:1001::86:54:11:213|https://noads.joindns4.eu/dns-query|0|ads,security,europe,encrypted|Protective resolver plus website and in-app ad blocking.|Resolvedor protector más bloqueo de anuncios en webs y aplicaciones."
"dns4eu_child_ads|DNS4EU Child + Ads|family|86.54.11.11 86.54.11.211|2a13:1001::86:54:11:11 2a13:1001::86:54:11:211|https://child-noads.joindns4.eu/dns-query|0|family,adult,ads,security,europe,encrypted|Combines protective DNS, child-content filtering and ad blocking.|Combina DNS protector, filtrado de contenido infantil y bloqueo de anuncios."
"dns4eu_unfiltered|DNS4EU Unfiltered|standard|86.54.11.100 86.54.11.200|2a13:1001::86:54:11:100 2a13:1001::86:54:11:200|https://unfiltered.joindns4.eu/dns-query|0|general,privacy,europe,encrypted|European unfiltered resolver focused on reliable anonymised resolution.|Resolvedor europeo sin filtrado orientado a resolución fiable y anonimizada."
"controld_unfiltered|Control D Unfiltered|standard|76.76.2.0 76.76.10.0|2606:1a40::0 2606:1a40:1::0|https://freedns.controld.com/p0|0|general,encrypted|Control D free unfiltered community resolver.|Resolvedor comunitario gratuito de Control D sin filtrado."
"controld_malware|Control D Malware|security|76.76.2.1 76.76.10.1|2606:1a40::1 2606:1a40:1::1|https://freedns.controld.com/p1|0|security,encrypted|Control D free malware-filtering preset.|Perfil gratuito de Control D para filtrado de malware."
"controld_ads|Control D Ads & Tracking|adblock|76.76.2.2 76.76.10.2|2606:1a40::2 2606:1a40:1::2|https://freedns.controld.com/p2|0|ads,tracking,encrypted|Control D free ads and tracking preset.|Perfil gratuito de Control D para anuncios y rastreo."
"controld_social|Control D Social|special|76.76.2.3 76.76.10.3|2606:1a40::3 2606:1a40:1::3|https://freedns.controld.com/p3|0|social,encrypted|Control D preset focused on social-network blocking.|Perfil de Control D orientado al bloqueo de redes sociales."
"controld_family|Control D Family Friendly|family|76.76.2.4 76.76.10.4|2606:1a40::4 2606:1a40:1::4|https://freedns.controld.com/family|0|family,encrypted|Control D free family-friendly preset.|Perfil familiar gratuito de Control D."
"controld_uncensored|Control D Uncensored|standard|76.76.2.5 76.76.10.5|2606:1a40::5 2606:1a40:1::5|https://freedns.controld.com/uncensored|0|general,uncensored,encrypted|Control D free uncensored preset.|Perfil gratuito sin censura de Control D."
"vercara_unfiltered|Vercara UltraDNS Unfiltered|standard|64.6.64.6 64.6.65.6|2620:74:1b::1:1 2620:74:1c::2:2||0|general|UltraDNS Public unfiltered resolution.|Resolución pública UltraDNS sin filtrado."
"vercara_threat|Vercara UltraDNS Threat Protection|security|156.154.70.2 156.154.71.2|2610:a1:1018::2 2610:a1:1019::2||0|security|Blocks malicious domains including malware and phishing.|Bloquea dominios maliciosos, incluidos malware y phishing."
"vercara_family|Vercara UltraDNS Family Secure|family|156.154.70.3 156.154.71.3|2610:a1:1018::3 2610:a1:1019::3||0|family,adult,security|Threat protection plus gambling, pornography, violence and hate/discrimination categories.|Protección contra amenazas más categorías de apuestas, pornografía, violencia y odio/discriminación."
"oracle_dyn|Oracle OCI / Dyn Recursive DNS|standard|216.146.35.35 216.146.36.36|||0|general|Free validating recursive DNS service provided by Oracle OCI.|Servicio DNS recursivo de validación gratuito de Oracle OCI."
"hurricane|Hurricane Electric Public Recursor|standard|74.82.42.42|2001:470:20::2|https://ordns.he.net/dns-query|0|general,encrypted|Hurricane Electric anycast public recursor.|Resolvedor público anycast de Hurricane Electric."
"comodo|Comodo Secure DNS|security|8.26.56.26 8.20.247.20|||0|security|Comodo public Secure DNS resolver.|Resolvedor público Secure DNS de Comodo."
"safedns|SafeDNS Service Resolvers|special|195.46.39.39 195.46.39.40|2001:67c:2778::3939 2001:67c:2778::3940||0|account,family,security|SafeDNS service addresses; filtering policies can depend on account/network registration.|Direcciones del servicio SafeDNS; las políticas de filtrado pueden depender del registro de cuenta/red."
"mullvad_plain|Mullvad Encrypted DNS - Unfiltered|encrypted|194.242.2.2|2a07:e340::2|https://dns.mullvad.net/dns-query|1|general,privacy,encrypted-only|Encrypted DNS only; no content blocking.|Solo DNS cifrado; sin bloqueo de contenido."
"mullvad_adblock|Mullvad Encrypted DNS - Ads & Trackers|encrypted|194.242.2.3|2a07:e340::3|https://adblock.dns.mullvad.net/dns-query|1|ads,tracking,encrypted-only|Encrypted-only profile blocking ads and trackers.|Perfil solo cifrado que bloquea anuncios y rastreadores."
"mullvad_base|Mullvad Encrypted DNS - Base|encrypted|194.242.2.4|2a07:e340::4|https://base.dns.mullvad.net/dns-query|1|ads,tracking,security,encrypted-only|Encrypted-only profile blocking ads, trackers and malware.|Perfil solo cifrado que bloquea anuncios, rastreadores y malware."
"mullvad_extended|Mullvad Encrypted DNS - Extended|encrypted|194.242.2.5|2a07:e340::5|https://extended.dns.mullvad.net/dns-query|1|ads,tracking,security,social,encrypted-only|Base filtering plus social-media blocking.|Filtrado Base más bloqueo de redes sociales."
"mullvad_family|Mullvad Encrypted DNS - Family|encrypted|194.242.2.6|2a07:e340::6|https://family.dns.mullvad.net/dns-query|1|family,adult,ads,security,encrypted-only|Encrypted-only family profile: ads, trackers, malware, adult content and gambling.|Perfil familiar solo cifrado: anuncios, rastreadores, malware, contenido adulto y apuestas."
"mullvad_all|Mullvad Encrypted DNS - All|encrypted|194.242.2.9|2a07:e340::9|https://all.dns.mullvad.net/dns-query|1|family,adult,ads,security,social,encrypted-only|Mullvad broadest encrypted-only blocking profile.|Perfil solo cifrado con el filtrado más amplio de Mullvad."
)

trp() {
  local k="$1"
  if [[ "$LANG_UI" == es ]]; then
    case "$k" in
      select) echo "Selecciona una opción";; back) echo "Volver";; exit) echo "Salir";;
      current_interface) echo "Interfaz actual";; current_dns) echo "DNS actual";; dns_mode) echo "Modo DNS";;
      auto) echo "Automático";; manual) echo "Manual";; press) echo "Pulsa ENTER para continuar";;
      simple) echo "MODO SIMPLE";; advanced) echo "MODO AVANZADO";; invalid) echo "Opción no válida";;
      public_ip) echo "IP pública / región / VPN";; blocker) echo "Bloqueo local de sitios/dominios";;
      family_compare) echo "Comparar protección DNS familiar";; restore) echo "Restaurar DNS anterior";;
      reset) echo "Restaurar DNS Automático / DHCP";; catalog) echo "Catálogo DNS";;
      benchmark) echo "Probar proveedores DNS";; interfaces) echo "Información de interfaces";;
      quick) echo "Mini guía";; docs) echo "Documentación / GitHub";;
      *) echo "$k";;
    esac
  else
    case "$k" in
      select) echo "Select an option";; back) echo "Back";; exit) echo "Exit";;
      current_interface) echo "Current interface";; current_dns) echo "Current DNS";; dns_mode) echo "DNS mode";;
      auto) echo "Automatic";; manual) echo "Manual";; press) echo "Press ENTER to continue";;
      simple) echo "SIMPLE MODE";; advanced) echo "ADVANCED MODE";; invalid) echo "Invalid option";;
      public_ip) echo "Public IP / region / VPN";; blocker) echo "Local website/domain blocker";;
      family_compare) echo "Compare family DNS protection";; restore) echo "Restore previous DNS";;
      reset) echo "Reset DNS to Automatic / DHCP";; catalog) echo "DNS catalog";;
      benchmark) echo "Test DNS providers";; interfaces) echo "Interface information";;
      quick) echo "Quick guide";; docs) echo "Documentation / GitHub";;
      *) echo "$k";;
    esac
  fi
}

pause_pdm(){ echo; read -r -p "$(trp press): " _; }
line(){ printf '%*s\n' 72 '' | tr ' ' '='; }
subline(){ printf '%*s\n' 72 '' | tr ' ' '-'; }
need_cmd(){ command -v "$1" >/dev/null 2>&1; }
ensure_state(){ mkdir -p "$STATE_DIR"; chmod 700 "$STATE_DIR" 2>/dev/null || true; }
sudo_ok(){ [[ $EUID -eq 0 ]] || sudo -v; }

active_dev(){
  local d=""
  if need_cmd ip; then d="$(ip route show default 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')"; fi
  if [[ -z "$d" ]] && need_cmd nmcli; then d="$(nmcli -t -f DEVICE,STATE device status 2>/dev/null | awk -F: '$2=="connected" && $1!="lo"{print $1;exit}')"; fi
  printf '%s' "$d"
}
active_conn(){
  local d; d="$(active_dev)"
  [[ -z "$d" || ! $(command -v nmcli 2>/dev/null) ]] && return 1
  nmcli -g GENERAL.CONNECTION device show "$d" 2>/dev/null | head -n1
}
current_dns(){
  local d; d="$(active_dev)"
  if need_cmd resolvectl && [[ -n "$d" ]]; then
    resolvectl dns "$d" 2>/dev/null | sed 's/^[^:]*:[[:space:]]*//' | head -n1
  elif need_cmd nmcli && [[ -n "$d" ]]; then
    nmcli -g IP4.DNS,IP6.DNS device show "$d" 2>/dev/null | sed '/^$/d' | paste -sd' ' -
  else
    awk '/^nameserver/{printf "%s ",$2}' /etc/resolv.conf 2>/dev/null
  fi
}
dns_mode(){
  local c v
  c="$(active_conn 2>/dev/null || true)"
  [[ -z "$c" ]] && { trp auto; return; }
  v="$(nmcli -g ipv4.ignore-auto-dns con show "$c" 2>/dev/null || true)"
  [[ "$v" == yes ]] && trp manual || trp auto
}

header(){
  clear 2>/dev/null || true
  line
  printf '                  PORTABLE DNS MANAGER v%s\n' "$VERSION"
  line
  [[ "$LANG_UI" == es ]] && {
    echo " Catálogo DNS revisado: Agosto 2026"
    echo " Sin telemetría - Diagnósticos externos solo bajo solicitud"
  } || {
    echo " DNS catalog reviewed: August 2026"
    echo " No telemetry - External diagnostics only on request"
  }
  echo
  printf ' %-22s: %s\n' "$(trp current_interface)" "$(active_dev || true)"
  printf ' %-22s: %s\n' "$(trp current_dns)" "$(current_dns)"
  printf ' %-22s: %s\n' "$(trp dns_mode)" "$(dns_mode)"
  echo
}

choose_language(){
  while true; do
    clear 2>/dev/null || true; line
    echo "                    PORTABLE DNS MANAGER v$VERSION"; line; echo
    echo "              DNS catalog reviewed: August 2026"
    echo "              Catálogo DNS revisado: Agosto 2026"; echo
    echo "                     Language / Idioma"; echo
    echo "                     [1] English"
    echo "                     [2] Español"
    echo "                     [0] Exit / Salir"; echo
    read -r -p "> " c
    case "$c" in 1) LANG_UI=en; return 0;; 2) LANG_UI=es; return 0;; 0) return 1;; esac
  done
}

get_provider_by_id(){
  local id="$1" row
  for row in "${PROVIDERS[@]}"; do
    IFS='|' read -r pid _ <<<"$row"
    [[ "$pid" == "$id" ]] && { printf '%s\n' "$row"; return 0; }
  done
  return 1
}
provider_matches(){
  local tags="$1" filter="$2"
  [[ "$filter" == all ]] && return 0
  [[ ",$tags," == *",$filter,"* ]]
}
show_provider_detail(){
  local row="$1" pid name cat p4 p6 doh enc tags sen ses
  IFS='|' read -r pid name cat p4 p6 doh enc tags sen ses <<<"$row"
  header; echo "$name"; subline
  [[ "$LANG_UI" == es ]] && echo "$ses" || echo "$sen"
  echo; echo "IPv4: ${p4:--}"; echo "IPv6: ${p6:--}"
  [[ -n "$doh" ]] && echo "DoH : $doh"
  if [[ "$enc" == 1 ]]; then
    echo
    [[ "$LANG_UI" == es ]] && echo "Nota: este perfil es solo cifrado y no se aplica desde la edición Linux v1.0.0." || echo "Note: this profile is encrypted-only and is not applied by the Linux v1.0.0 edition."
  elif [[ -n "$doh" ]]; then
    echo
    [[ "$LANG_UI" == es ]] && echo "Linux v1.0.0 aplica aquí DNS estándar. No instala proxies/daemons para DoH." || echo "Linux v1.0.0 applies standard DNS here. It does not install DoH proxies/daemons."
  fi
  pause_pdm
}

save_backup(){
  local c="$1"; ensure_state
  {
    printf 'connection\t%s\n' "$c"
    printf 'ipv4_ignore\t%s\n' "$(nmcli -g ipv4.ignore-auto-dns con show "$c" 2>/dev/null || true)"
    printf 'ipv4_dns\t%s\n' "$(nmcli -g ipv4.dns con show "$c" 2>/dev/null || true)"
    printf 'ipv6_ignore\t%s\n' "$(nmcli -g ipv6.ignore-auto-dns con show "$c" 2>/dev/null || true)"
    printf 'ipv6_dns\t%s\n' "$(nmcli -g ipv6.dns con show "$c" 2>/dev/null || true)"
  } >"$BACKUP_FILE"
  chmod 600 "$BACKUP_FILE" 2>/dev/null || true
}
need_nm(){
  if ! need_cmd nmcli; then
    [[ "$LANG_UI" == es ]] && echo "Para modificar DNS, Linux v1.0.0 requiere NetworkManager/nmcli. Las herramientas de diagnóstico siguen disponibles." || echo "To modify DNS, Linux v1.0.0 requires NetworkManager/nmcli. Diagnostic tools remain available."
    pause_pdm; return 1
  fi
}
apply_provider(){
  need_nm || return
  local row pid name cat p4 p6 doh enc tags sen ses c ans v6method
  row="$(get_provider_by_id "$1")" || return
  IFS='|' read -r pid name cat p4 p6 doh enc tags sen ses <<<"$row"
  if [[ "$enc" == 1 ]]; then
    header
    [[ "$LANG_UI" == es ]] && echo "Este perfil requiere DNS cifrado. La edición Linux v1.0.0 no instala un proxy/daemon DoH, por lo que no lo aplicará como DNS plano." || echo "This profile requires encrypted DNS. Linux v1.0.0 does not install a DoH proxy/daemon, so it will not apply it as plain DNS."
    pause_pdm; return
  fi
  c="$(active_conn 2>/dev/null || true)"
  [[ -z "$c" ]] && { echo "No active NetworkManager connection found."; pause_pdm; return; }
  header; echo "$name"; echo "DNS1 / DNS2: ${p4// / / }"; echo "IPv6: ${p6:--}"; echo
  [[ "$LANG_UI" == es ]] && read -r -p "¿Aplicar este perfil? [S/N] " ans || read -r -p "Apply this profile? [Y/N] " ans
  case "${ans^^}" in Y|YES|S|SI|SÍ) ;; *) return;; esac
  sudo_ok || return
  save_backup "$c"
  sudo nmcli con mod "$c" ipv4.ignore-auto-dns yes ipv4.dns "$p4" || { pause_pdm; return; }
  v6method="$(nmcli -g ipv6.method con show "$c" 2>/dev/null || true)"
  if [[ -n "$p6" && "$v6method" != disabled && "$v6method" != ignore ]]; then
    sudo nmcli con mod "$c" ipv6.ignore-auto-dns yes ipv6.dns "$p6" || true
  fi
  sudo nmcli con up "$c" >/dev/null || { echo "Failed to reactivate NetworkManager connection."; pause_pdm; return; }
  need_cmd resolvectl && sudo resolvectl flush-caches 2>/dev/null || true
  echo
  [[ "$LANG_UI" == es ]] && echo "Configuración DNS aplicada. Copia anterior: $BACKUP_FILE" || echo "DNS configuration applied. Previous settings: $BACKUP_FILE"
  getent ahostsv4 example.com >/dev/null 2>&1 && echo "DNS resolution: OK" || echo "DNS resolution: FAIL"
  pause_pdm
}
reset_auto(){
  need_nm || return
  local c; c="$(active_conn 2>/dev/null || true)"; [[ -z "$c" ]] && return
  sudo_ok || return; save_backup "$c"
  sudo nmcli con mod "$c" ipv4.ignore-auto-dns no ipv4.dns '' || return
  sudo nmcli con mod "$c" ipv6.ignore-auto-dns no ipv6.dns '' 2>/dev/null || true
  sudo nmcli con up "$c" >/dev/null || true
  pause_pdm
}
restore_backup(){
  need_nm || return
  [[ -f "$BACKUP_FILE" ]] || { [[ "$LANG_UI" == es ]] && echo "No hay copia DNS anterior." || echo "No DNS backup is available."; pause_pdm; return; }
  local c="" i4i=no i4d="" i6i=no i6d="" k v
  while IFS=$'\t' read -r k v; do
    case "$k" in connection)c="$v";;ipv4_ignore)i4i="$v";;ipv4_dns)i4d="$v";;ipv6_ignore)i6i="$v";;ipv6_dns)i6d="$v";;esac
  done <"$BACKUP_FILE"
  nmcli con show "$c" >/dev/null 2>&1 || c="$(active_conn 2>/dev/null || true)"
  [[ -z "$c" ]] && return
  sudo_ok || return
  sudo nmcli con mod "$c" ipv4.ignore-auto-dns "${i4i:-no}" ipv4.dns "$i4d" || return
  sudo nmcli con mod "$c" ipv6.ignore-auto-dns "${i6i:-no}" ipv6.dns "$i6d" 2>/dev/null || true
  sudo nmcli con up "$c" >/dev/null || true
  pause_pdm
}

valid_ip(){
  local x="$1"
  if need_cmd python3; then python3 - "$x" <<'PY' >/dev/null 2>&1
import ipaddress,sys
ipaddress.ip_address(sys.argv[1])
PY
  else [[ "$x" =~ ^[0-9a-fA-F:.]+$ ]]; fi
}
custom_dns(){
  need_nm || return
  header
  local raw arr=() x p4="" p6="" c
  [[ "$LANG_UI" == es ]] && read -r -p "Direcciones DNS separadas por espacios/comas: " raw || read -r -p "DNS addresses separated by spaces/commas: " raw
  raw="${raw//,/ }"
  read -r -a arr <<<"$raw"
  (( ${#arr[@]} > 0 )) || return
  for x in "${arr[@]}"; do valid_ip "$x" || { echo "Invalid IP: $x"; pause_pdm; return; }; [[ "$x" == *:* ]] && p6+="${p6:+ }$x" || p4+="${p4:+ }$x"; done
  c="$(active_conn 2>/dev/null || true)"; [[ -z "$c" ]] && return
  sudo_ok || return; save_backup "$c"
  [[ -n "$p4" ]] && sudo nmcli con mod "$c" ipv4.ignore-auto-dns yes ipv4.dns "$p4"
  [[ -n "$p6" ]] && sudo nmcli con mod "$c" ipv6.ignore-auto-dns yes ipv6.dns "$p6" 2>/dev/null || true
  sudo nmcli con up "$c" >/dev/null || true
  pause_pdm
}

benchmark_one(){
  local server="$1" start end ms
  if need_cmd dig; then
    dig @"$server" example.com A +time=2 +tries=1 +stats 2>/dev/null | awk '/Query time:/{print $4;exit}'
  elif need_cmd nslookup; then
    start="$(date +%s%N 2>/dev/null || date +%s)"
    if nslookup example.com "$server" >/dev/null 2>&1; then
      end="$(date +%s%N 2>/dev/null || date +%s)"
      if [[ ${#start} -gt 10 && ${#end} -gt 10 ]]; then echo $(( (end-start)/1000000 )); else echo $(( (end-start)*1000 )); fi
    fi
  fi
}
benchmark(){
  header
  [[ "$LANG_UI" == es ]] && echo "PRUEBA DE PROVEEDORES DNS" || echo "DNS PROVIDER BENCHMARK"
  echo
  local row pid name cat p4 p6 doh enc tags sen ses server ms
  printf '%-42s %10s\n' "Provider / Proveedor" "ms"
  subline
  for row in "${PROVIDERS[@]}"; do
    IFS='|' read -r pid name cat p4 p6 doh enc tags sen ses <<<"$row"
    [[ "$enc" == 1 || -z "$p4" ]] && continue
    server="${p4%% *}"; ms="$(benchmark_one "$server" || true)"
    [[ -n "$ms" ]] && printf '%-42s %8s ms\n' "$name" "$ms" || printf '%-42s %10s\n' "$name" "FAIL"
  done
  echo
  [[ "$LANG_UI" == es ]] && echo "La menor latencia medida no implica automáticamente mejor privacidad, seguridad o filtrado." || echo "Lowest measured latency does not automatically mean better privacy, security or filtering."
  pause_pdm
}

public_ip_vpn(){
  if [[ $EXTERNAL_NOTICE -eq 0 ]]; then
    header
    [[ "$LANG_UI" == es ]] && echo "Esta función contacta https://ipwho.is para conocer tu IP pública y geolocalización aproximada. No se envían datos a servidores propios." || echo "This feature contacts https://ipwho.is for your public IP and approximate geolocation. No data is sent to servers operated by this project."
    echo
    local a; [[ "$LANG_UI" == es ]] && read -r -p "¿Continuar? [S/N] " a || read -r -p "Continue? [Y/N] " a
    case "${a^^}" in Y|YES|S|SI|SÍ) EXTERNAL_NOTICE=1;; *) return;; esac
  fi
  header
  need_cmd curl || { echo "curl is required."; pause_pdm; return; }
  local j; j="$(curl -fsS --max-time 10 https://ipwho.is/ 2>/dev/null || true)"
  [[ -z "$j" ]] && { echo "Unable to query IP service."; pause_pdm; return; }
  if need_cmd python3; then
    JSON_DATA="$j" LANG_UI="$LANG_UI" python3 - <<'PY'
import json,os
d=json.loads(os.environ["JSON_DATA"]); es=os.environ.get("LANG_UI")=="es"
def g(*p):
    x=d
    for k in p:
        if not isinstance(x,dict): return "-"
        x=x.get(k)
    return "-" if x in (None,"") else x
rows=[("IP pública","Public IP",g("ip")),("País","Country",g("country")),("Región aprox.","Approx. region",g("region")),
("Ciudad aprox.","Approx. city",g("city")),("ISP","ISP",g("connection","isp")),
("ASN","ASN","AS"+str(g("connection","asn"))),("Organización","Organization",g("connection","org")),
("Zona horaria","Time zone",g("timezone","id"))]
for a,b,v in rows: print(f"{(a if es else b):22}: {v}")
PY
  else printf '%s\n' "$j"; fi
  echo
  local hits; hits="$(ip -o link show 2>/dev/null | grep -Ei 'vpn|wireguard|wg[0-9]|tun|tap|tailscale|zerotier|mullvad|proton|warp|nord|surfshark|express' || true)"
  if [[ -n "$hits" ]]; then
    [[ "$LANG_UI" == es ]] && echo "Indicadores locales: VPN/túnel probablemente activo" || echo "Local indicators: VPN/tunnel likely active"
    echo "$hits"
  else
    [[ "$LANG_UI" == es ]] && echo "No se detectó un indicador local concluyente de VPN/túnel." || echo "No conclusive local VPN/tunnel indicator was detected."
  fi
  [[ "$LANG_UI" == es ]] && echo "La geolocalización y detección de VPN son aproximadas." || echo "IP geolocation and VPN detection are approximate."
  pause_pdm
}

interface_info(){
  header
  need_cmd ip && { ip -brief address 2>/dev/null || true; echo; ip route 2>/dev/null || true; }
  if need_cmd resolvectl; then echo; resolvectl status 2>/dev/null | head -n 120 || true; fi
  if need_cmd nmcli; then echo; nmcli device status 2>/dev/null || true; fi
  pause_pdm
}
test_current(){
  header
  local start end
  start="$(date +%s%N 2>/dev/null || date +%s)"
  if getent ahostsv4 example.com >/dev/null 2>&1; then
    end="$(date +%s%N 2>/dev/null || date +%s)"
    [[ ${#start} -gt 10 ]] && echo "OK ($(( (end-start)/1000000 )) ms)" || echo "OK"
  else echo "FAIL"; fi
  pause_pdm
}
flush_cache(){
  sudo_ok || return
  need_cmd resolvectl && sudo resolvectl flush-caches 2>/dev/null || true
  need_cmd systemd-resolve && sudo systemd-resolve --flush-caches 2>/dev/null || true
  pause_pdm
}

normalize_domain(){
  local raw="$1"
  if need_cmd python3; then
    python3 - "$raw" <<'PY'
import re,sys,urllib.parse
s=sys.argv[1].strip()
if "://" not in s: s="https://"+s
try: h=urllib.parse.urlsplit(s).hostname or ""
except: h=""
h=h.rstrip(".").lower()
if h.startswith("www."): h=h[4:]
try: h=h.encode("idna").decode("ascii")
except: h=""
ok=bool(re.fullmatch(r"(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])",h))
print(h if ok else "")
PY
  else
    raw="${raw#http://}"; raw="${raw#https://}"; raw="${raw%%/*}"; raw="${raw#www.}"
    [[ "$raw" =~ ^([A-Za-z0-9-]+\.)+[A-Za-z0-9-]+$ ]] && echo "${raw,,}"
  fi
}
managed_domains(){
  sudo awk -v s="$HOSTS_START" -v e="$HOSTS_END" '
    $0==s{inside=1;next}$0==e{inside=0;next}
    inside && $1=="0.0.0.0" && $2 !~ /^www\./ {print $2}
  ' /etc/hosts 2>/dev/null | sort -u
}
backup_hosts(){
  ensure_state; sudo cat /etc/hosts >"$HOSTS_BACKUP"; chmod 600 "$HOSTS_BACKUP" 2>/dev/null || true
}
write_managed_domains(){
  local tmp d; tmp="$(mktemp)" || return 1
  sudo awk -v s="$HOSTS_START" -v e="$HOSTS_END" '
    $0==s{inside=1;next}$0==e{inside=0;next}!inside{print}
  ' /etc/hosts >"$tmp" || { rm -f "$tmp"; return 1; }
  mapfile -t doms
  if (( ${#doms[@]} > 0 )); then
    { echo; echo "$HOSTS_START"; echo "# Entries below are managed by Portable DNS Manager."
      for d in "${doms[@]}"; do echo "0.0.0.0 $d"; echo "0.0.0.0 www.$d"; echo ":: $d"; echo ":: www.$d"; done
      echo "$HOSTS_END"; } >>"$tmp"
  fi
  sudo tee /etc/hosts >/dev/null <"$tmp"; rm -f "$tmp"
  need_cmd resolvectl && sudo resolvectl flush-caches 2>/dev/null || true
}
domain_blocker(){
  while true; do
    header
    [[ "$LANG_UI" == es ]] && echo "BLOQUEO LOCAL DE DOMINIOS" || echo "LOCAL DOMAIN BLOCKER"
    echo
    echo " [1] Block / Bloquear"
    echo " [2] Unblock / Desbloquear"
    echo " [3] List / Ver lista"
    echo " [4] Restore last hosts backup / Restaurar última copia hosts"
    echo " [B] $(trp back)"; echo
    read -r -p "$(trp select): " c
    case "${c^^}" in
      1)
        local raw d ans; read -r -p "Domain / Dominio: " raw; d="$(normalize_domain "$raw")"
        [[ -z "$d" ]] && { echo "Invalid domain / Dominio no válido"; pause_pdm; continue; }
        [[ "$LANG_UI" == es ]] && read -r -p "Se bloquearán $d y www.$d. ¿Continuar? [S/N] " ans || read -r -p "Block $d and www.$d? [Y/N] " ans
        case "${ans^^}" in Y|YES|S|SI|SÍ) ;; *) continue;; esac
        sudo_ok || continue; backup_hosts
        mapfile -t old < <(managed_domains)
        printf '%s\n' "${old[@]}" "$d" | sed '/^$/d' | sort -u | write_managed_domains
        pause_pdm;;
      2)
        sudo_ok || continue
        mapfile -t old < <(managed_domains)
        (( ${#old[@]} )) || { echo "None / Ninguno"; pause_pdm; continue; }
        local i; for i in "${!old[@]}"; do echo " [$((i+1))] ${old[$i]}"; done
        read -r -p "$(trp select): " n
        [[ "$n" =~ ^[0-9]+$ ]] || continue
        (( n>=1 && n<=${#old[@]} )) || continue
        backup_hosts
        for i in "${!old[@]}"; do (( i == n-1 )) || echo "${old[$i]}"; done | write_managed_domains
        pause_pdm;;
      3) managed_domains; pause_pdm;;
      4) sudo_ok || continue; [[ -f "$HOSTS_BACKUP" ]] && sudo tee /etc/hosts >/dev/null <"$HOSTS_BACKUP"; pause_pdm;;
      B) return;;
    esac
  done
}

family_compare(){
  header
  [[ "$LANG_UI" == es ]] && echo "COMPARATIVA DE PROTECCIÓN FAMILIAR" || echo "FAMILY FILTER COMPARISON"
  echo
  printf '%-28s %-8s %-7s %-6s %-10s %s\n' "Profile" "Threats" "Adult" "Ads" "SafeSrch" "Extra"
  subline
  printf '%-28s %-8s %-7s %-6s %-10s %s\n' "DNS4EU Child + Ads" Y Y Y - "violence, drugs"
  printf '%-28s %-8s %-7s %-6s %-10s %s\n' "CleanBrowsing Family" Y Y - Y "proxy/VPN, mixed"
  printf '%-28s %-8s %-7s %-6s %-10s %s\n' "AdGuard Family" Y Y Y Y "trackers"
  printf '%-28s %-8s %-7s %-6s %-10s %s\n' "Cloudflare Family" Y Y - - "-"
  printf '%-28s %-8s %-7s %-6s %-10s %s\n' "Vercara Family Secure" Y Y - - "gambling, violence"
  echo
  [[ "$LANG_UI" == es ]] && echo "Un guion significa «no afirmado aquí», no necesariamente «imposible»." || echo "A dash means “not claimed here”, not necessarily “impossible”."
  pause_pdm
}
quick_guide(){
  header
  if [[ "$LANG_UI" == es ]]; then
    cat <<'EOF'
USO NORMAL       -> DNS estable sin filtrado por categorías.
SEGURIDAD        -> bloqueo de malware/phishing según proveedor.
PUBLICIDAD       -> bloqueo de dominios publicitarios/rastreadores.
FAMILIAR         -> filtrado para menores; algunos añaden SafeSearch.
BLOQUEO LOCAL    -> /etc/hosts para dominios concretos.

IMPORTANTE:
- DNS no es una VPN.
- El filtrado DNS no sustituye un control parental completo.
- Linux v1.0.0 no instala proxies/daemons de DoH.
EOF
  else
    cat <<'EOF'
GENERAL USE      -> stable DNS without category filtering.
SECURITY         -> provider-specific malware/phishing blocking.
ADS/TRACKING     -> blocks advertising/tracking domains.
FAMILY           -> child-oriented filtering; some add SafeSearch.
LOCAL BLOCKING   -> /etc/hosts for specific domains.

IMPORTANT:
- DNS is not a VPN.
- DNS filtering is not a complete parental-control system.
- Linux v1.0.0 does not install DoH proxies/daemons.
EOF
  fi
  pause_pdm
}
documentation(){
  header; echo "$REPO_URL"; echo
  if need_cmd xdg-open; then
    local a; [[ "$LANG_UI" == es ]] && read -r -p "¿Abrir repositorio? [S/N] " a || read -r -p "Open repository? [Y/N] " a
    case "${a^^}" in Y|YES|S|SI|SÍ) xdg-open "$REPO_URL" >/dev/null 2>&1 || true;; esac
  fi
  pause_pdm
}

provider_menu(){
  local filter="${1:-all}"
  while true; do
    header; echo "$(trp catalog)"; echo
    local shown=() row pid name cat p4 p6 doh enc tags sen ses i=1 pair
    for row in "${PROVIDERS[@]}"; do
      IFS='|' read -r pid name cat p4 p6 doh enc tags sen ses <<<"$row"
      provider_matches "$tags" "$filter" || continue
      shown+=("$row"); pair="${p4// / / }"
      printf ' [%2d] %-39s %-31s%s\n' "$i" "$name" "${pair:--}" "$([[ "$enc" == 1 ]] && echo ' [DoH-only]' || ([[ -n "$doh" ]] && echo ' [DoH]' || true))"
      ((i++))
    done
    echo; echo " [I] Details / Detalles"; echo " [B] $(trp back)"
    read -r -p "$(trp select): " c
    [[ "${c^^}" == B ]] && return
    if [[ "${c^^}" == I ]]; then
      read -r -p "Profile number / Número: " n
      [[ "$n" =~ ^[0-9]+$ ]] && (( n>=1 && n<=${#shown[@]} )) && show_provider_detail "${shown[$((n-1))]}"
      continue
    fi
    [[ "$c" =~ ^[0-9]+$ ]] && (( c>=1 && c<=${#shown[@]} )) || continue
    IFS='|' read -r pid _ <<<"${shown[$((c-1))]}"; apply_provider "$pid"
  done
}
filter_menu(){
  while true; do
    header
    echo " [1] All / Todos"
    echo " [2] General"
    echo " [3] Security / Seguridad"
    echo " [4] Ads / Publicidad"
    echo " [5] Family / Familiar"
    echo " [6] Adult"
    echo " [7] Europe / Europa"
    echo " [C] Custom DNS / DNS personalizado"
    echo " [B] $(trp back)"
    read -r -p "$(trp select): " c
    case "${c^^}" in 1)provider_menu all;;2)provider_menu general;;3)provider_menu security;;4)provider_menu ads;;5)provider_menu family;;6)provider_menu adult;;7)provider_menu europe;;C)custom_dns;;B)return;;esac
  done
}

simple_menu(){
  while true; do
    header; echo "$(trp simple)"; echo
    if [[ "$LANG_UI" == es ]]; then
      echo " [1] USO NORMAL"
      echo " [2] MÁS SEGURIDAD"
      echo " [3] MENOS PUBLICIDAD Y RASTREO"
      echo " [4] PROTECCIÓN FAMILIAR"
      echo " [5] COMPARAR DNS FAMILIAR"
      echo " [6] BLOQUEAR CONTENIDO ADULTO"
      echo " [7] ELEGIR UN DNS"
    else
      echo " [1] GENERAL USE"
      echo " [2] MORE SECURITY"
      echo " [3] LESS ADS & TRACKING"
      echo " [4] FAMILY PROTECTION"
      echo " [5] COMPARE FAMILY DNS"
      echo " [6] BLOCK ADULT CONTENT"
      echo " [7] CHOOSE A DNS"
    fi
    echo
    echo " [8] $(trp public_ip)"
    echo " [9] $(trp blocker)"
    echo "[10] $(trp restore)"
    echo "[11] $(trp reset)"
    echo " [H] $(trp quick)"
    echo " [D] $(trp docs)"
    echo " [A] $(trp advanced)"
    echo " [0] $(trp exit)"
    read -r -p "$(trp select): " c
    case "${c^^}" in
      1)provider_menu general;;2)provider_menu security;;3)provider_menu ads;;4)provider_menu family;;
      5)family_compare;;6)provider_menu adult;;7)filter_menu;;8)public_ip_vpn;;9)domain_blocker;;
      10)restore_backup;;11)reset_auto;;H)quick_guide;;D)documentation;;A)advanced_menu || return 1;;0)return 1;;
    esac
  done
}
advanced_menu(){
  while true; do
    header; echo "$(trp advanced)"; echo
    echo " [1] $(trp catalog)"
    echo " [2] Custom DNS / DNS personalizado"
    echo " [3] $(trp benchmark)"
    echo " [4] Test current DNS / Probar DNS actual"
    echo " [5] $(trp interfaces)"
    echo " [6] $(trp public_ip)"
    echo " [7] Full network/DNS configuration / Configuración completa"
    echo " [8] Flush DNS cache / Vaciar caché"
    echo " [9] $(trp blocker)"
    echo "[10] $(trp family_compare)"
    echo "[11] $(trp restore)"
    echo "[12] $(trp reset)"
    echo "[13] $(trp quick)"
    echo "[14] $(trp docs)"
    echo " [B] $(trp back)"
    echo " [0] $(trp exit)"
    read -r -p "$(trp select): " c
    case "${c^^}" in
      1)filter_menu;;2)custom_dns;;3)benchmark;;4)test_current;;5)interface_info;;6)public_ip_vpn;;
      7)interface_info;;8)flush_cache;;9)domain_blocker;;10)family_compare;;11)restore_backup;;
      12)reset_auto;;13)quick_guide;;14)documentation;;B)return 0;;0)return 1;;
    esac
  done
}
main_menu(){
  while true; do
    header
    [[ "$LANG_UI" == es ]] && echo "¿Cómo quieres utilizar Portable DNS Manager?" || echo "How do you want to use Portable DNS Manager?"
    echo
    echo " [1] $(trp simple)"
    echo " [2] $(trp advanced)"
    echo " [3] $(trp public_ip)"
    echo " [4] $(trp blocker)"
    echo " [5] $(trp family_compare)"
    echo " [H] $(trp quick)"
    echo " [D] $(trp docs)"
    echo " [0] $(trp exit)"
    read -r -p "$(trp select): " c
    case "${c^^}" in
      1)simple_menu || return;;2)advanced_menu || return;;3)public_ip_vpn;;4)domain_blocker;;
      5)family_compare;;H)quick_guide;;D)documentation;;0)return;;
    esac
  done
}
main(){ choose_language || exit 0; main_menu; }
main "$@"
