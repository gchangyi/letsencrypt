# letsencrypt
This script is the renew TLS certs from Let's Encrypt base on acme-tiny(https://github.com/diafygi/acme-tiny)

#Usage
+1.clone script from Github
		sudo git clone https://github.com/gchangyi/letsencrypt.git
		cd letsencrypt
		chmod +x letsencrypt.sh
+2.change configuration file

change the  DOMAIN_KEY DOMAIN_DIR DOMAINS to your information
		ACCOUNT_KEY="account.key"
		DOMAIN_KEY="site.com.key"
		DOMAIN_DIR="/usr/local/nginx/html/"
		DOMAINS="DNS:site.com,DNS:www.site.com"
+3.run script
		./letsencrypt.sh
