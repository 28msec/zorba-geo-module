import module namespace geo = "http://expath.org/ns/geo";
declare namespace gml="http://www.opengis.net/gml";

geo:num-points(<gml:LineString>
                    <gml:pos>1 1</gml:pos>
                    <gml:pos>2 1</gml:pos>
                    <gml:pos>20 2</gml:pos>
                    <gml:pos>1 1</gml:pos>
                </gml:LineString>)