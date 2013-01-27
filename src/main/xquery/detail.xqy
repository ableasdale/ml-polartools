xquery version "1.0-ml";

import module namespace common = "http://www.example.com/common" at "/common.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $uri := xdmp:get-request-field("id");
declare variable $debug := xdmp:get-request-field("debug", "false");
declare variable $doc := doc($uri);

declare function local:overview(){
element div {attribute id {"overview"},
    element h2 {"Overview"},
    element ul {
    element li {element strong {"Date: "}, $doc/PolarHrmData/Date},
    element li {element strong {"Start Time: "}, $doc/PolarHrmData/StartTime},
    element li {element strong {"Length: "}, $doc/PolarHrmData/Length},
    element li {element strong {"Maximum Heartrate: "}, $doc/PolarHrmData/MaxHR},
    element li {element strong {"Resting Heartrate: "}, $doc/PolarHrmData/RestHR},
    element li {element strong {"VO2 Max: "}, $doc/PolarHrmData/VO2max}
    },
    element hr {},
    element h2 {"Data Output Formats"},
    element ul {
        element li {element a {attribute href {concat("/data.xqy?id=",$uri)}, "View XML"}},
        element li {element a {attribute href {concat("/data.xqy?output=json&amp;id=",$uri)}, "View JSON"}}
    }
}
};

common:build-page(
element div {attribute class {"container"},
    common:html-page-header("Detail view"),
    local:overview(),
    if($debug eq "true") then (element textarea {$doc}) else (),
    element div {attribute id {"chart"}, attribute style {"width: 100%; height: 400px"}},       
    common:html-page-footer()
})
