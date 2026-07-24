exports.handler = async (event) => {
    return {
        originalValue: event.value,
        processedValue: event.value * 2,
        message: "Value processed successfully",
    };
};