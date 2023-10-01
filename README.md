<h1>Docker setup with IPAM, LibreNMS, Netbox, PwPush, Oxidized, Syslog and Portainer for network monitoring, management and documentation</h1>

<p>Install Docker:</p>

<code>curl -fsSL https://get.docker.com -o get-docker.sh</code><br>
<code>sudo sh get-docker.sh</code><br>
<code>sudo apt install docker-compose</code>

<p>This docker compose is based on dockerimages for phpIPAM, LibreNMS, Netbox, PwPush, Portainer, Oxidized and others. Hard coded versions are defined in docker-compose.yml to avoid new bugs at deployment. New versions are tested evaluated regularly and this docker compose is updated sporadically with approved versions numbers.</p>

<p>Traefik is used as a reverse proxy and TLS endpoint for all ingress traffic. If a valid domain and email address is provided and you point public dns names towards a web server on port 80 Traefik will generate a valid Letsencrypt certificate. If else Traefiks self signed certificate will be used.
</p>

<p>The easiest solution is to point the dns names to a public address on the firewall and configure dnat on port 80 towards the Docker host. Port 80 will reply with a redirect to https which is closed but you will still get valid certs without publishing any services. Add the DNS records to a private DNS and access your services with a valid certificate.
</p>

## Wildcard certificates

To use purchased wildcard certificates do the following:

Remove these lines under "command" and "volumes" for the Traefik container:
       
     commands:
      - "--certificatesresolvers.letsencrypt.acme.storage=acme.json"
      - "--certificatesresolvers.letsencrypt.acme.email=${EMAIL}"  
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=http"
     volumes:
      - "./acme.json:/acme.json"
      
Uncomment these lines under "command" and "volumes" for the Traefik container:</p>

     commands:
      - "--providers.file.directory=/etc/traefik/dynamic"
      - "--providers.file.watch=true"
     volumes:
      - "./traefik/:/etc/traefik/dynamic/:ro" 

<p>If you have a pfx file with your wildcard certificate available export .crt and .key with OpenSSL and put them in the "certs" folder.</p>

Adjust the certificate and key name in "/certs/config.yml".
    
    /certs/config.yml:
       
    tls:
    certificates:
    - certFile: /etc/traefik/dynamic/temp.crt <--
      keyFile: /etc/traefik/dynamic/temp.key <--
    
    /haproxy/haproxy.cfg:
       
    frontend  main
    bind *:443 ssl crt /etc/ssl/certs/temp.crt <--
   
<p>Perform a "docker-compose down" and sedan "docker-compose up" and wait a couple of minutes. Refresh the site and verify the proper function of the certificate.</p>

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
