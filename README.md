<h1>Docker med IPAM, LibreNMS, Oxidized och Portainer för network management</h1>

<p>Installera Docker:</p>

<code>curl -fsSL https://get.docker.com -o get-docker.sh</code><br>
<code>$ sudo sh get-docker.sh</code>

<p> Bygger på officiella dockerimages för phpIPAM, librenms och Oxidized. 
Satt fasta versioner för att slippa buggar vid installation. Nya versioner kommer testas och då uppdateras docker-compose.yml
</p>

<p> traefik är reverseproxy för all web. redirectar http till https för de två namn som anges i .env -filen.
Anger man en giltig domän + email-adress och leder dessa dns-namn publikt mot en ip som svarar på port80 kommer ett traefik
generera ett giltigt cert från LetsEncrypt. Annars används default inbyggda self-signed cert.
</p>

<p> Lättast är att peka de 2 dns-namnen publikt mot brandvägg och NATa endast port80 mot docker-servern.
Port80 svarar med redirect mot https (som inte är öppet) och du får giligt cert utan att faktiskt behöva publicera något.
Lägg sedan upp samma namn i en intern DNS-server som pekar på serverns interna IP.
</p>
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
