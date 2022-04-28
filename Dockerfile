FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine

RUN apk -U upgrade && \
    adduser -u 1001 -D -h /home/appuser appuser

USER 1001
WORKDIR /home/appuser
