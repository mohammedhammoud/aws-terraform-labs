const http = require("http");

const server = http.createServer((req, res) => {
    if (req.url === "/health") {
        res.writeHead(200, { "Content-Type": "text/plain" });
        return res.end("ok");
    }

    if (req.url === "/work") {
        let result = 0;

        for (let i = 0; i < 20_000_000; i++) {
            result += Math.sqrt(i);
        }

        res.writeHead(200, { "Content-Type": "application/json" });
        return res.end(
            JSON.stringify({
                status: "done",
                result,
            })
        );
    }

    res.writeHead(404, { "Content-Type": "text/plain" });
    res.end("not found");
});

server.listen(80, "0.0.0.0", () => {
    console.log("server listening on port 80");
});