#!/bin/bash
# LAST UPDATES :
# 20170313 v1.0 - created
####################################################################################################################################
# Script       : letsencrypt.sh
# Author       : gchangyi
# Version      : 1.0
# Lastupdate   : 13 Mar 2017
# Description  : This script is the renew TLS certs from Let's Encrypt base on acme-tiny
# Usage        : letsencrypt.sh
# Options      :
# Examples     : ./letsencrypt.sh
# the script can be run at any "folder" to give "absolute path" or "relative path" WITHOUT side effect
####################################################################################################################################
PATH_DIR=$(dirname $(which $0))
cd ${PATH_DIR}
source ${PATH_DIR}/letsencrypt.conf
ACME_TINY="${PATH_DIR}/acme_tiny.py"
#DOMAIN_KEY=""

ACCOUNT_KEY="${PATH_DIR}/${ACCOUNT_KEY}"
DOMAIN_KEY="${PATH_DIR}/${DOMAIN_KEY}"
KEY_PREFIX="${DOMAIN_KEY%.*}"
DOMAIN_PEM="${KEY_PREFIX}.pem"
DOMAIN_CSR="${KEY_PREFIX}.csr"
SIGNED_CRT="${PATH_DIR}/signed.crt"
INTERMEDIATE_PEM="${PATH_DIR}/intermediate.pem"
DOMAIN_CHAINED_CRT="${PATH_DIR}/fullchained.pem"

if [ ! -f ${ACCOUNT_KEY} ];then
    echo "Generate account key..."
    openssl genrsa 4096 > ${ACCOUNT_KEY}
fi

if [ ! -f ${DOMAIN_KEY} ];then
    echo "Generate domain key..."
    if [ "${ECC}" = "TRUE" ];then
        openssl ecparam -genkey -name secp256r1 | openssl ec -out ${DOMAIN_KEY}
    else
        openssl genrsa 4096 > ${DOMAIN_KEY}
    fi
fi

echo "Generate CSR...${DOMAIN_CSR}"

OPENSSL_CONF="/etc/ssl/openssl.cnf"

if [ ! -f ${OPENSSL_CONF} ];then
    OPENSSL_CONF="/etc/pki/tls/openssl.cnf"
    if [ ! -f ${OPENSSL_CONF} ];then
        echo "Error, file openssl.cnf not found."
        exit 1
    fi
fi

openssl req -new -sha256 -key ${DOMAIN_KEY} -subj "/" -reqexts SAN -config <(cat ${OPENSSL_CONF} <(printf "[SAN]\nsubjectAltName=%s" ${DOMAINS})) > ${DOMAIN_CSR}

wget https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py -O ${ACME_TINY} -o /dev/null

if [ -f ${SIGNED_CRT} ];then
    mv ${SIGNED_CRT} "${SIGNED_CRT}-OLD-$(date +%y%m%d-%H%M%S)"
fi

python ${ACME_TINY} --account-key ${ACCOUNT_KEY} --csr ${DOMAIN_CSR} --acme-dir ${DOMAIN_DIR} > ${SIGNED_CRT} || exit

if [ "$?" != 0 ];then
    exit 1
fi

#if [ ! -f ${INTERMEDIATE_PEM} ];then
   wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > ${INTERMEDIATE_PEM}
#fi

cat ${SIGNED_CRT} ${INTERMEDIATE_PEM} > ${DOMAIN_CHAINED_CRT}

if [ "${LIGHTTPD}" = "TRUE" ];then
    cat ${DOMAIN_KEY} ${SIGNED_CRT} > ${DOMAIN_PEM}
    echo -e "\e[01;32mNew pem: $DOMAIN_PEM has been generated\e[0m"
fi

echo -e "\e[01;32mNew cert: $DOMAIN_CHAINED_CRT has been generated\e[0m"

#/usr/local/nginx/sbin/nginx -s reload

