exports.handler = async (event) => {
  console.log(`Received customer: ${event.detail.customerId}`);

  return {
    statusCode: 200,
  };
};