# Verdaccio Tests for OpenUPM

Requirements
- npm and yarn
- [bats](https://github.com/sstephenson/bats)
    ```bash
    git clone https://github.com/sstephenson/bats.git
    cd bats
    ./install.sh /usr/local
    ```
- [minio](https://github.com/minio/minio)
    ```
    wget https://dl.min.io/server/minio/release/linux-amd64/minio
    chmod +x minio
    ```

Build

```bash
# Checkout verdaccio
git clone --single-branch --branch openupm git@github.com:favoyang/verdaccio.git

# Checkout monorepo
git clone --single-branch --branch monorepo git@github.com:favoyang/monorepo.git

# Checkout verdaccio-storage-proxy
git clone git@github.com:openupm/verdaccio-storage-proxy.git

# Install npm libs
nvm use
npm install

# Build verdaccio
./build-all.sh
```

Run tests

```bash
nvm use
./run-tests.sh
```
