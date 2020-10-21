#!/bin/bash

# Enter home directory
cd # I could specify a path instead of home directory

# Algorithms to set by default
# declare -a List_algo_to_test=("OQS_SIG_alg_sphincs_haraka_128f_robust" "OQS_SIG_alg_sphincs_haraka_128f_simple" "OQS_SIG_alg_sphincs_haraka_128s_robust")

declare -a List_algo_to_test=("OQS_SIG_alg_sphincs_haraka_128f_robust" "OQS_SIG_alg_sphincs_haraka_128f_simple" "OQS_SIG_alg_sphincs_haraka_128s_robust" "OQS_SIG_alg_sphincs_haraka_128s_simple" "OQS_SIG_alg_sphincs_haraka_192f_robust" "OQS_SIG_alg_sphincs_haraka_192f_simple" "OQS_SIG_alg_sphincs_haraka_192s_robust" "OQS_SIG_alg_sphincs_haraka_192s_simple" "OQS_SIG_alg_sphincs_haraka_256f_robust" "OQS_SIG_alg_sphincs_haraka_256f_simple" "OQS_SIG_alg_sphincs_haraka_256s_robust" "OQS_SIG_alg_sphincs_haraka_256s_simple" "OQS_SIG_alg_sphincs_sha256_128f_robust" "OQS_SIG_alg_sphincs_sha256_128f_simple" "OQS_SIG_alg_sphincs_sha256_128s_robust" "OQS_SIG_alg_sphincs_sha256_128s_simple" "OQS_SIG_alg_sphincs_sha256_192f_robust" "OQS_SIG_alg_sphincs_sha256_192f_simple" "OQS_SIG_alg_sphincs_sha256_192s_robust" "OQS_SIG_alg_sphincs_sha256_192s_simple" "OQS_SIG_alg_sphincs_sha256_256f_robust" "OQS_SIG_alg_sphincs_sha256_256f_simple" "OQS_SIG_alg_sphincs_sha256_256s_robust" "OQS_SIG_alg_sphincs_sha256_256s_simple" "OQS_SIG_alg_sphincs_shake256_128f_robust" "OQS_SIG_alg_sphincs_shake256_128f_simple" "OQS_SIG_alg_sphincs_shake256_128s_robust" "OQS_SIG_alg_sphincs_shake256_128s_simple" "OQS_SIG_alg_sphincs_shake256_192f_robust" "OQS_SIG_alg_sphincs_shake256_192f_simple" "OQS_SIG_alg_sphincs_shake256_192s_robust" "OQS_SIG_alg_sphincs_shake256_192s_simple" "OQS_SIG_alg_sphincs_shake256_256f_robust" "OQS_SIG_alg_sphincs_shake256_256f_simple" "OQS_SIG_alg_sphincs_shake256_256s_robust" "OQS_SIG_alg_sphincs_shake256_256s_simple")


# Print length of algorithms list
echo "There are" ${#List_algo_to_test[@]} "algorithms to test."

# Create ad-hoc directory for all openssl versions
rm -rf testbed
mkdir testbed
cd testbed

 # One directory for each sphincs variant. Each directory contains 2 directories: liboqs and openssl

# Structure of directories:
# testbed
# |
# ---------sphincs1
#          |
#          ---------liboqs
#          |
#          ---------openssl_pq
# |
# ---------sphincs2
#          |
#          ---------liboqs
#          |
#          ---------openssl_pq
# |
# ---------sphincs3
#          |
#          ---------liboqs
#          |
#          ---------openssl_pq

# If the available disk memory is limited, uncomment the cleaning code at the end of the for loop

sudo apt install cmake gcc libtool libssl-dev make ninja-build unzip xsltproc git

for algo in ${List_algo_to_test[@]}; do
	echo "Starting installation procedure for" $algo "."
	cd
	cd testbed
	echo "Creating directories for:" $algo
	rm -rf $algo
	mkdir $algo
	# Entering <algo> folder
	cd $algo
	# Clone liboqs inside "liboqs" folder inside <algo> folder
	echo "Cloning liboqs library"
	git clone --branch master https://github.com/open-quantum-safe/liboqs.git
	# Clone openssl inside "openssl_pq" folder inside <algo> folder
	echo "Cloning openssl_pq library"
	git clone --branch OQS-OpenSSL_1_1_1-stable https://github.com/open-quantum-safe/openssl.git openssl_pq
	cd liboqs
	# Modify line number 4 of alg_support.cmake file
	#replace_string="set(OQS_SIG_DEFAULT \""$algo"\")/"
	#replace_line="4s/.*/$replace_string"
	#echo "Replace line:" $replace_line "inside .CMake/alg_support.cmake file"
	#sed -i "$replace_line" .CMake/alg_support.cmake
	# Create "build" directory and enter it
	mkdir build
	cd build
	# Make liboqs inside <algo>/oqs directory
	# oqs is created automatically by the following commands
	cmake -GNinja -DCMAKE_INSTALL_PREFIX=../../openssl_pq/oqs .. -DOQS_SIG_DEFAULT="$algo"
	echo "Making of liboqs library. This operation may take a while [ninja]"
	ninja >> /dev/null
	ninja install
	# Return to <algo> directory
	cd ../..
	# Go to <algo>/openssl_pq directory
	cd openssl_pq
	# Make openssl library
	echo "Making of openssl library. This operation may take a while [make]"
	./Configure no-shared linux-x86_64 -lm >> /dev/null
	make >> /dev/null
	# If all works here, it directly prepares certificates and keys for the OQS_SIG_DEFAULT algorithm which is <algo>
	# Generate a self-signed root CA certificate with <algo>
	apps/openssl req -x509 -new -newkey oqs_sig_default -keyout sphincs_CA.key -out sphincs_CA.crt -nodes -subj "/CN=oqstest CA" -days 365 -config apps/openssl.cnf
	# Server generates key pair with <algo>
	apps/openssl genpkey -algorithm oqs_sig_default -out sphincs_srv.key
	# Server generates a certificate request and sends it to the CA with <algo>
	apps/openssl req -new -newkey oqs_sig_default -keyout sphincs_srv.key -out sphincs_srv.csr -nodes -subj "/CN=oqstest server" -config apps/openssl.cnf
	# CA generates the signed server certificate
	apps/openssl x509 -req -in sphincs_srv.csr -out sphincs_srv.crt -CA sphincs_CA.crt -CAkey sphincs_CA.key -CAcreateserial -days 365
	echo "Installation procedure for" $algo "algorithm finished."

	echo "Starting testing procedure for" $algo "..."
	# Tests computation with s_time with run_testbed.sh script
	~/tests/run_testbed.sh $algo
	echo "Testing procedure for" $algo "finished."

	echo "Starting cleaning procedure for" $algo "..."
	# Clean before going to the next algorithm
	~/tests/clean_testbed.sh
	cd
	mkdir testbed
	cd testbed
	echo "Cleaning procedure for" $algo "finished."

done
echo "Done."





