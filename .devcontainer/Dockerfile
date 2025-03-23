FROM mcr.microsoft.com/vscode/devcontainers/base:latest

RUN apt-get update && apt-get install -y lua5.4 luarocks
RUN luarocks install lpeg
RUN luarocks install busted

WORKDIR /workspace
