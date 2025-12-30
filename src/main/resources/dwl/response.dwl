%dw 2.0
output application/json
---
{
  status: "success",
  statusCode: 200,
  message: "Email Sent successfully",
  corelationID: vars.correlationID,
  timestamp: now() >> "IST"
}