#!/bin/bash

declare -a List_algo_to_test=("SPHINCS+-Haraka-128f-robust" "SPHINCS+-Haraka-128f-simple" "SPHINCS+-Haraka-128s-robust" "SPHINCS+-Haraka-128s-simple" "SPHINCS+-Haraka-192f-robust" "SPHINCS+-Haraka-192f-simple" "SPHINCS+-Haraka-192s-robust" "SPHINCS+-Haraka-192s-simple" "SPHINCS+-Haraka-256f-robust" "SPHINCS+-Haraka-256f-simple" "SPHINCS+-Haraka-256s-robust" "SPHINCS+-Haraka-256s-simple" "SPHINCS+-SHA256-128f-robust" "SPHINCS+-SHA256-128f-simple" "SPHINCS+-SHA256-128s-robust" "SPHINCS+-SHA256-128s-simple" "SPHINCS+-SHA256-192f-robust" "SPHINCS+-SHA256-192f-simple" "SPHINCS+-SHA256-192s-robust" "SPHINCS+-SHA256-192s-simple" "SPHINCS+-SHA256-256f-robust" "SPHINCS+-SHA256-256f-simple" "SPHINCS+-SHA256-256s-robust" "SPHINCS+-SHA256-256s-simple" "SPHINCS+-SHAKE256-128f-robust" "SPHINCS+-SHAKE256-128f-simple" "SPHINCS+-SHAKE256-128s-robust" "SPHINCS+-SHAKE256-128s-simple" "SPHINCS+-SHAKE256-192f-robust" "SPHINCS+-SHAKE256-192f-simple" "SPHINCS+-SHAKE256-192s-robust" "SPHINCS+-SHAKE256-192s-simple" "SPHINCS+-SHAKE256-256f-robust" "SPHINCS+-SHAKE256-256f-simple" "SPHINCS+-SHAKE256-256s-robust" "SPHINCS+-SHAKE256-256s-simple")

declare -a List_algo_frodo=("FrodoKEM-640-AES" "FrodoKEM-640-SHAKE" "FrodoKEM-976-AES" "FrodoKEM-976-SHAKE" "FrodoKEM-1344-AES" "FrodoKEM-1344-SHAKE")

declare -a List_algo_NTRU=("NTRU-HPS-2048-509" "NTRU-HPS-2048-677" "NTRU-HPS-4096-821" "NTRU-HRSS-701")

declare -a List_algo_BIKE=("BIKE1-L1-CPA" "BIKE1-L3-CPA" "BIKE1-L1-FO" "BIKE1-L3-FO")


output_sig=~/tests/results/output_liboqs_sig.txt
output_kem=~/tests/results/output_liboqs_kem.txt
output_std_sig=~/tests/results/output_liboqs_std_sig.txt

# Clean previous outputs
echo > $output_sig
echo > $output_kem
echo > $output_std_sig


main_dir="openssl_for_liboqs_tests"

# PQ signature: SPHINCS+

# Print length of algorithms list
echo "There are" ${#List_algo_to_test[@]} "SPHINCS+ signature variants to test."

for algo in ${List_algo_to_test[@]}; do
	echo "-------------------------------------------------------------"  >> $output_sig
	echo $algo
	echo $algo >> $output_sig
	echo "#############################################################" >> $output_sig
	cd
	cd testbed_for_liboqs_tests
	cd $main_dir
	cd liboqs/build
	./tests/test_sig $algo >> $output_sig
	./tests/speed_sig $algo >> $output_sig
done


# PQ key exchange: Frodo

for algo in ${List_algo_frodo[@]}; do
	echo "-------------------------------------------------------------" >> $output_kem
	echo $algo
	echo $algo >> $output_kem
	echo "#############################################################" >> $output_kem
	cd
	cd testbed_for_liboqs_tests
	cd $main_dir
	cd liboqs/build
	./tests/test_kem $algo >> $output_kem
	./tests/speed_kem $algo >> $output_kem
done

# PQ key exchange: NTRU

for algo in ${List_algo_NTRU[@]}; do
	echo "-------------------------------------------------------------" >> $output_kem
	echo $algo
	echo $algo >> $output_kem
	echo "#############################################################" >> $output_kem
	cd
	cd testbed_for_liboqs_tests
	cd $main_dir
	cd liboqs/build
	./tests/test_kem $algo >> $output_kem
	./tests/speed_kem $algo >> $output_kem
done

# PQ key exchange: BIKE

for algo in ${List_algo_BIKE[@]}; do
	echo "-------------------------------------------------------------" >> $output_kem
	echo $algo
	echo $algo >> $output_kem
	echo "#############################################################" >> $output_kem
	cd
	cd testbed_for_liboqs_tests
	cd $main_dir
	cd liboqs/build
	./tests/test_kem $algo >> $output_kem
	./tests/speed_kem $algo >> $output_kem
done

echo "Done"


