const { S3Client, GetObjectCommand, PutObjectCommand } = require("@aws-sdk/client-s3")

const s3 = new S3Client({})

const streamToString = async (stream) => {
  const chunks = []

  for await (const chunk of stream) {
    chunks.push(Buffer.from(chunk))
  }

  return Buffer.concat(chunks).toString("utf-8")
}

exports.handler = async (event) => {
  console.log("S3 event received:", JSON.stringify(event, null, 2))

  const record = event.Records?.[0]

  if (!record) {
    return {
      statusCode: 400,
      body: "No S3 record found",
    }
  }

  const bucket = record.s3.bucket.name
  const inputKey = decodeURIComponent(record.s3.object.key.replace(/\+/g, " "))

  const inputObject = await s3.send(
    new GetObjectCommand({
      Bucket: bucket,
      Key: inputKey,
    }),
  )

  const inputBody = await streamToString(inputObject.Body)
  const outputKey = inputKey.replace(/^input\//, "output/")

  await s3.send(
    new PutObjectCommand({
      Bucket: bucket,
      Key: outputKey,
      Body: `Processed by Lambda:\n${inputBody}`,
      ContentType: "text/plain",
    }),
  )

  return {
    statusCode: 200,
    body: `Wrote ${outputKey}`,
  }
}