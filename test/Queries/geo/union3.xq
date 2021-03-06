import module namespace geo = "http://expath.org/ns/geo";
declare namespace gml="http://www.opengis.net/gml";

geo:union(<gml:MultiPoint>
                <gml:Point><gml:pos>1 1</gml:pos></gml:Point>
                <gml:Point><gml:pos>10 10</gml:pos></gml:Point>
                <gml:Point><gml:pos>2 2</gml:pos></gml:Point>
              </gml:MultiPoint>,
              <gml:LinearRing><gml:posList>0 0 20 20 20 30 0 20 0 0</gml:posList></gml:LinearRing>
              )