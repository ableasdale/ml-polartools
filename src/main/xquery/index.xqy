xquery version "1.0-ml";

import module namespace common = "http://www.example.com/common" at "/common.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function local:upload-module(){
element form {attribute method {"post"}, attribute enctype {"multipart/form-data"}, attribute action {"/process-zip.xqy"},
    element fieldset {
        element legend {"Upload polar zipfile:"},
        element p {element label {attribute for {"zipfile"}, "Zipfile to upload: "}, element br {}, element input {attribute class {"title"}, attribute type {"file"}, attribute name {"zipfile"}}},
        element p {element input {attribute type {"submit"}, attribute name {"upload"}, attribute value {"Process Zip"}}} 
    }
}
};

declare function local:previous-collections(){
element div {attribute class {"previous-collections"},
    element hr {},
    element h2 {"Previous Collections (TODO)"},
    element hr {}
}
};

common:build-page(
element div {attribute class {"container"},
    common:html-page-header("Polar Tools"),
    local:previous-collections(),
    local:upload-module(),       
    common:html-page-footer()
})