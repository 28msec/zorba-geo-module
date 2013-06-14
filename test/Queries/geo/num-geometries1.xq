import module namespace geo = "http://zorba.io/modules/geo";
declare namespace gml="http://www.opengis.net/gml";

geo:num-geometries(<gml:MultiPoint>
                <gml:Point><gml:pos>1 1</gml:pos></gml:Point>
                <gml:Point><gml:pos>1 1</gml:pos></gml:Point>
                <gml:Point><gml:pos>1 1</gml:pos></gml:Point>
              </gml:MultiPoint>
              )