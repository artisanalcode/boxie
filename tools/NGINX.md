#Reverse Proxy

Depending on your testing setup, modifying your *hosts* file on your Windows box might not be enough--you might need to setup a reverse proxy.

## NGINX

For you convenience NGINX is downloaded and copied to your new client machine, to C:\Temp. The script however does not install or configures it.

### Installation
 
Locate NGINX installation file:

    C:\Temp\nginx-1.8.0.zip

Unzip it to your folder of choice.

### Configuration

Locate your config file:

    C:\<nginx_folder>\conf\nginx.conf

Add the following inside the http config (you will see other commented out configurations to guide you). Add as many as necessary.

    server {
		listen <listen_to_port>;	
		server_name <listen_to_address_>;
		location / {
			proxy_pass http://<forward_to_address>:<forward_to_port>?;
		}
	}

### Resources

[Wikipedia:Reverse Proxy](https://en.wikipedia.org/wiki/Reverse_proxy)
[NGINX Reverse Proxy](https://www.nginx.com/resources/admin-guide/reverse-proxy/)
[NGINX Install Wiki](http://wiki.nginx.org/Install)
