import module namespace geo = "http://expath.org/ns/geo";
declare namespace gml="http://www.opengis.net/gml";

geo:as-text(<gml:MultiPoint>
                <gml:Point><gml:pos>1 1</gml:pos></gml:Point>
                <gml:Point><gml:pos>2 2</gml:pos></gml:Point>
              </gml:MultiPoint>)