xquery version "1.0-ml";

doc(xdmp:get-request-field("id"))

(:
(xdmp:set-response-content-type("application/csv"),
xdmp:add-response-header("Content-Disposition", fn:concat("attachment; filename=", $filename)),
csv:generate-document($zip))
:)