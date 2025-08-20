import base64
import sys
from io import StringIO, BytesIO

try:
    # Python 3
    from urllib.parse import urlencode

    # Convert bytes to str, if required
    def convert_str(s):
        try:
            return s.decode('utf-8')
        except UnicodeDecodeError:
            return s
except:
    # Python 2
    from urllib import urlencode

    # No conversion required
    def convert_str(s):
        return s


def response(app, event, context):
    sr = StartResponse()
    output = app(environ(event, context), sr)
    return sr.response(output)


class StartResponse:
    def __init__(self):
        self.status = 500
        self.headers = []
        self.body = StringIO()

    def __call__(self, status, headers, exc_info=None):
        self.status = status.split()[0]
        self.headers[:] = headers
        return self.body.write

    def response(self, output):
        headers = dict(self.headers)
        if headers.get('Content-Type') in ['image/png', 'image/gif', 'application/octet-stream']:
            is_base64 = True
            body = base64.b64encode(b''.join(output)).decode('ascii')
        else:
            is_base64 = False
            body = self.body.getvalue() + ''.join(map(convert_str, output))
        return {
            'statusCode': str(self.status),
            'headers': headers,
            'body': body,
            'isBase64Encoded': is_base64
        }


def environ(event, context):
    # Detect payload format version
    version = event.get("version")

    if version == "2.0":
        method = event.get("requestContext", {}).get("http", {}).get("method", "GET")
        path = event.get("rawPath", "/")
        query_string = event.get("rawQueryString", "")
        headers = event.get("headers", {})
        body = event.get("body", "")
        if event.get("isBase64Encoded", False):
            body = base64.b64decode(body)
        else:
            body = body.encode("utf-8")
    else:
        # Assume v1.0 (REST API)
        method = event["httpMethod"]
        path = event["path"]
        query_string = urlencode(event.get("queryStringParameters") or {})
        headers = event.get("headers", {})
        body = event.get("body", "")
        body = bytes(body, "utf-8")

    environ = {
        "REQUEST_METHOD": method,
        "SCRIPT_NAME": "",
        "PATH_INFO": path,
        "QUERY_STRING": query_string,
        "REMOTE_ADDR": "127.0.0.1",
        "CONTENT_LENGTH": str(len(body)),
        "HTTP": "on",
        "SERVER_PROTOCOL": "HTTP/1.1",
        "wsgi.version": (1, 0),
        "wsgi.input": BytesIO(body),
        "wsgi.errors": sys.stderr,
        "wsgi.multithread": False,
        "wsgi.multiprocess": False,
        "wsgi.run_once": False,
    }

    # Normalize headers
    for k, v in headers.items():
        k = k.upper().replace("-", "_")
        if k == "CONTENT_TYPE":
            environ["CONTENT_TYPE"] = v
        elif k == "HOST":
            environ["SERVER_NAME"] = v
        elif k == "X_FORWARDED_FOR":
            environ["REMOTE_ADDR"] = v.split(", ")[0]
        elif k == "X_FORWARDED_PROTO":
            environ["wsgi.url_scheme"] = v
        elif k == "X_FORWARDED_PORT":
            environ["SERVER_PORT"] = v
        environ["HTTP_" + k] = v

    return environ
