set -ex

wget https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2
tar -xvjf htslib-1.9.tar.bz2
cd htslib-1.9 && ./configure --prefix=/usr && make && sudo make install
