# docker-goaccess-cron

A docker-container running [goaccess](goaccess.io) in a cron job. To be used with
[portal-compose](github.com/mardi4nfdi/portal-compose).

Goaccess will be executed with command line arguments given via `command` in
docker-compose, or by mounting a config file `/etc/goaccess.conf`.
The cron schedule is defined via the `GOACCESS_SCHEDULE` env var.

docker-compose example setup:
```yaml
services:
  apache:
    [...]

  goaccess:
    image: goaccess-cron:latest
    container_name: goaccess
    restart: unless-stopped
    command:
      - --log-file=/srv/log/access.log 
      - --output=/srv/reports/index.html 
      - --geoip-database=/srv/geoip/GeoLite2-City.mmdb 
      - --db-path=/srv/data 
    environment:
      - GOACCESS_SCHEDULE=${GOACCESS_SCHEDULE:-0 0 * * *}
    volumes:
      - apache_logs:/srv/log:ro
      - apache_reports:/srv/reports
      - goaccess_db:/srv/data
      - ./goaccess/goaccess.conf:/etc/goaccess.conf
      - ./goaccess/GeoLite2-City.mmdb:/srv/geoip/GeoLite2-City.mmdb
    labels:
      - traefik.enable=false

  # web server to serve the report (localhost:8000)
  nginx:
    image: nginx
    container_name: nginx-goaccess
    depends_on:
      - goaccess
    volumes:
      - apache_reports:/usr/share/nginx/html
    ports:
      - 8000:80
```
