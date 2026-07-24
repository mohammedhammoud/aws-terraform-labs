exports.handler = async (event) => {
    const value = event.value;

    return {
        valid: typeof value === "number" && value > 0,
        value,
    };
};