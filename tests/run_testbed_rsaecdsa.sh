#!/bin/bash

# This script is testing a RSA and ECDSA TLS handshakes with DH key exchange. The parameter passed is the name of the directory which contains both the liboqs and the openssl libraries already compiled.

# Use one parameter to choose the directory
# Use no parameters to use default directory 

if [ $# -eq 1 ]
then
	echo "Test this directory: "
	dir=$1
else
	echo "Test default directory: "
	dir=~/testbed_for_liboqs_tests/openssl_for_liboqs_tests

fi

echo $dir

cd
cd $dir
cd openssl_pq

output_dir=~/tests/results/output_tls_s_time_rsaecdsa.txt

# First create RSA server certificates
apps/openssl req -x509 -new -newkey rsa -keyout rsa_CA.key -out rsa_CA.crt -nodes -subj "/CN=oqstest CA" -days 365 -config apps/openssl.cnf

apps/openssl genpkey -algorithm rsa -out rsa_srv.key

apps/openssl req -new -newkey rsa -keyout rsa_srv.key -out rsa_srv.csr -nodes -subj "/CN=oqstest server" -config apps/openssl.cnf

apps/openssl x509 -req -in rsa_srv.csr -out rsa_srv.crt -CA rsa_CA.crt -CAkey rsa_CA.key -CAcreateserial -days 365

sleep 2

# Need of a TLS server and a TLS client
apps/openssl s_server -cert rsa_srv.crt -key rsa_srv.key -www -tls1_3 &
server_pid=$!

echo "------------------------------------------------------------------------" > $output_dir
echo "RSA" >> $output_dir
echo "########################################################################" >> $output_dir


echo "Testing with s_time:"
# Loop in order to compute mean and std dev
for i in {1..10}
do
	sleep 2
	echo "ITERATION " $i
	apps/openssl s_time -new -time 10 | tail -n 2 >> $output_dir
done


kill -9 $server_pid

# First create ECDSA server certificates

apps/openssl req -x509 -new -newkey ec:<(apps/openssl ecparam -name secp384r1) -keyout ecdsa_CA.key -out ecdsa_CA.crt -nodes -subj "/CN=oqstest" -days 365 -config apps/openssl.cnf


apps/openssl genpkey -genparam -algorithm EC -out ecdsa_srv.key -pkeyopt ec_paramgen_curve:secp384r1 -pkeyopt ec_param_enc:named_curve


apps/openssl req -new -newkey EC -keyout ecdsa_srv.key -out ecdsa_srv.csr -nodes -subj "/CN=oqstest server" -config apps/openssl.cnf -pkeyopt ec_paramgen_curve:secp384r1 -pkeyopt ec_param_enc:named_curve

apps/openssl x509 -req -in ecdsa_srv.csr -out ecdsa_srv.crt -CA ecdsa_CA.crt -CAkey ecdsa_CA.key -CAcreateserial -days 365

sleep 2

# Need of a TLS server and a TLS client
apps/openssl s_server -cert ecdsa_srv.crt -key ecdsa_srv.key -www -tls1_3 &
server_pid=$!

echo "------------------------------------------------------------------------" >> $output_dir
echo "ECDSA" >> $output_dir
echo "########################################################################" >> $output_dir


echo "Testing with s_time:"
# Loop in order to compute mean and std dev
for i in {1..10}
do
	sleep 2
	echo "ITERATION " $i
	apps/openssl s_time -new -time 10 | tail -n 2 >> $output_dir
done


kill -9 $server_pid

echo "Done."
