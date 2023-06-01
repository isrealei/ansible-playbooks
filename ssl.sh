yum -y update
yum install -y make gcc perl-core pcre-devel wget zlib-devel
wget https://ftp.openssl.org/source/openssl-1.1.1k.tar.gz
tar -xzvf openssl-1.1.1k.tar.gz
cd openssl-1.1.1k
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib no-shared zlib-dynamic
make
make test
make install
echo "export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64" >  /etc/profile.d/openssl.sh
source /etc/profile.d/openssl.sh
openssl version