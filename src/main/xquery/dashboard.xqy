xquery version "1.0-ml";

import module namespace common = "http://www.example.com/common" at "/common.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function local:table(){
<table>
<tr>
<th>Date</th>
<th>Start Time</th>
<th>Length</th>
<th>Details</th>
</tr>
{
for $i in doc()
order by $i/polar/Date
return 
<tr>
<td>{$i/PolarHrmData/Date}</td>
<td>{$i/PolarHrmData/StartTime}</td>
<td>{$i/PolarHrmData/Length}</td>
<td>{
element a {attribute href { fn:concat("/detail.xqy?id=", xdmp:node-uri($i)) }}, "Details"
}
</td>
</tr>
}
</table>};


common:build-page(
element div {attribute class {"container"},
    common:html-page-header("Polar"),
    element div {local:table()},
    common:html-page-footer()
})
