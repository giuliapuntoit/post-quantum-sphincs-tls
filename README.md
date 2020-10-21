# Testbed SPHINCS+ - TLS

This testbed aims to test the SPHINCS+ framework inside the TLS context. 

First, SPHINCS+ along with all its variants is tested and compared to standard signature schemes: RSA and ECDSA. This is done exploiting the liboqs testsuite library.

Second, SPHINCS+ is used as the signature algorithm in the authentication phase of TLS handshake procedure. The performance of TLS handshakes made with SPHINCS+ are compared to TLS handshakes performed with standard signature algorithms. 

## Project motivation

In the last decades, post-quantum cryptography has become an active area of research. In 2016, NIST started the post-quantum crypto project in order to encourage the development of new post-quantum signature and key exchange algorithms. SPHINCS+ is one of the post-quantum signature schemes proposed to NIST. Since it is a new cryptographic algorithm, it has not been fully tested yet. Moreover, just few works tested SPHINCS+ in a real-world use case scenario.

In this project we want to test SPHINCS+ inside the TLS protocol, in order to provide some results about the overhead introduced by this post-quantum signature algorithm with respect to standard cryptography algorithms.

## Features

The testbed is divided into 2 main parts:

* liboqs: the scripts `build_testbed_liboqs.sh`, `run_testbed_liboqs.sh`, `run_testbed_liboqs_rsaecdsa.sh` and `clean_testbed_liboqs.sh` focus on the performance evaluation of SPHINCS+. For completeness, also the most common post-quantum key exchange mechanisms are evaluated.
* openssl: the scripts `build_testbed.sh`, `build_testbed_single_variant.sh`, `run_testbed.sh`, `run_testbed_rsaecdsa.sh` and `clean_testbed.sh` focus on the performance evaluation of SPHINCS+ inside the OpenSSL library.

See the How to use section to have a description of the specific functionalities provided by each script.

## How to use

In this section we are going to describe the goal of each .sh script. 
All outputs provided by this testbed are organized inside the **results** directory, contained inside the **tests** directory which contains all scripts. They will be described in the next section.

### liboqs

With this part both liboqs and openssl libraries are installed. Also the latter is installed because standard cryptographic algorithms can not be tested through the liboqs testsuite, so the openssl testsuite need to be used (for RSA and ECDSA).

* `build_testbed_liboqs.sh`: downloads both liboqs and openssl libraries inside the testbed\_for\_liboqs\_tests directory, and compiles them. The liboqs is compiled to have as default signature algorithm SPHINCS+-Haraka-128f-robust. This is used to issue X.509 certificates. In this way if the library needs to be used afterward, it is ready to be tested. 
* `run_testbed_liboqs.sh`: runs the test suites provided by the liboqs library for post-quantum algorithms. All SPHINCS+ variants are tested with the `test_sig` script inside liboqs. Moreover, post-quantum KEMs like BIKE, Frodo and NTRU are tested with the `test_kem` script inside liboqs. These algorithms are evaluated because after having found the best one, it will be used inside the OpenSSL related tests for evaluating the performance of a TLS handshake with both post-quantum signature and key exchange algorithms.
* `run_testbed_liboqs_rsaecdsa.sh`: runs multiple times (10) the openssl speed command for evaluating the performance of RSA2048 and ECDSA384 algorithms. The command is executed multiple times in order to have more precise results, computing the mean and the standard deviation of the obtained values.
* `clean_testbed_liboqs.sh`: deletes the testbed\_for\_liboqs\_tests directory.

### OpenSSL

