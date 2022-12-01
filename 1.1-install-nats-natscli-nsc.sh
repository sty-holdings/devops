#!/bin/bash
#
# This will install NATS, NATS CLI, and NSC. Additionally, it will create the operator account
#

cd $HOME
mkdir nats
cd $HOME/nats

# NATS Server
echo "==> Installing NATS Server"
curl -L https://github.com/nats-io/nats-server/releases/download/v2.9.8/nats-server-v2.9.8-linux-386.zip -o nats-server-v2.9.8.zip

unzip nats-server-v2.9.8.zip -d nats-server

sudo cp "$HOME/nats/nats-server/nats-server-v2.9.8-linux-386/nats-server" /usr/bin/.

# NATS CLI
echo "==> Installing NATS CLI"
curl -L https://github.com/nats-io/natscli/releases/download/v0.0.35/nats-0.0.35-linux-386.zip -o nats-cli-v0.0.35.zip

unzip nats-cli-v0.0.35.zip -d nats-cli

sudo cp "$HOME/nats/nats-cli/nats-0.0.35-linux-386/nats" /usr/bin/.

# NATS NCS
echo "==> Installing NSC"
curl -L https://github.com/nats-io/nsc/releases/download/2.7.4/nsc-linux-386.zip -o nsc.7.4.zip

unzip nsc.7.4.zip -d nsc

sudo cp "$HOME/nats/nsc/nsc" /usr/bin/.

echo "==> Creating NSC operator"
nsc add operator --generate-signing-key --sys --name styh

nsc edit operator --require-signing-keys --account-jwt-server-url "nats://0.0.0.0:4222"