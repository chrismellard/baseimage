FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine

RUN apk -U upgrade

RUN apk add --no-cache python3
