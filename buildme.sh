#!bin/bash

dotnet restore
dotnet test test/products.Tests
dotnet publish src/products/project.json -c release -o $(pwd)/publish/
docker stop products || true && docker rm products || true
docker build -t products publish
docker run -d --name products -p 8001:80 products