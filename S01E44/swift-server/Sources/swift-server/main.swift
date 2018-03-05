import Curassow
import Inquiline


serve { request in
    return Response(.ok, contentType: "text/plain", content: "Hello World")
}
