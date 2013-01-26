xquery version "1.0-ml";

import module namespace common = "http://www.example.com/common" at "/common.xqy";

declare namespace zip="xdmp:zip";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
    
declare variable $zip := xdmp:set-server-field("zip", xdmp:get-request-field("zipfile"));
declare variable $manifest := xdmp:zip-manifest($zip);

declare function local:overview(){
<div id="overview">
    <h2>The zip file contains {count($manifest//zip:part)} records</h2>
    <h3>{count($manifest//zip:part/text()[contains(.,".hrm")] )} of these are hrm files (this application currently only processes these)</h3>
    <h3>{count($manifest//zip:part/text()[contains(.,".pdd")] )} of these are pdd files</h3>
    <hr/>
</div>
};

declare function local:processing-options(){
<div id="options">
    <h2>Options</h2>
    <ul>
        <li><p><strong>Generate a csv file</strong> for processing with Excel or Matlab</p></li>
        <li><p><a href="/load-ml.xqy">Load the contents of the Zip into MarkLogic</a> and use the dashboard</p></li>
    </ul>
    <hr/>
    {
    element form {attribute method {"post"}, attribute enctype {"multipart/form-data"}, attribute action {"/csv.xqy"},
    element fieldset {
        element legend {"Generate CSV File:"},
        (: element p {element label {attribute for {"zipfile"}, "Zipfile to upload: "}, element br {}, element input {attribute class {"title"}, attribute type {"file"}, attribute name {"zipfile"}}}, :)
        element p {element input {attribute type {"submit"}, attribute name {"csv"}, attribute value {"Generate CSV"}}} 
    }
}
    
    }
</div>
};

declare function local:get-parts-from-zip-manifest(){
    for $x in xdmp:zip-manifest($zip)//zip:part/text()
    where (fn:ends-with($x, ".hrm"))
    (: order by $x ascending :)
    return $x
    (: return xdmp:zip-get($zip, $x, <options xmlns="xdmp:zip-get">
    	  <format>text</format>
    	</options>) :)
};

(common:build-page(
element div {attribute class {"container"},
    common:html-page-header("Polar Tools - Processing Zip File"),
    local:overview(),
    local:processing-options(),
   (: local:upload-module(), :)       
    common:html-page-footer()
}))