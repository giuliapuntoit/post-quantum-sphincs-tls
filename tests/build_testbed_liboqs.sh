#!/bin/bash

# Builds liboqs and openssl libraries to use <algo> as default algorithm.
# By default <algo> is OQS_SIG_alg_sphincs_haraka_128f_robust.

# Run all liboqs tests for all sphincs variants with the run_testbed_liboqs script


# Enter home directory
cd 

# Algorithms to set by default
algo="OQS_SIG_alg_sphincs_haraka_128f_robust"

# Create ad-hoc directory for all openssl versions
rm -rf testbed_for_liboqs_tests
mkdir testbed_for_liboqs_tests
cd testbed_for_liboqs_tests

# Structure:
# testbed_for_liboqs_tests
# |
# ---------openssl_for_liboqs_tests
#          |
#          ---------liboqs
#          |
#          ---------openssl_pq

sudo apt install cmake gcc libtool libssl-dev make ninja-build unzip xsltproc git

cd
cd testbed_for_liboqs_tests
echo "Creating directory openssl_for_liboqs_tests for:" $algo
rm -rf openssl_for_liboqs_tests
mkdir openssl_for_liboqs_tests
# Entering openssl_for_liboqs_tests folder
cd openssl_for_liboqs_tests
# Clone liboqs inside "liboqs" folder inside openssl_for_liboqs_tests folder
echo "Cloning liboqs library"
git clone --branch master https://github.com/open-quantum-safe/liboqs.git
# Clone openssl inside "openssl_pq" folder inside openssl_for_liboqs_tests folder
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
# Make liboqs inside openssl_pq/oqs directory
# oqs is created automatically by the following commands)
cmake -GNinja -DCMAKE_INSTALL_PREFIX=../../openssl_pq/oqs .. -DOQS_SIG_DEFAULT="$algo"
echo "Making of liboqs library. This operation may take a while [ninja]"
ninja >> /dev/null
ninja install >> /dev/null
# Return to openssl_for_liboqs_tests directory
cd ../..
# Go to openssl_for_liboqs_tests/openssl_pq directory
cd openssl_pq
# Make openssl library
echo "Making of openssl library. This operation may take a while [make]"
./Configure no-shared linux-x86_64 -lm
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

echo "Done."
