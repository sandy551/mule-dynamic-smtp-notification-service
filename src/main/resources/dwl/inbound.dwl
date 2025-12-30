%dw 2.0
output application/json
---
{
    "method": attributes.method,
    "uriPath": attributes.requestPath,
    "protocolVersion": attributes.version,
    "clientIpAddress": attributes.remoteAddress,
    "hostHeader": attributes.headers.host,
    "authHeader": attributes.headers.authorization default "N/A",
    "requestTimestamp": now() as String {
        format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    },
    "correlationId": correlationId default uuid(),
    "contentType": attributes.headers."content-type",
    "contentLength": attributes.headers."content-length",
}