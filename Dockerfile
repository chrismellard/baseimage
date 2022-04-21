FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine

RUN apk update && \
    apk upgrade
