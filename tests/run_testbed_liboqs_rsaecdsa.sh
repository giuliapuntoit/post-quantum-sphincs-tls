#!/bin/bash

output_std_sig=~/tests/results/output_liboqs_std_sig.txt
echo > $output_std_sig

main_dir="openssl_for_liboqs_tests"


# Standard crypto: rsa and ecdsa

echo "-------------------------------------------------------------" >> $output_std_sig
echo RSA
echo "RSA2048" >> $output_std_sig
echo "#############################################################" >> $output_std_sig
cd
cd testbed_for_liboqs_tests
cd $main_dir
cd openssl_pq
for i in {1..10}
do
	echo "ITERATION " $i
	openssl speed rsa2048 | tail -n 2 >> $output_std_sig
done



echo "-------------------------------------------------------------" >> $output_std_sig
echo ECDSA
echo "ECDSA nistp384" >> $output_std_sig
echo "#############################################################" >> $output_std_sig

for i in {1..10}
do
	echo "ITERATION " $i
	openssl speed ecdsap384 | tail -n 2  >> $output_std_sig
done

echo "Done"
