# mule-notification-service-s ✅

Short description
-----------------
This repository contains a Mule application that exposes an email notification API to send emails (with attachments). The API accepts a JSON payload describing the send operation and SMTP connection information (or you can configure SMTP in properties).

Quick start 🔧
--------------
Prerequisites:
- Java 17
- Mule runtime or Anypoint Studio
- Maven (to build)

Build (optional):
- mvn clean package

Run locally:
- Start the Mule runtime or run the app from Anypoint Studio. The application listens (by default) on port 8083 for API requests.

API: Send Email ✉️
-----------------
Endpoint:
- POST http://localhost:8083/api/v1/notifications/email
- Content-Type: application/json

Example curl (provided):

curl --location 'http://localhost:8083/api/v1/notifications/email' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "send_operation_properties": {
        "fromAddress": "alerts.muleintegration@mule.org.in",
        "toAddresses": ["sample@gmail.com"],
        "subject": "Order Confirmation #12345",
        "body": "Hello, your order has been processed successfully.",
        "contentType": "text/html",
        "ccAddresses": ["sample2@gmail.com"],
        "bccAddresses": ["sample4@gmail.com"],
        "replyToAddresses": "sample@gmail.com",
        "encoding": "UTF-8",
        "attachments": {
            "test data.txt": "<base64-content>",
            "Release_Notes_B2B_1.0_UAT_EDX.docx": "<base64-content>"
        }
    },
    "connection_configuration": {
        "host": "smtp.zoho.in",
        "port": 465,
        "user": "alerts@mule.org.in",
        "password": "testpassword",
        "properties": {
            "mail.smtp.starttls.enable": "true",
            "mail.smtp.connectiontime": "60",
            "mail.smtp.timeout": "60",
            "mail.smtp.writetimeout": "60",
            "mail.debug": "true"
        },
        "connectionTimeout": 30000,
        "readTimeout": 30000,
        "writeTimeout": 30000
    }
}'

Notes & tips 💡
--------------
- Attachments must be provided as base64-encoded values in the `attachments` map (filename -> base64-data).
- The example includes `connection_configuration` inline. For production use, prefer configuring SMTP credentials in secure properties (`src/main/resources/properties/common-local.yaml` or other secrets mechanism).
- The request schema is available at: `src/main/resources/schemas/email-request-schema.json`.

Configuration files
-------------------
- Global Mule config: `src/main/mule/global.xml`
- Main flows: `src/main/mule/mule-notification-service-s.xml`
- App properties: `src/main/resources/properties/`
- DWL helpers: `src/main/resources/dwl/` (transformations like `response.dwl`)

Testing
-------
- MUnit tests under `src/test/munit/` and unit tests under `src/test/java`.

Security / warnings ⚠️
----------------------
- Do not commit real passwords or secrets to version control. The examples in this README are for local/testing only.

Troubleshooting
---------------
- Check Mule logs for errors when sending emails (SMTP connection issues, auth failures, etc).
- Ensure network access to the SMTP server / port.

JSON request schema (summary) 📘
--------------------------------
Below is a compact, human-friendly summary of the request shape. The canonical, full JSON Schema is still available at `src/main/resources/schemas/email-request-schema.json`.

```json
{
  "type": "object",
  "required": ["send_operation_properties", "connection_configuration"],
  "send_operation_properties": {
    "fromAddress": "string (email)",
    "toAddresses": "array[string (email)]",
    "subject": "string",
    "body": "string",
    "contentType": "string (text/plain|text/html, default UTF-8)",
    "attachments": "object (filename -> base64 string)"
  },
  "connection_configuration": {
    "host": "string (hostname)",
    "port": "integer",
    "user": "string",
    "password": "string",
    "properties": "object (mail.* JVM properties)",
    "connectionTimeout/readTimeout/writeTimeout": "integer (ms, optional)"
  }
}
```

> Note: This summary is for readability; the service uses the full schema for validation (see `src/main/resources/schemas/email-request-schema.json`).

Example responses (expanded) ✅
-------------------------------
Success (HTTP 200) — message sent:

```json
{
  "status": "sent",
  "messageId": "<smtp-message-id-or-uuid>",
  "recipients": ["alice@example.com", "bob@example.com"]
}
```

Accepted (HTTP 202) — queued for delivery (async backends):

```json
{
  "status": "queued",
  "queueId": "<uuid>",
  "estimatedDelivery": "2025-12-31T12:00:00Z"
}
```

Validation error (HTTP 400):

```json
{
  "status": "error",
  "error": "validation_failed",
  "details": [
    { "field": "send_operation_properties.toAddresses", "message": "At least one recipient is required" }
  ]
}
```

Unauthorized (HTTP 401):

```json
{
  "status": "error",
  "error": "unauthorized",
  "message": "Invalid credentials or missing API key"
}
```

Rate limited (HTTP 429):

```json
HTTP/1.1 429 Too Many Requests
Retry-After: 60
{
  "status": "error",
  "error": "rate_limited",
  "message": "Too many requests, try again later"
}
```

SMTP/server error (HTTP 502 / 500):

```json
{
  "status": "error",
  "error": "smtp_failure",
  "message": "Unable to deliver message: Authentication failed"
}
```

CI/CD & Deployment notes 🚀
---------------------------
- Build (CI): Run tests and build the deployable with Maven:

```bash
mvn clean package
```

- Mule Standalone / Local deploy:
  - Copy the generated application (artifact under `target/`) into your Mule runtime `apps/` directory or use Anypoint Studio.
  - Restart the runtime or wait for hot-deploy to pick up the artifact.

- CloudHub / Runtime Fabric (example GitHub Actions with deploy job)

Below is a practical GitHub Actions example that runs the build and performs a deploy step only on `main`. It uses **secrets** for credentials. Adjust the deploy command to match your chosen plugin or Anypoint command.

```yaml
name: CI
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK
        uses: actions/setup-java@v4
        with:
          java-version: '17'
      - name: Build
        run: mvn -B clean package

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK
        uses: actions/setup-java@v4
        with:
          java-version: '17'
      - name: Build (artifact)
        run: mvn -B -DskipTests package
      - name: Deploy to CloudHub (Mule Maven Plugin example)
        env:
          ANYPNT_USERNAME: ${{ secrets.ANYPNT_USERNAME }}
          ANYPNT_PASSWORD: ${{ secrets.ANYPNT_PASSWORD }}
          ANYPNT_ENVIRONMENT: ${{ secrets.ANYPNT_ENVIRONMENT }}
          ANYPNT_ORG: ${{ secrets.ANYPNT_ORG }}
        run: |
          mvn org.mule.tools:mule-maven-plugin:deploy \
            -Danypoint.username=${{ env.ANYPNT_USERNAME }} \
            -Danypoint.password=${{ env.ANYPNT_PASSWORD }} \
            -Danypoint.environment=${{ env.ANYPNT_ENVIRONMENT }} \
            -Danypoint.organization=${{ env.ANYPNT_ORG }}
```

Notes:
- Configure the `mule-maven-plugin` in your `pom.xml` (artifactId/groupId and deploy configuration) for the deploy command above to work. Alternatively, you can use Anypoint CLI in the workflow (login with secure secrets and run a CLI deploy command).
- Keep **all** credentials (SMTP, Anypoint, tokens) in the CI provider's secret store; never commit them.
