import module namespace geo = "http://expath.org/ns/geo";
declare namespace gml="http://www.opengis.net/gml";

geo:difference(<gml:MultiGeometry>
                <gml:geometryMember>
                <gml:LineString><gml:pos>1 1</gml:pos><gml:pos>2 1</gml:pos></gml:LineString>
                </gml:geometryMember>
                <gml:geometryMember>
                <gml:Point><gml:pos>1 4</gml:pos></gml:Point>
                </gml:geometryMember>
                <gml:geometryMembers>
                <gml:LineString><gml:pos>100 200</gml:pos><gml:pos>100 1</gml:pos></gml:LineString>
                <gml:Polygon>
                    <gml:exterior>
                    <gml:LinearRing><gml:posList>10 20 11 20 11 21 10 21 10 20</gml:posList></gml:LinearRing>
                    </gml:exterior>
                </gml:Polygon>
                </gml:geometryMembers>
              </gml:MultiGeometry>,
             <gml:LineString>
                <gml:posList>
                100 100
                100 50
                </gml:posList>
             </gml:LineString>)