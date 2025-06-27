import http.server
import socketserver
import socket
from http import HTTPStatus


class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        message = "V1:Hello world, I'm host: " + socket.gethostname()
        self.wfile.write(message.encode())


if __name__ == "__main__":
    httpd = socketserver.TCPServer(('', 8000), Handler)
    print("Server started on port 8000")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("Server stopping...")
    finally:
        httpd.server_close()
        print("Server stopped.")