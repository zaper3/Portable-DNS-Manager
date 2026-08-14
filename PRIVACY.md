# Privacy / Privacidad

## English

Portable DNS Manager does **not** include telemetry, analytics, advertising, accounts or a project-operated backend.

### Local-only operations
DNS configuration, interface inspection, backup/restore, DHCP reset, cache flush and local `hosts` management are performed locally.

### External requests initiated by the user
Some optional functions necessarily communicate with third parties:
- **Public IP / region / VPN indicators:** queries `https://ipwho.is/`.
- **DNS benchmark / DNS tests:** sends DNS queries to the resolver(s) being tested.
- **Documentation:** may open the official GitHub repository in the default browser.

The application asks before the public-IP lookup. The project itself does not receive or store those results.

IP geolocation and VPN detection are approximate and should not be treated as identity or physical-location proof.

## Español

Portable DNS Manager **no** contiene telemetría, analítica, publicidad, cuentas ni backend operado por el proyecto.

### Operaciones locales
Configuración DNS, inspección de interfaces, backup/restore, DHCP, vaciado de caché y gestión local de `hosts` se realizan localmente.

### Consultas externas iniciadas por el usuario
Algunas funciones opcionales necesitan comunicarse con terceros:
- **IP pública / región / indicadores VPN:** consulta `https://ipwho.is/`.
- **Benchmark / pruebas DNS:** envían consultas DNS a los resolvers que se están probando.
- **Documentación:** puede abrir el repositorio oficial de GitHub en el navegador.

La aplicación solicita confirmación antes de consultar la IP pública. El proyecto no recibe ni almacena esos resultados.

La geolocalización IP y la detección de VPN son aproximadas y no deben interpretarse como prueba de identidad o ubicación física.
