import module namespace geo = "http://expath.org/ns/geo";
declare namespace gml="http://www.opengis.net/gml";

geo:overlaps(<gml:LineString>
                <gml:pos>1 1</gml:pos>
                <gml:pos>55 99</gml:pos>
                <gml:pos>2 1</gml:pos>
             </gml:LineString>,
             <gml:LineString>
                <gml:posList>
                1 2
                55 0
                </gml:posList>
             </gml:LineString>)