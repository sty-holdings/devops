# NATS Server
curl -L https://github.com/nats-io/nats-server/releases/download/v2.9.8/nats-server-v2.9.8-linux-386.zip -o nats-server-v2.9.8.zip

unzip nats-server-v2.9.8.zip -d nats-server

sudo cp "$HOME/nats-server/nats-server-v2.9.8-linux-386/nats-server" /usr/bin/.

rm -rf "$HOME/nats-server"

# NATS CLI
curl -L https://github.com/nats-io/natscli/releases/download/v0.0.35/nats-0.0.35-linux-386.zip -o nats-cli-v0.0.35.zip

unzip nats-cli-v0.0.35.zip -d nats-cli

sudo cp "$HOME/nats-cli/nats-0.0.35-linux-386/nats" /usr/bin/.

rm -rf "$HOME/nats-cli"

# NATS NCS
curl -L https://github.com/nats-io/nsc/releases/download/2.7.4/nsc-linux-386.zip -o nsc.7.4.zip

unzip nsc.7.4.zip -d nsc

sudo cp "$HOME/nsc/nsc" /usr/bin/.

rm -rf "$HOME/nsc"

nsc add operator --generate-signing-key --sys --name styh

nsc edit operator --require-signing-keys --account-jwt-server-url "nats://0.0.0.0:4222"
