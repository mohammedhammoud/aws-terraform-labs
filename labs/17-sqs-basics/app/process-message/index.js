exports.handler = async (event) => {
  console.log("SQS event received:", JSON.stringify(event, null, 2))

  for (const record of event.Records ?? []) {
    console.log(`Processing message ${record.messageId}: ${record.body}`)
  }
}
