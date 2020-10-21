#!/bin/bash

# This script is testing a single SPHINCS variant. The parameter passed is the name of the directory which contains both the liboqs and the openssl libraries already compiled. They should use as default signature algorithm the one specified as parameter here (the same of the name of the directory)

# Use one parameter to choose the algorithm to test
# Use no parameters to use default algorithm to test

if [ $# -eq 1 ]
then
	echo "Test this algorithm: "
	algo_to_test=$1
else
	echo "Test default algorithm: "
	algo_to_test="OQS_SIG_alg_sphincs_haraka_128f_robust"

fi

echo $algo_to_test

cd
cd testbed
cd $algo_to_test
cd openssl_pq

output_dir=~/tests/results/output_tls_s_time.txt


# Need of a TLS server and a TLS client
apps/openssl s_server -cert sphincs_srv.crt -key sphincs_srv.key -www -tls1_3 &
server_pid=$!

echo "------------------------------------------------------------------------" > $output_dir
echo $algo_to_test >> $output_dir
echo "########################################################################" >> $output_dir


echo "Testing with s_time:"
# Loop in order to compute mean and std dev
for i in {1..10}
do
	sleep 2
	echo "ITERATION " $i
	apps/openssl s_time -new -time 10 | tail -n 2 >> $output_dir
done

# Testing with best performant key exchange algorithm: ntru_hps2048509
best_kem="ntru_hps2048509"
echo "------------------------------------------------------------------------" >> $output_dir
echo $best_kem
echo $best_kem >> $output_dir
echo "########################################################################" >> $output_dir

# Loop in order to compute mean and std dev
for i in {1..10}
do
	sleep 2
	echo "ITERATION " $i
	apps/openssl s_time -new -time 10 -curves $best_kem | tail -n 2 >> $output_dir
done


kill -9 $server_pid

echo "Done."
