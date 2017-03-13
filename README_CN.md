# letsencrypt
这是关于linux中获取/更新Let’s encrypt 证书的shell脚本。该脚本通过调用acme_tiny.py[acme-tiny](https://github.com/diafygi/acme-tiny) 认证、获取、更新证书，不需要额外的依赖。

#使用方法
+1.克隆脚本到本地  

		sudo git clone https://github.com/gchangyi/letsencrypt.git
		cd letsencrypt
		chmod +x letsencrypt.sh
+2.修改配置文件  

只需要修改 DOMAIN_KEY DOMAIN_DIR DOMAINS 为你自己的信息  

		ACCOUNT_KEY="account.key"
		DOMAIN_KEY="site.com.key"
		DOMAIN_DIR="/usr/local/nginx/html/"
		DOMAINS="DNS:site.com,DNS:www.site.com"
+3.执行脚本  

		./letsencrypt.sh
即可生成所需要的证书