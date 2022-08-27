# docker-goaccess-cron

A docker-container running [goaccess](goaccess.io) in a cron job. To be used with
[portal-compose](https://github.com/mardi4nfdi/portal-compose).

Goaccess will be executed with command line arguments given via `command` in
docker-compose and with the settings in a config file `/etc/goaccess.conf`.
The cron schedule is defined via the `GOACCESS_SCHEDULE` env var.

docker-compose example setup:
```yaml
services:
  apache:
    [...]


  goaccess:
    image: "ghcr.io/mardi4nfdi/docker-goaccess-cron:main"
    container_name: goaccess
    restart: unless-stopped
    command:
      - /srv/log/access.log
      - /srv/log/access.log.1
      - --output=/srv/reports/index.html
      - --geoip-database=/srv/geoip/GeoLite2-City.mmdb
      - --db-path=/srv/data
      - --log-format='%h %^[%d:%t %^] "%r" %s %b "%R" "%u" %Lm'
      - --date-format=%d/%b/%Y
      - --time-format=%T
    environment:
      - GOACCESS_SCHEDULE=${GOACCESS_SCHEDULE:-0 0 * * *}
    volumes:
      - ./traefik-log:/srv/log:ro
      - goaccess_report:/srv/reports
      - goaccess_db:/srv/data
      - ./goaccess/goaccess.conf:/etc/goaccess/goaccess.conf
      - ./goaccess/GeoLite2-City.mmdb:/srv/geoip/GeoLite2-City.mmdb

  # web server to serve the report (localhost:8000)
  nginx:
    image: nginx
    container_name: nginx-goaccess
    depends_on:
      - goaccess
    volumes:
      - goaccess_report:/usr/share/nginx/html
    ports:
      - 8000:80

volumes:
    - goacces_report
    - goacces_db
```
This setup assumes that traefik logs are mounted to `./traefik-log` (on host), that a log
rotation is applied on these logs (recommended but not required), that
`goaccess/goaccess.conf` is provided (done by [portal-compose](https://github.com/mardi4nfdi/portal-compose)) and that `GeoLite2-City.mmdb` GeoLocation DB is placed under `./goaccess` (see below).

## GeoIP Database

In order to resolve IP geo locations, download the free database `GeoLite2 City` from https://www.maxmind.com/en/accounts/758058/geoip/downloads.
An account was already registered with our MaRDI4NFDI groupware email account.
Extract the file `GeoLite2-City.mmdb` to the directory `./goaccess/`.
