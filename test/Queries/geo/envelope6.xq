import module namespace geo = "http://expath.org/ns/geo";
declare namespace gml="http://www.opengis.net/gml";

geo:envelope(<gml:Polygon>
              <gml:exterior>
                <gml:LinearRing><gml:posList>
                1 1 
                20 1 
                20 20 
                1 20 
                1 1
                </gml:posList></gml:LinearRing>
              </gml:exterior>
              <gml:interior>
                <gml:LinearRing><gml:posList>
                2 2 
                3 2 
                3 3 
                2 3 
                2 2
                </gml:posList></gml:LinearRing>
              </gml:interior>
              <gml:interior>
                <gml:LinearRing><gml:posList>
                10 10 
                20 10
                 20 20 
                 10 20 
                10 10
                </gml:posList></gml:LinearRing>
              </gml:interior>
              </gml:Polygon>)
              