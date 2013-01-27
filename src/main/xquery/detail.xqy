xquery version "1.0-ml";

import module namespace common = "http://www.example.com/common" at "/common.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $uri := xdmp:get-request-field("id");

declare function local:overview(){
<h2>Overview</h2>
};

common:build-page(
element div {attribute class {"container"},
    common:html-page-header("Detail view"),
    local:overview(),
    element textarea {doc($uri)},
    element div {attribute id {"chart"}, attribute style {"width: 100%; height: 400px"}},       
    common:html-page-footer()
})
