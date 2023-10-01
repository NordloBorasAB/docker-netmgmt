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
      
<p>Perform a "docker-compose down" and "docker-compose up" and wait a couple of minutes. Refresh the site and verify the proper function of the certificate.</p>

<br>
<h3>Basic setup</h3>
<p>Adjust the .env and config file before running docker-compose</p>
<p>The .env file specifies a subnet for the private Docker network. If you change this the config file for Oxidized must be updated:
http:
url: http://172.23.240.22  <-
</p>
<p>After creating public DNS records, create acme.json and set permissions:
<br>touch acme.json
<br>chmod 600 acme.json
<p>After editing the .env file start the containers by running: <BR>
<code>docker-compose up -d</code></p>
<p>While waiting for docker-compose to do its thing create DNS records in your internal DNS for the containers you have chosen to deploy.</p>
<p>When LibreNMS is ready log on with the default password and configure API access for oxidized, copy the API token to Oxidized's config file.</p>
<p>Add username and password for the switches in the config file and copy the file to the oxidized folder to replace the current file.</p>
<p>The remaining config is performed from the web gui of each application.</p>
