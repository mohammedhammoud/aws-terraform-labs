exports.handler = async (event) => {
  console.log(`Received order: ${event.detail.orderId}`);

  return {
    statusCode: 200,
  };
};