xquery version "1.0-ml";

import module namespace common = "http://www.example.com/common" at "/common.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function local:upload-module(){
element form {attribute method {"post"}, attribute enctype {"multipart/form-data"}, attribute action {"/process-zip.xqy"},
    element fieldset {
        element legend {"Upload polar zipfile:"},
        element p {element label {attribute for {"zipfile"}, "Zipfile to upload: "}, element br {}, element input {attribute class {"title"}, attribute type {"file"}, attribute name {"zipfile"}}},
        element p {element label {attribute for {"collection"}, "Collection Name: "}, element br {}, element input {attribute class {"title"}, attribute type {"text"}, attribute name {"collection"}}},
        element p {element input {attribute type {"submit"}, attribute name {"upload"}, attribute value {"Process Zip"}}},
        if (string-length(xdmp:get-session-field("validation-error")) gt 0)
        then (element div {attribute class {"error"}, xdmp:get-session-field("validation-error")})
        else ()
    }
}
};

declare function local:previous-collections(){
element div {attribute class {"previous-collections"},
    element hr {},
    element h2 {"Available Collections:"},
    if (count(cts:collections()) gt 0)
    then (
    element ul {
    for $x in cts:collections()
    return element li {element a {attribute href{concat("/dashboard.xqy?change-collection=",$x)}, $x}}
    }
    ) else (element p {element em {"You currently have no collections available"}}),
    element hr {}
}
};

common:build-page(
element div {attribute class {"container"},
    common:html-page-header("Polar ProTrainer Tools : Home"),
    local:previous-collections(),
    local:upload-module(),       
    common:html-page-footer()
})