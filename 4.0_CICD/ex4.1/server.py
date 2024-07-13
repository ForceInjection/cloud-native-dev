import http.server
import socketserver
import socket
from http import HTTPStatus


class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        message = "V2:Hello world, I'm host: " + socket.gethostname()
        self.wfile.write(message.encode())


if __name__ == "__main__":
    httpd = socketserver.TCPServer(('', 8000), Handler)
    
    httpd.serve_forever()
    print("Server started.")

    httpd.server_close()
    print("Server stopped.")