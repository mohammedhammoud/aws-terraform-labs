import {
  CloudWatchClient,
  PutMetricDataCommand,
} from "@aws-sdk/client-cloudwatch";

const cloudwatch = new CloudWatchClient({});

export const handler = async () => {
  await cloudwatch.send(
    new PutMetricDataCommand({
      Namespace: "Lab29",
      MetricData: [
        {
          MetricName: "RequestProcessed",
          Value: 1,
          Unit: "Count",
        },
      ],
    }),
  );

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "ok",
      timestamp: new Date().toISOString(),
    }),
  };
};