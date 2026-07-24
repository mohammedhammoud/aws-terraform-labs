from datetime import datetime, timezone
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import os

LOG_FILE = "/var/log/observability-app.log"
WEB_ROOT = "/opt/observability-app"


class Handler(SimpleHTTPRequestHandler):
    def log_message(self, format: str, *args: object) -> None:
        message = (
            f"{datetime.now(timezone.utc).isoformat()} "
            f'{self.client_address[0]} '
            f"{format % args}\n"
        )

        with open(LOG_FILE, "a", encoding="utf-8") as log:
            log.write(message)


os.chdir(WEB_ROOT)

server = ThreadingHTTPServer(("0.0.0.0", 80), Handler)
server.serve_forever()