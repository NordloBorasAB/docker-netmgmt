<h1>Docker setup with IPAM, LibreNMS, Netbox, PwPush, Oxidized, Syslog and Portainer for network monitoring, management and documentation</h1>

<p>Install Docker:</p>

<code>curl -fsSL https://get.docker.com -o get-docker.sh</code><br>
<code>sudo sh get-docker.sh</code><br>
<code>sudo apt install docker-compose</code>

<p>This docker compose is based on dockerimages for phpIPAM, LibreNMS, Netbox, PwPush, Portainer, Oxidized and others. Hard coded versions are defined in docker-compose.yml to avoid new bugs at deployment. New versions are tested evaluated regularly and this docker compose is updated sporadically with approved versions numbers.</p>

<p>Traefik is used as a reverse proxy and TLS endpoint for all ingress traffic. Anger man en giltig domän + email-adress och leder dessa dns-namn publikt mot en ip som svarar på port 80 kommer Traefik generera ett giltigt cert från LetsEncrypt. Annars används Traefiks inbyggda self-signed certifikat.
</p>

<p>Lättast är att peka de 2 dns-namnen publikt mot brandvägg och konfigurera DNAT på port 80 mot docker-servern. Port 80 svarar med redirect mot https (som inte är öppet) och du får giligt cert utan att faktiskt behöva publicera något. Lägg sedan upp samma namn i en intern DNS-server som pekar på serverns interna ip-adress.
</p>

## Wildcard certifikat

Om du vill använda ett lokalt wildcard certifikat för Traefik behöver du göra följande:

Plocka bort följande rader från "command" och "volumes" under Traefik-containerns konfiguration:
       
     commands:
      - "--certificatesresolvers.letsencrypt.acme.storage=acme.json"
      - "--certificatesresolvers.letsencrypt.acme.email=${EMAIL}"  
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=http"
     volumes:
      - "./acme.json:/acme.json"
      
Aktivera följande rader från "command" och "volumes" under Traefik-containern:</p>

     commands:
      - "--providers.file.directory=/etc/traefik/dynamic"
      - "--providers.file.watch=true"
     volumes:
      - "./traefik/:/etc/traefik/dynamic/:ro" 

<p>Om du har ett wildcard.pfx tillgänglig kan du bryta den med openssl och klistra in .crt och .key i mappen som heter "certs".</p>

Under "/certs/config.yml" behöver man justera certifikatsnamnet.
    
    /certs/config.yml:
       
    tls:
    certificates:
    - certFile: /etc/traefik/dynamic/temp.crt <--
      keyFile: /etc/traefik/dynamic/temp.key <--
    
    /haproxy/haproxy.cfg:
       
    frontend  main
    bind *:443 ssl crt /etc/ssl/certs/temp.crt <--
   
<p>Utför sedan en "docker-compose down" och sedan "docker-comopse up" och vänta ett par minuter. Uppdatera sedan sidan och verifiera att certifikatet ser korrekt ut</p>

<br>
<h3> Basic setup </h3>
<p> Vid installation anpassa .env -filen samt config -filen </p>
<p>.env -filen innehåller ett ip-scope. Ändras detta måste config -filen för oxidized uppdateras manuellt på:
http:
url: http://172.23.240.22  <-
</p>
<p> Efter att du skapat publika DNS-namn (om du vill ha giltigt LetsEncrypt cert) skapa acme.json och sätt korrekt rättighet:
<br> touch acme.json
<br> chmod 600 acme.json
<p> Efter du redigera .env starta upp docker containers med: <BR>
docker-compose up -d
<p> Medans du väntar på att docker-compose gör sitt jobb skapa DNS-entrys i interna DNSen mot serverns interna-ip för de 2 dns-namnen.</p>
<p> Det tar ca 15min för librenms databas att bli helt färdig så ha tålamod. 
När librenms är uppe logga på med default lösenord och skapa API access för oxidized kopiera in token i config -filen 
</p>
<p> Lägg till username och password för switcharna i config -filen och kopiera sedan in den i oxidized mappen. (ersätt befintlig).
</p>
<p> Resten sköts ifrån webGUIt. Sätt användarnamn och lösen för librenms och phpIPAM och initiera phpIPAM databasen
</p>