* **`build_testbed.sh`**: this is the most important script in the testbed of this SPHINCS+ - TLS project. First it iterates on the list of all SPHINCS+ variants (36). It compiles the liboqs with the current variant as the default signature algorithm. Then both the liboqs and openssl libraries are built. It then calls the `run_testbed.sh`script passing as parameter the current SPHINCS+ variant. Then, if the memory of the current machine is not enough to support multiple copies of the liboqs and openssl libraries, it calls the `clean_testbed.sh` script. Those libraries have to be rebuilt for each SPHINCS+ variant since the implementation of SPHINCS+ into OpenSSL is not available yet. The only way to test it into the TLS scenario is to compile the liboqs library with SPHINCS+ as the default signature algorithm.
* `build_testbed_single_variant.sh`: support script which enables to build the liboqs and openssl libraries to select as the default signature algorithm the one specificed in the command line as first parameter. The algorithm has to be specified in the form OQS\_SIG\_alg\_sphincs\_haraka\_128f\_robust.
* `run_testbed.sh`: this script tests a single SPHINCS+ variant, passed as first parameter by command line. It launches a TLS server and evaluates the performance of the TLS handshake with the `s_time` command, multiple times (10). For each SPHINCS+ variant, the TLS handshake is performed with the Diffie-Hellman key exchange and with the NTRU hps2048509 post-quantum key exchange algorithm. This is the post-quantum key exchange algorithm chosen since it was the most efficient post-quantum KEM among the ones tested by the `run_testbed_liboqs.sh` script.
* `run_testbed_rsaecdsa.sh`: it evaluates the performances of TLS handshakes performed with RSA2048 and ECDSA384 signature algorithms. It can be used to use as target directory the one specified by command line. For each signature algorithm, it creates inside openssl the keys and the X.509 certificates, and then iterates multiple times (10) executing the `s_time` command.
* `clean_testbed.sh`: deletes the testbed directory.

## Output

The output files produced by this testbed are contained inside the ~/tests/results folder. All files related to the first part of the testbed, the one described in the liboqs section, are in the format `output_liboqs_*.txt`.
All files related to the second part of the testbed, the one focusing on TLS integration, are in the format `output_tls_s_time_*.txt`.

* `output_liboqs_kem.txt` contains the performance values for encapsulating and decapsulating keys for the selected post-quantum KEM algorithms.
* `output_liboqs_sig.txt` contains the performance values for the key generation, sign and verify operations for post-quantum authentication mechanisms (SPHINCS+).
* `output_liboqs_std_sig.txt` contains the performance values for sign and verify operations for standard signature algorithms (RSA2048 and ECDSA384).
* `output_tls_s_time.txt` contains the statistics for TLS handshakes performed with SPHINCS+ as the signature algorithm inside the authentication phase of the handshake. 
* `output_tls_s_time_rsaecdsa.txt` contains the statistics for TLS handshakes performed with RSA2048 and ECDSA384 as the signature algorithms inside the authentication phase of the handshake.

For now, the content of these files is the copy of the ouput the exploited test commands of the liboqs and openssl libraries.

## Installation

In order to use this testbed, download and install it into home directory (~). That is because some scripts use absolute paths to work.
In order to change this behaviour the paths inside the scripts could be changed.
The path for one of the scripts should be ~/tests/script.sh.

## API reference

This testbed relies on the [OpenSSL](https://github.com/open-quantum-safe/openssl) library, version 1.1.1 and on the [liboqs](https://github.com/open-quantum-safe/liboqs) library.

These libraries are cloned at runtime, installing and building the last available versions.

## Future work

Future work for this testbed: 

* Improve the readability of the output produced by the `run_*.sh` scripts, in order to produce a .csv output instead of a .txt file, which can be automatically manipulated in order to compute the desired statistics.
* Avoid the compilation of liboqs and openssl libraries in order to set manually one of the SPHINCS+ variants as the default signature algorithm. This will be possible when the OpenSSL library will fully implement all SPHINCS+ variants directly. In that scenario, only one compilation of the libraries is necessary in order to test all variants with TLS handshakes.
* Avoid to clone the liboqs and openssl repository at each time, but performing a check of the last available version and download it only if it is different from the already installed one.
* Improve the management of paths, replacing input and output absolute path with relative paths.

## Credits

This project was developed for the *Computer System Security* course of Politecnico di Torino, Italy. The code was developed by [Giulia Milan](https://www.linkedin.com/in/giulia-milan-a86169172/), under the supervision of Eng. [Ignazio Pedone](https://scholar.google.com.sg/citations?user=jfwzxG8AAAAJ&hl=th) and Professor [Antonio Lioy](https://security.polito.it/~lioy/).

## License 

MIT open license.

