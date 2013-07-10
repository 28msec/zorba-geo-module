xquery version "1.0";

(:
 : Copyright 2006-2009 The FLWOR Foundation.
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 : http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
:)

(:~
 : <p>Function library providing geo processing using Simple Features api API GMLSF format.
 : It uses the GEOS third party library, license LGPL. Version 3.2.2 or above is required.</p>
 : <p/>
 : <p>The data format supported is GML SF profile 0/1.
 : This is a subset of GML, and covers the basic geometries of Point, Line and Surface and collections of those.
 : GMLSF nodes have the namespace "http://www.opengis.net/gml".</p>
 : <p/>
 : <p>Possible GMLSF geometric structures are:</p>
 : <p><dl>
 :  <dt><b>Point</b></dt>
 :  <pre class="ace-static" ace-mode="xquery"><![CDATA[<gml:Point [srsDimension='2|3']?>
 :    <gml:pos [srsDimension='2|3']?>double_x double_y </gml:pos>
 :  </gml:Point>]]></pre>
 :  <dt><b>LineString</b></dt>
 :  <pre class="ace-static" ace-mode="xquery"><![CDATA[<gml:LineString [srsDimension='2|3']?>
 :    <gml:posList [srsDimension='2|3']?> double_x1 double_y1 double_x2 double_y2 ... </gml:posList>
 :  </gml:LineString>]]></pre>
 :  <dt><b>Curve</b></dt>
 :  <pre class="ace-static" ace-mode="xquery"><![CDATA[<gml:Curve [srsDimension='2|3']?>
 :    <gml:segments>
 :    [<gml:LineStringSegment interpolation="linear" [srsDimension='2|3']?>
 :       <gml:posList [srsDimension='2|3']?> double_x1 double_y1 double_x2 double_y2 ... </gml:posList>;
 :     <gml:LineStringSegment>]*
 :    </gml:segments>
 :  </gml:Curve>]]></pre>
 :  <dt><b>LinearRing</b></dt>
 :  <pre class="ace-static" ace-mode="xquery"><![CDATA[<gml:LinearRing [srsDimension='2|3']?>
 :    <gml:posList [srsDimension='2|3']?> double_x1 double_y1 double_x2 double_y2 ... </gml:posList>
 :  </gml:LinearRing>]]></pre>
 :  <dt><b>Surface</b></dt>
 :  <pre class="ace-static" ace-mode="xquery"><![CDATA[<gml:Surface [srsDimension='2|3']?>
 :    <gml:patches>
 :    [<gml:PolygonPatch [srsDimension='2|3']?>
 :       <gml:exterior>
 :         <gml:LinearRing> ... </gml:LinearRing>
 :       </gml:exterior>
 :       <gml:interior>
 :         <gml:LinearRing> ... </gml:LinearRing>
 :       </gml:interior>]*
 :     </gml:PolygonPatch>]*
 :    </gml:patches>
 :  </gml:Surface>]]></pre>
 :  <dt><b>Polygon</b></dt>
 :  <pre class="ace-static" ace-mode="xquery"><![CDATA[<gml:Polygon [srsDimension='2|3']?>
 :    <gml:exterior>
 :      <gml:LinearRing> ... </gml:LinearRing>
 :    </gml:exterior>
 :    [<gml:interior>
 :       <gml:LinearRing> ... </gml:LinearRing>
 :     </gml:interior>]*
 :  </gml:Polygon>]]></pre>
 :  <dt><b>MultiPoint</b></dt>
 :  <pre class="ace-static" ace-mode="xquery"><![CDATA[<gml:MultiPoint [srsDimension='2|3']?>
 :    [<gml:Point> ... </gml:Point>]*
 :  </gml:MultiPoint>]]></pre>
 :  <dt><b>MultiCurve</b></dt>
 :  <pre class="ace-static" ace-mode="xquery"><![CDATA[<gml:MultiCurve [srsDimension='2|3']?>
 :    [<gml:LineString> ... </gml:LineString>]*
 :  </gml:MultiCurve>]]></pre>
 :  <dt><b>MultiSurface</b></dt>
 :  <pre class="ace-static" ace-mode="xquery"><![CDATA[<gml:MultiSurface [srsDimension='2|3']?>
 :    [<gml:Polygon> ... </gml:Polygon>]*
 :  </gml:MultiSurface>
 :  ]]></pre>
 :  <dt><b>MultiGeometry (this is from GML 3 schema)</b></dt>
 :  <pre class="ace-static" ace-mode="xquery"><![CDATA[<gml:MultiGeometry [srsDimension='2|3']?>
 :     [<gml:geometryMember>
 :          ...one geometry...
 :     </gml:geometryMember>]*
 :    [<gml:geometryMembers>
 :      ...a list of geometries...
 :    </gml:geometryMembers>]?
 :  </gml:MultiGeometry>]]></pre>
 : </dl></p>
 : <p>Note: When using gml:posList, it is possible to replace this element with a list of gml:pos.</p>
 : <p>Note: XLink referencing is not supported.</p>
 : <p>Note: The <i>srsDimension</i> optional attribute specifies the coordinate dimension. The default value is 2 (for 2D).
 :    Another possible value is 3 (for 3D) in which case every point has to have three double values (x, y, z).
 :    This is an extension borrowed from GML 3 spec.</p> 
 : <p>The operations made on 3D objects work only on x-y coordinates, the z coordinate is not taken into account.
 : When returning the result, the original z-coordinates of the points are preserved.
 : For computed points, the z-coordinate is interpolated.</p>
 : <p/>
 : <p>The coordinates values have to be in cartesian coordinates, not in polar coordinates. 
 : Converting between coordinate systems and doing projections from polar to cartesian is outside the scope of this geo module.</p> 
 : <p/>
 : <p>For operations between two geometries, the DE-9IM matrix is used. The DE-9IM matrix is defined like this:</p>
 : <table>
 :	<tr>
 :		 <td></td>
 :		 <td><b>Interior</b></td>
 :		 <td><b>Boundary</b></td>
 :		 <td><b>Exterior</b></td>
 :		</tr>
 :		<tr>
 :		 <td><b>Interior</b></td>
 :		 <td>dim(intersection of interior1 and interior2)</td>
 :		 <td>dim(intersection of interior1 and boundary2)</td>
 :		 <td>dim(intersection of interior1 and exterior2)</td>
 :		</tr>
 :		<tr>
 :		 <td><b>Boundary</b></td>
 :		 <td>dim(intersection of boundary1 and interior2)</td>
 :		 <td>dim(intersection of boundary1 and boundary2)</td>
 :		 <td>dim(intersection of boundary1 and exterior2)</td>
 :		</tr>
 :		<tr>
 :		 <td><b>Exterior</b></td>
 :		 <td>dim(intersection of exterior1 and interior2)</td>
 :		 <td>dim(intersection of exterior1 and boundary2)</td>
 :		 <td>dim(intersection of exterior1 and exterior2)</td>
 :		</tr>
 :	</table>
 :	<p/>
 :	<p>The values in the DE-9IM can be T, F, *, 0, 1, 2.</p>
 :  <p>- T means the intersection gives a non-empty result.</p>
 :  <p>- F means the intersection gives an empty result.</p>
 :  <p>- * means any result.</p>
 :  <p>- 0, 1, 2 gives the expected dimension of the result (point, curve, surface)</p>
 :  <p/>
 : 
 : @author Daniel Turcanu
 :
 : @see http://expath.org/spec/geo
 : @see http://www.opengeospatial.org/standards/sfa
 : @see http://www.opengeospatial.org/standards/gml
 : @see http://trac.osgeo.org/geos/
 : @library <a href="http://trac.osgeo.org/geos/">GEOS (Geometry Engine - Open Source)</a>
 : @project EXPath/EXPath Geo Module
 :)
module namespace geo = "http://expath.org/ns/geo";

(:~
 : <p>Declare the namespace for the gml geometry objects.</p>
 :)
declare namespace gml="http://www.opengis.net/gml";

(:~
 : <p>Declare the expath errors namespace.</p>
 :)
declare namespace geo-err="http://expath.org/ns/error";

declare namespace ver = "http://www.zorba-xquery.com/options/versioning";
declare option ver:module-version "1.0";


(:~
 : <p>Return the dimension of the geo object.</p> 
 : 
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return 0 for point, 1 for line, 2 for surface.
 : @error geo-err:UnrecognizedGeoObject
 : @example test/Queries/geo/dimension1.xq
 : @example test/Queries/geo/dimension2.xq
 : @example test/Queries/geo/dimension3.xq
 : @example test/Queries/geo/dimension4.xq
 : @example test/Queries/geo/dimension5.xq
 : @example test/Queries/geo/dimension6.xq
 : @example test/Queries/geo/dimension7.xq
 : @example test/Queries/geo/dimension8.xq
 : @example test/Queries/geo/dimension9.xq
 : @example test/Queries/geo/dimension10.xq
:)
declare function geo:dimension( $geometry as element()) as xs:integer external;

(:~
 : <p>Return the coordinate dimension of the geo object, as specified in the srsDimension attribute.</p>
 : <p>Only two-dimensional and three-dimensional coordinates are supported.</p>
 : 
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return 2 for 2D, 3 for 3D.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/coordinate_dimension1.xq
 : @example test/Queries/geo/coordinate_dimension2.xq
 : @example test/Queries/geo/coordinate_dimension3.xq
 : @example test/Queries/geo/coordinate_dimension4.xq
 : @example test/Queries/geo/coordinate_dimension5.xq
 : @example test/Queries/geo/coordinate_dimension6.xq
:)
declare function geo:coordinate-dimension( $geometry as element()) as xs:integer external;

(:~
 : <p>Return the qname type of geo object.</p> 
 : <p>Returns empty sequence if the geometry is not recognized.</p> 
 : 
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return "gml:Point" for Point, "gml:LineString" for LineString, "gml:Curve" for Curve, "gml:LineString" for LinearRing,
 :     "gml:Surface" for Surface, "gml:Polygon" for Polygon and PolygonPatch, 
 :     "gml:MultiPoint" for MultiPoint, "gml:MultiCurve" for MultiCurve,
 :     "gml:MultiSurface" for MultiSurface, "gml:MultiGeometry" for MultiGeometry
 : @error geo-err:UnrecognizedGeoObject
 : @example test/Queries/geo/geometry_type1.xq
 : @example test/Queries/geo/geometry_type2.xq
 : @example test/Queries/geo/geometry_type3.xq
 : @example test/Queries/geo/geometry_type4.xq
 : @example test/Queries/geo/geometry_type5.xq
 : @example test/Queries/geo/geometry_type6.xq
 : @example test/Queries/geo/geometry_type7.xq
 : @example test/Queries/geo/geometry_type8.xq
 : @example test/Queries/geo/geometry_type9.xq
 : @example test/Queries/geo/geometry_type10.xq
 : @example test/Queries/geo/geometry_type11.xq
:)
declare function geo:geometry-type( $geometry as element()) as xs:QName? external;

(:~
 : <p>Return the srid URI of geo object.</p> 
 : <p>SRID is contained in the srsName attribute in the geo element, or one of the parents,
 : or in the boundedBy/Envelope element in one of the parents.</p>
 : <p>This function searches recursively from this element up to the top-most parent.</p>
 : 
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return the SRID if it is found
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/srid1.xq
 : @example test/Queries/geo/srid2.xq
 : @example test/Queries/geo/srid3.xq
 : @example test/Queries/geo/srid4.xq
 : @example test/Queries/geo/srid5.xq
:)
declare function geo:srid( $geometry as element()) as xs:anyURI? external;

(:~
 : <p>Return the number of geometries in the collection, or 1 for non-collection.</p> 
 : <p>For gml:Point, gml:LineString, gml:LinearRing, gml:Polygon, return 1.</p>
 : <p>For gml:Curve and gml:Surface, they are treated as geometric collections.</p>
 : 
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return number of geometries in collection
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/num-geometries1.xq
 : @example test/Queries/geo/num-geometries2.xq
 : @example test/Queries/geo/num-geometries3.xq
:)
declare function geo:num-geometries( $geometry as element()) as xs:unsignedInt external;

(:~
 : <p>Return the n-th geometry in the collection.</p> 
 : <p>Return this geometry if it is not a collection.</p>
 : <p>For gml:Point, gml:LineString, gml:LinearRing, gml:Polygon, return this item if n is zero, otherwise error.</p>
 : <p>For gml:Curve and gml:Surface, they are treated as geometric collections.</p>
 : 
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $n zero-based index in the collection
 : @return n-th geometry in collection. The node is the original node, not a copy.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/geometry-n1.xq
 : @example test/Queries/geo/geometry-n2.xq
 : @example test/Queries/geo/geometry-n3.xq
 : @example test/Queries/geo/geometry-n4.xq
:)
declare function geo:geometry-n( $geometry as element(), $n as xs:unsignedInt) as element() external;

(:~
 : <p>The envelope is the minimum bounding box of this geometry.</p>
 : 
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return An gml:Envelope element with content 
 :         &lt;gml:Envelope>
 :         &lt;gml:lowerCorner><i>minx miny</i>&lt;/gml:lowerCorner>
 :         &lt;gml:upperCorner><i>maxx maxy</i>&lt;/gml:upperCorner>
 :         &lt;/gml:Envelope>
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/envelope1.xq
 : @example test/Queries/geo/envelope2.xq
 : @example test/Queries/geo/envelope3.xq
 : @example test/Queries/geo/envelope4.xq
 : @example test/Queries/geo/envelope5.xq
 : @example test/Queries/geo/envelope6.xq
 : @example test/Queries/geo/envelope7.xq
 : @example test/Queries/geo/envelope8.xq
 : @example test/Queries/geo/envelope9.xq
 : @example test/Queries/geo/envelope11.xq
 : @example test/Queries/geo/envelope12.xq
:)
declare function geo:envelope( $geometry as element()) as element(gml:Envelope) external;

(:~
 : <p>Return the Well-known Text Representation of Geometry.</p> 
 : <p>This is defined in the Simple Features spec from OGC.</p>
 : <p>gml:Curve is represented as MultiLineString.</p>
 : <p>gml:Surface is represented as MultiPolygon.</p>
 : 
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return the Well-known Text Representation for the geo object.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/as_text1.xq
 : @example test/Queries/geo/as_text2.xq
 : @example test/Queries/geo/as_text3.xq
 : @example test/Queries/geo/as_text4.xq
 : @example test/Queries/geo/as_text5.xq
 : @example test/Queries/geo/as_text6.xq
 : @example test/Queries/geo/as_text7.xq
 : @example test/Queries/geo/as_text8.xq
 : @example test/Queries/geo/as_text9.xq
:)
declare function geo:as-text( $geometry as element()) as xs:string external;

(:~
 : <p>Return the Well-known Binary Representation of Geometry.</p> 
 : <p>This is defined in the Simple Features spec from OGC.</p>
 : <p>gml:Curve is represented as MultiLineString.</p>
 : <p>gml:Surface is represented as MultiPolygon.</p>
 : 
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return the Well-known Binary Representation for the geo object as base64.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/as_binary1.xq
:)
declare function geo:as-binary( $geometry as element()) as xs:base64Binary external;

(:~
 : <p>Checks if the argument is empty or not and if it is a valid geometry or not.</p> 
 : <p>A geometry is considered empty if it has no points.</p>
 : 
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return true if $geometry is not a valid gmlsf object or if is empty.
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/is_empty1.xq
 : @example test/Queries/geo/is_empty2.xq
 : @example test/Queries/geo/is_empty3.xq
 : @example test/Queries/geo/is_empty4.xq
 : @example test/Queries/geo/is_empty5.xq
:)
declare function geo:is-empty( $geometry as element()?) as xs:boolean external;

(:~
 : <p>Checks if this geometric object has no anomalous geometric points, such
 :	as self intersection or self tangency.</p> 
 : <p>Does not work for gml:Surface and gml:MultiGeometry.</p>
 : 
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString,
 :    gml:LinearRing, gml:Curve, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface
 : @return true if $geometry is simple.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/is_simple1.xq
 : @example test/Queries/geo/is_simple2.xq
 : @example test/Queries/geo/is_simple3.xq
 : @example test/Queries/geo/is_simple4.xq
 : @example test/Queries/geo/is_simple5.xq
 : @example test/Queries/geo/is_simple6.xq
 : @example test/Queries/geo/is_simple7.xq
 : @example test/Queries/geo/is_simple8.xq
 : @example test/Queries/geo/is_simple9.xq
 : @example test/Queries/geo/is_simple10.xq
 : @example test/Queries/geo/is_simple11.xq
 : @example test/Queries/geo/is_simple12.xq
 : @example test/Queries/geo/is_simple13.xq
 : @example test/Queries/geo/is_simple14.xq
:)
declare function geo:is-simple( $geometry as element()) as xs:boolean external;

(:~
 : <p>Checks if this geometric object is 2D or 3D, as specified in srsDimension optional attribute.</p>
 : 
 : 
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return true if $geometry is 3D. 
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/is_3D1.xq
 : @example test/Queries/geo/is_3D2.xq
:)
declare function geo:is-3d( $geometry as element()) as xs:boolean external;

(:~
 : <p>Checks if this geometric object has measurements.</p>
 : <p>Measurements is not supported in this geo module, so the function returns false.</p>
 : 
 : 
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return false. 
 : @error geo-err:UnrecognizedGeoObject
 : @example test/Queries/geo/is_measured1.xq
:)
declare function geo:is-measured( $geometry as element()) as xs:boolean external;

(:~
 : <p>A boundary is a set that represents the limit of an geometry.</p>
 : <p>For a Point or MultiPoint, the boundary is the empty geometry, nothing is returned.</p>
 : <p>For a LineString, the boundary is the MultiPoint set of start point and end point.</p>
 : <p>For a LinearRing, the boundary is empty MultiPoint.</p>
 : <p>For a Curve, it is treated as a MultiCurve.</p>
 : <p>For a Polygon, the boundary is the MultiCurve set of exterior and interior rings.</p>
 : <p>For a Surface, the boundary is the MultiCurve set formed from the exterior ring of all patches
 :  seen as a single surface and all the interior rings from all patches.</p>
 : <p>For MultiCurve, the boundary is the MultiPoint set of all start and end points that appear
 :  in an odd number of linestrings.</p>
 : <p>For MultiGeometry, a sequence of boundaries is returned, corresponding to each child geometry.</p>
 : 
 : 
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:LinearRing,
 :    gml:Curve, gml:Polygon, gml:Surface, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return the boundary of a Geometry as a set of Geometries of the next lower dimension.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/boundary1.xq
 : @example test/Queries/geo/boundary2.xq
 : @example test/Queries/geo/boundary3.xq
 : @example test/Queries/geo/boundary4.xq
 : @example test/Queries/geo/boundary5.xq
 : @example test/Queries/geo/boundary6.xq
 : @example test/Queries/geo/boundary7.xq
 : @example test/Queries/geo/boundary8.xq
 : @example test/Queries/geo/boundary9.xq
 : @example test/Queries/geo/boundary10.xq
 : @example test/Queries/geo/boundary11.xq
 : @example test/Queries/geo/boundary12.xq
 : @example test/Queries/geo/boundary13.xq
 : @example test/Queries/geo/boundary14.xq
:)
declare function geo:boundary( $geometry as element()) as element()* external;





(:~
 : <p>Checks if the two geometries are equal.</p>
 : <p/>
 : <p>Note: Does not work for gml:Surface and gml:MultiSurface if they have multiple Polygons.</p>
 : 
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return true if the DE-9IM intersection matrix for the two Geometrys is T*F**FFF*.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/equals1.xq
 : @example test/Queries/geo/equals2.xq
 : @example test/Queries/geo/equals3.xq
 : @example test/Queries/geo/equals4.xq
 : @example test/Queries/geo/equals5.xq
 : @example test/Queries/geo/equals6.xq
 : @example test/Queries/geo/equals7.xq
 : @example test/Queries/geo/equals8.xq
 : @example test/Queries/geo/equals9.xq
:)
declare function geo:equals( $geometry1 as element(),  $geometry2 as element()) as xs:boolean external;

(:~
 : <p>Checks if geometry1 covers geometry2.</p>         
 : <p>It has to fulfill one of these conditions:</p>
 :  <p>- every point of geometry2 is a point of geometry1.</p>
 :  <p>- the DE-9IM Intersection Matrix for the two geometries is
 :     T*****FF* or *T****FF* or ***T**FF* or ****T*FF*.</p>
 : 
 : Unlike contains it does not distinguish between points in the boundary and in the interior of geometries.
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return true if geometry1 covers geometry2.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/covers6.xq
:)
declare function geo:covers( $geometry1 as element(),  $geometry2 as element()) as xs:boolean external;

(:~
 : <p>Checks if geometry1 does not touch or intersects geometry2.</p>
 : <p>It has to fulfill these conditions:</p>
 :  <p>- they have no point in common</p>
 :  <p>- the DE-9IM Intersection Matrix for the two geometries is
 :     FF*FF****.</p>
 :  <p>- geometry1 does not intersect geometry2.</p>
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return true if geometry1 and geometry2 are disjoint.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/disjoint1.xq
 : @example test/Queries/geo/disjoint2.xq
 : @example test/Queries/geo/disjoint3.xq
 : @example test/Queries/geo/disjoint4.xq
 : @example test/Queries/geo/disjoint5.xq
 : @example test/Queries/geo/disjoint6.xq
 : @example test/Queries/geo/disjoint7.xq
 : @example test/Queries/geo/disjoint8.xq
 : @example test/Queries/geo/disjoint9.xq
:)
declare function geo:disjoint( $geometry1 as element(),  $geometry2 as element()) as xs:boolean external;

(:~
 : <p>Checks if geometry1 intersects geometry2.</p>
 : <p>This is true if disjoint returns false.</p>
 : 
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return true if geometry1 and geometry2 are not disjoint.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/intersects1.xq
 : @example test/Queries/geo/intersects2.xq
 : @example test/Queries/geo/intersects3.xq
 : @example test/Queries/geo/intersects4.xq
 : @example test/Queries/geo/intersects5.xq
 : @example test/Queries/geo/intersects6.xq
 : @example test/Queries/geo/intersects6_3d.xq
 : @example test/Queries/geo/intersects7.xq
 : @example test/Queries/geo/intersects8.xq
 : @example test/Queries/geo/intersects9.xq
:)
declare function geo:intersects( $geometry1 as element(),  $geometry2 as element()) as xs:boolean external;

(:~
 : <p>Checks if geometry1 touches geometry2.</p>
 : <p>Returns true if the DE-9IM intersection matrix for the two
 : geometries is FT*******, F**T***** or F***T****.</p>
 : 
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return true if geometry1 touches geometry2.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/touches1.xq
 : @example test/Queries/geo/touches2.xq
 : @example test/Queries/geo/touches3.xq
 : @example test/Queries/geo/touches4.xq
 : @example test/Queries/geo/touches5.xq
 : @example test/Queries/geo/touches6.xq
 : @example test/Queries/geo/touches7.xq
 : @example test/Queries/geo/touches8.xq
 : @example test/Queries/geo/touches9.xq
:)
declare function geo:touches( $geometry1 as element(),  $geometry2 as element()) as xs:boolean external;

(:~
 : <p>Checks if geometry1 crosses geometry2.</p>
 : <p>That is if the geometries have some but not all interior points in common.</p>
 : <p>Returns true if the DE-9IM intersection matrix for the two
 : geometries is:</p>
 : <p>T*T****** (for P/L, P/A, and L/A situations).</p> 
 : <p>T*****T** (for L/P, A/P, and A/L situations).</p> 
 : <p>0******** (for L/L situations).</p>
 : 
 : <p>This applies for situations:  P/L, P/A, L/L, L/A, L/P, A/P and A/L.</p>
 : <p>For other situations it returns false.</p>
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return true if geometry1 crosses geometry2.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/crosses1.xq
 : @example test/Queries/geo/crosses2.xq
 : @example test/Queries/geo/crosses3.xq
 : @example test/Queries/geo/crosses4.xq
 : @example test/Queries/geo/crosses5.xq
 : @example test/Queries/geo/crosses6.xq
 : @example test/Queries/geo/crosses7.xq
 : @example test/Queries/geo/crosses8.xq
 : @example test/Queries/geo/crosses9.xq
 : @example test/Queries/geo/crosses10.xq
:)
declare function geo:crosses( $geometry1 as element(),  $geometry2 as element()) as xs:boolean external;

(:~
 : <p>Checks if geometry1 is within geometry2.</p>
 : <p>Returns true if the DE-9IM intersection matrix for the two
 :  geometries is T*F**F***.</p>
 : 
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return true if geometry1 is within geometry2.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/within1.xq
 : @example test/Queries/geo/within2.xq
 : @example test/Queries/geo/within3.xq
 : @example test/Queries/geo/within4.xq
 : @example test/Queries/geo/within5.xq
 : @example test/Queries/geo/within6.xq
 : @example test/Queries/geo/within7.xq
 : @example test/Queries/geo/within8.xq
 : @example test/Queries/geo/within9.xq
:)
declare function geo:within( $geometry1 as element(),  $geometry2 as element()) as xs:boolean external;

(:~
 : <p>Checks if geometry1 contains geometry2.</p>
 : <p>Returns true if within(geometry2, geometry1) is true.</p>
 : 
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return true if geometry1 contains geometry2.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/contains1.xq
 : @example test/Queries/geo/contains2.xq
 : @example test/Queries/geo/contains3.xq
 : @example test/Queries/geo/contains4.xq
 : @example test/Queries/geo/contains5.xq
 : @example test/Queries/geo/contains6.xq
 : @example test/Queries/geo/contains7.xq
 : @example test/Queries/geo/contains8.xq
 : @example test/Queries/geo/contains9.xq
 : @example test/Queries/geo/contains10.xq
:)
declare function geo:contains( $geometry1 as element(),  $geometry2 as element()) as xs:boolean external;

(:~
 : <p>Checks if geometry1 overlaps with geometry2.</p>
 : <p>Returns true if DE-9IM intersection matrix for the two
 : geometries is T*T***T** (for two points or two surfaces)
 :	 or * 1*T***T** (for two curves).</p>
 : 
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return true if geometry1 overlaps geometry2.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/overlaps1.xq
 : @example test/Queries/geo/overlaps2.xq
 : @example test/Queries/geo/overlaps3.xq
 : @example test/Queries/geo/overlaps4.xq
 : @example test/Queries/geo/overlaps5.xq
 : @example test/Queries/geo/overlaps6.xq
 : @example test/Queries/geo/overlaps7.xq
 : @example test/Queries/geo/overlaps8.xq
 : @example test/Queries/geo/overlaps9.xq
 : @example test/Queries/geo/overlaps10.xq
 : @example test/Queries/geo/overlaps11.xq
 : @example test/Queries/geo/overlaps12.xq
:)
declare function geo:overlaps( $geometry1 as element(),  $geometry2 as element()) as xs:boolean external;

(:~
 : <p>Checks if geometry1 relates with geometry2 relative to a DE-9IM matrix.</p>
 : <p>The DE-9IM matrix is defined like this:</p>
 : <table>
 :	<tr>
 :		 <td></td>
 :		 <td><b>Interior</b></td>
 :		 <td><b>Boundary</b></td>
 :		 <td><b>Exterior</b></td>
 :		</tr>
 :		<tr>
 :		 <td><b>Interior</b></td>
 :		 <td>dim(intersection of interior1 and interior2)</td>
 :		 <td>dim(intersection of interior1 and boundary2)</td>
 :		 <td>dim(intersection of interior1 and exterior2)</td>
 :		</tr>
 :		<tr>
 :		 <td><b>Boundary</b></td>
 :		 <td>dim(intersection of boundary1 and interior2)</td>
 :		 <td>dim(intersection of boundary1 and boundary2)</td>
 :		 <td>dim(intersection of boundary1 and exterior2)</td>
 :		</tr>
 :		<tr>
 :		 <td><b>Exterior</b></td>
 :		 <td>dim(intersection of exterior1 and interior2)</td>
 :		 <td>dim(intersection of exterior1 and boundary2)</td>
 :		 <td>dim(intersection of exterior1 and exterior2)</td>
 :		</tr>
 :	</table>
 :	
 :	<p>The values in the DE-9IM can be T, F, *, 0, 1, 2 .</p>
 :  <p>- T means the intersection gives a non-empty result.</p>
 :  <p>- F means the intersection gives an empty result.</p>
 :  <p>- * means any result.</p>
 :  <p>- 0, 1, 2 gives the expected dimension of the result (point, curve, surface)</p>
 : 
 : <p>For example, the matrix of "T*T***T**" checks for intersections of interior1 with interior2,
 : interior1 with exterior2 and exterior1 with interior2.</p>
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString,
 :    gml:LinearRing, gml:Polygon
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString,
 :    gml:LinearRing, gml:Polygon
 : @param $intersection_matrix the DE-9IM matrix, with nine chars, three chars for each line in DE-9IM matrix.
 : @return true if geometry1 relates to geometry2 according to the intersection matrix.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/relate1.xq
 : @example test/Queries/geo/relate2.xq
 : @example test/Queries/geo/relate3.xq
 : @example test/Queries/geo/relate4.xq
:)
declare function geo:relate( $geometry1 as element(),  $geometry2 as element(), $intersection_matrix as xs:string) as xs:boolean external;




(:~
 : <p>Compute the shortest distance between any two Points in geometry1 and geometry2.</p>
 : 
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return minimum distance as xs:double.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/distance1.xq
:)
declare function geo:distance( $geometry1 as element(),  $geometry2 as element()) as xs:double external;

(:~
 : <p>Returns a polygon that represents all Points whose distance
 :   from this geometric object is less than or equal to distance.</p>
 : 
 :
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $distance the distance from geometry, expressed in units of the current coordinate system
 : @return new geometry surrounding the input geometry.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/buffer1.xq
 : @example test/Queries/geo/buffer2.xq
 : @example test/Queries/geo/buffer3.xq
 : @example test/Queries/geo/buffer4.xq
 : @example test/Queries/geo/buffer5.xq
 : @example test/Queries/geo/buffer6.xq
 : @example test/Queries/geo/buffer7.xq
 : @example test/Queries/geo/buffer8.xq
 : @example test/Queries/geo/buffer9.xq
 : @example test/Queries/geo/buffer10.xq
:)
declare function geo:buffer( $geometry as element(),  $distance as xs:double) as element() external;

(:~
 : <p>Returns the smallest convex Polygon that contains all the points in the Geometry.</p>
 : <p>Actually returns the object of smallest dimension possible (possible Point or LineString).</p>
 : 
 :
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return the convex polygon node.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/convex-hull1.xq
 : @example test/Queries/geo/convex-hull2.xq
 : @example test/Queries/geo/convex-hull3.xq
 : @example test/Queries/geo/convex-hull3_3d.xq
 : @example test/Queries/geo/convex-hull4.xq
 : @example test/Queries/geo/convex-hull5.xq
 : @example test/Queries/geo/convex-hull6.xq
 : @example test/Queries/geo/convex-hull7.xq
 : @example test/Queries/geo/convex-hull8.xq
 : @example test/Queries/geo/convex-hull9.xq
 : @example test/Queries/geo/convex-hull10.xq
:)
declare function geo:convex-hull( $geometry as element()) as element() external;

(:~
 : <p>Returns a geometric object that represents the Point set intersection of
 :    geometry1 and geometry2.</p>
 : <p>For intersection of two polygons interiors, returns a polygon.</p>
 : <p>If intersection is void, empty sequence is returned.</p>
 : 
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return point set geometry node.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/intersection1.xq
 : @example test/Queries/geo/intersection2.xq
 : @example test/Queries/geo/intersection3.xq
 : @example test/Queries/geo/intersection4.xq
 : @example test/Queries/geo/intersection5.xq
 : @example test/Queries/geo/intersection6.xq
 : @example test/Queries/geo/intersection7.xq
 : @example test/Queries/geo/intersection8.xq
 : @example test/Queries/geo/intersection8_3d.xq
 : @example test/Queries/geo/intersection9.xq
 : @example test/Queries/geo/intersection10.xq
:)
declare function geo:intersection( $geometry1 as element(),  $geometry2 as element()) as element()? external;

(:~
 : <p>Returns a geometric object that represents the Point set union of
 :    geometry1 and geometry2.</p>
 : 
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return point set geometry node.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/union1.xq
 : @example test/Queries/geo/union2.xq
 : @example test/Queries/geo/union3.xq
 : @example test/Queries/geo/union4.xq
 : @example test/Queries/geo/union5.xq
 : @example test/Queries/geo/union5_3d.xq
 : @example test/Queries/geo/union6.xq
 : @example test/Queries/geo/union7.xq
 : @example test/Queries/geo/union8.xq
 : @example test/Queries/geo/union9.xq
:)
declare function geo:union( $geometry1 as element(),  $geometry2 as element()) as element() external;

(:~
 : <p>Returns a geometric object that represents the Point set difference of
 :    geometry1 and geometry2. Points that are in geometry1 and are not in geometry2.</p>
 : <p>If difference is empty geometry, empty sequence is returned.</p>
 : 
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return point set geometry node.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/difference1.xq
 : @example test/Queries/geo/difference2.xq
 : @example test/Queries/geo/difference3.xq
 : @example test/Queries/geo/difference4.xq
 : @example test/Queries/geo/difference5.xq
 : @example test/Queries/geo/difference6.xq
 : @example test/Queries/geo/difference7.xq
 : @example test/Queries/geo/difference8.xq
 : @example test/Queries/geo/difference9.xq
 : @example test/Queries/geo/difference10.xq
:)
declare function geo:difference( $geometry1 as element(),  $geometry2 as element()) as element()? external;

(:~
 : <p>Returns a geometric object that represents the Point set symmetric difference of
 :    geometry1 and geometry2. Points that are in geometry1 and are not in geometry2
 :    and points that are in geometry2 and are not in geometry1.</p>
 : <p>If difference is empty geometry, empty sequence is returned.</p>
 : 
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return point set geometry node.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/sym-difference1.xq
 : @example test/Queries/geo/sym-difference2.xq
 : @example test/Queries/geo/sym-difference3.xq
 : @example test/Queries/geo/sym-difference4.xq
 : @example test/Queries/geo/sym-difference5.xq
 : @example test/Queries/geo/sym-difference6.xq
 : @example test/Queries/geo/sym-difference7.xq
 : @example test/Queries/geo/sym-difference8.xq
 : @example test/Queries/geo/sym-difference9.xq
:)
declare function geo:sym-difference( $geometry1 as element(),  $geometry2 as element()) as element()? external;




(:~
 : <p>Returns the area of this geometry.</p>
 : <p>Returns zero for Point and Lines.</p>
 : 
 :
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return geometry area as xs:double.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/area1.xq
 : @example test/Queries/geo/area2.xq
 : @example test/Queries/geo/area3.xq
 : @example test/Queries/geo/area4.xq
 : @example test/Queries/geo/area5.xq
 : @example test/Queries/geo/area6.xq
 : @example test/Queries/geo/area7.xq
 : @example test/Queries/geo/area8.xq
 : @example test/Queries/geo/area9.xq
 : @example test/Queries/geo/area10.xq
:)
declare function geo:area( $geometry as element()) as xs:double external;

(:~
 : <p>Returns the length of the lines of this geometry.</p>
 : <p>Returns zero for Points.</p>
 : 
 :
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return geometry length as xs:double.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/length1.xq
 : @example test/Queries/geo/length2.xq
 : @example test/Queries/geo/length3.xq
 : @example test/Queries/geo/length4.xq
 : @example test/Queries/geo/length5.xq
 : @example test/Queries/geo/length6.xq
 : @example test/Queries/geo/length7.xq
 : @example test/Queries/geo/length8.xq
 : @example test/Queries/geo/length9.xq
 : @example test/Queries/geo/length10.xq
:)
declare function geo:length( $geometry as element()) as xs:double external;

(:~
 : <p>Checks if geometry2 is within a certain distance of geometry1.</p>
 : 
 :
 : @param $geometry1 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $geometry2 node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @param $distance the distance from geometry1, expressed in units of the current coordinate system
 : @return true if distance from geometry1 to geometry2 is less than $distance.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:SRSNotIdenticalInBothGeometries
 : @error geo-err:GEOSError
 : @example test/Queries/geo/is-within-distance1.xq
 : @example test/Queries/geo/is-within-distance2.xq
 : @example test/Queries/geo/is-within-distance3.xq
 : @example test/Queries/geo/is-within-distance4.xq
 : @example test/Queries/geo/is-within-distance5.xq
 : @example test/Queries/geo/is-within-distance6.xq
 : @example test/Queries/geo/is-within-distance7.xq
 : @example test/Queries/geo/is-within-distance8.xq
 : @example test/Queries/geo/is-within-distance9.xq
:)
declare function geo:is-within-distance( $geometry1 as element(),  $geometry2 as element(), $distance as xs:double) as xs:boolean external;

(:~
 : <p>Returns a Point that is the mathematical centroid of this geometry.</p>
 : <p>The result is not guaranteed to be on the surface.</p> 
 : 
 :
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return centroid Point.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/centroid1.xq
 : @example test/Queries/geo/centroid2.xq
 : @example test/Queries/geo/centroid3.xq
 : @example test/Queries/geo/centroid4.xq
 : @example test/Queries/geo/centroid5.xq
 : @example test/Queries/geo/centroid6.xq
 : @example test/Queries/geo/centroid7.xq
 : @example test/Queries/geo/centroid8.xq
 : @example test/Queries/geo/centroid9.xq
 : @example test/Queries/geo/centroid10.xq
:)
declare function geo:centroid( $geometry as element()) as element(gml:Point) external;

(:~
 : <p>Returns a Point that is interior of this geometry.</p>
 : <p>If it cannot be inside the geometry, then it will be on the boundary.</p> 
 : 
 :
 : @param $geometry node of one of GMLSF objects: gml:Point, gml:LineString, gml:Curve, gml:LinearRing, 
 :    gml:Surface, gml:Polygon, gml:MultiPoint, gml:MultiCurve, gml:MultiSurface, gml:MultiGeometry
 : @return a Point inside the geometry.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/interior-point1.xq
 : @example test/Queries/geo/interior-point2.xq
 : @example test/Queries/geo/interior-point3.xq
 : @example test/Queries/geo/interior-point4.xq
 : @example test/Queries/geo/interior-point5.xq
 : @example test/Queries/geo/interior-point6.xq
 : @example test/Queries/geo/interior-point7.xq
 : @example test/Queries/geo/interior-point8.xq
 : @example test/Queries/geo/interior-point9.xq
 : @example test/Queries/geo/interior-point10.xq
:)
declare function geo:point-on-surface( $geometry as element()) as element(gml:Point) external;






(:~
 : <p>Returns the X coordinate of a Point.</p>
 : 
 :
 : @param $point node of one of GMLSF objects: gml:Point
 : @return the X coordinate
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/point_xyz1.xq
 : @example test/Queries/geo/point_xyz4.xq
:)
declare function geo:x( $point as element(gml:Point)) as xs:double external;

(:~
 : <p>Returns the Y coordinate of a Point.</p>
 : 
 :
 : @param $point node of one of GMLSF objects: gml:Point
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @return the Y coordinate
 : @example test/Queries/geo/point_xyz2.xq
:)
declare function geo:y( $point as element(gml:Point)) as xs:double external;

(:~
 : <p>Returns the Z coordinate of a Point, if is 3D.</p>
 : 
 :
 : @param $point node of one of GMLSF objects: gml:Point
 : @return the Z coordinate, or empty sequence if 2D
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/point_xyz3.xq
 : @example test/Queries/geo/point_xyz5.xq
:)
declare function geo:z( $point as element(gml:Point)) as xs:double? external;

(:~
 : <p>Should return the Measure of a Point, but is not implemented, 
 : because it is not specified in GMLSF.</p>
 : 
 :
 : @param $point node of one of GMLSF objects: gml:Point
 : @return always empty sequence
 : @error geo-err:UnsupportedSRSDimensionValue
 : @example test/Queries/geo/point_xyz6.xq
:)
declare function geo:m( $point as element(gml:Point)) as xs:double? external;







(:~
 : <p>Returns the start Point of a line.</p>
 : 
 :
 : @param $line node of one of GMLSF objects: gml:LineString, gml:LinearRing, gml:Curve
 : @return the starting gml:Point, constructed with the first coordinates in the line.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/start-point1.xq
 : @example test/Queries/geo/start-point2.xq
 : @example test/Queries/geo/start-point3.xq
:)
declare function geo:start-point( $line as element()) as element(gml:Point) external;

(:~
 : <p>Returns the end Point of a line.</p>
 : 
 :
 : @param $line node of one of GMLSF objects: gml:LineString, gml:LinearRing, gml:Curve
 : @return the end gml:Point, constructed with the last coordinates in the line.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/end-point1.xq
:)
declare function geo:end-point( $line as element()) as element(gml:Point) external;

(:~
 : <p>Checks if the line is closed loop. That is, if the start Point is same with end Point.</p>
 : <p>For gml:Curve, checks if the start point of the first segment is the same with the
 :   last point of the last segment. It also checks that all the segments are connected together,
 :   and returns false if they aren't.</p>
 : <p>For gml:MultiCurve, checks recursively for each LineString.</p>
 : <p>For gml:Surface, checks if the exterior boundary of each patch touches completely other patches,
 :   so the Surface encloses a solid.
 :   For this to happen there is a need for 3D objects, and full 3D processing is not supported in GEOS library,
 :   so the function always returns false in this case.</p>
 : 
 :
 : @param $geom node of one of GMLSF objects: gml:LineString, gml:LinearRing, gml:Curve,
 :      gml:MultiCurve, gml:Surface
 : @return true if the line or surface is closed.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/is-closed1.xq
 : @example test/Queries/geo/is-closed2.xq
 : @example test/Queries/geo/is-closed3.xq
 : @example test/Queries/geo/is-closed4.xq
 : @example test/Queries/geo/is-closed5.xq
 : @example test/Queries/geo/is-closed6.xq
:)
declare function geo:is-closed( $geom as element()) as xs:boolean external;

(:~
 : <p>Checks if the line is a ring. That is, if the line is closed and simple.</p>
 : 
 :
 : @param $line node of one of GMLSF objects: gml:LineString, gml:LinearRing, gml:Curve
 : @return true if the line is a closed ring.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/is-ring1.xq
 : @example test/Queries/geo/is-ring2.xq
 : @example test/Queries/geo/is-ring3.xq
 : @example test/Queries/geo/is-ring4.xq
:)
declare function geo:is-ring( $line as element()) as xs:boolean external;

(:~
 : <p>Return the number of Points in a line.</p>
 : 
 :
 : @param $line node of one of GMLSF objects: gml:LineString, gml:LinearRing, gml:Curve,
 :   gml:MultiCurve
 : @return number of points in the line
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/num-points1.xq
 : @example test/Queries/geo/num-points2.xq
 : @example test/Queries/geo/num-points3.xq
:)
declare function geo:num-points( $line as element()) as xs:unsignedInt external;

(:~
 : <p>Return the n-th Point in a line.</p>
 :
 : @param $line node of one of GMLSF objects: gml:LineString, gml:LinearRing, gml:Curve,
 :    gml:MultiCurve
 : @param $n index in the list of coordinates, zero based.
 : @return n-th point in the line, zero-based. The node is gml:Point constructed with n-th coordinate from line.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/point-n1.xq
 : @example test/Queries/geo/point-n2.xq
 : @example test/Queries/geo/point-n3.xq
:)
declare function geo:point-n( $line as element(), $n as xs:unsignedInt) as element(gml:Point) external;






(:~
 : <p>Return the exterior ring of a Polygon.</p>
 : 
 :
 : @param $polygon node of one of GMLSF objects: gml:Polygon
 : @return the original gml:LinearRing node for exterior ring
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/exterior-ring1.xq
 : @example test/Queries/geo/exterior-ring2.xq
:)
declare function geo:exterior-ring( $polygon as element(gml:Polygon)) as element(gml:LinearRing) external;

(:~
 : <p>Return the number of interior rings of a Polygon.</p>
 : 
 :
 : @param $polygon node of one of GMLSF objects: gml:Polygon
 : @return the number of interior rings
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/num-interior-ring1.xq
:)
declare function geo:num-interior-ring( $polygon as element(gml:Polygon)) as xs:unsignedInt external;

(:~
 : <p>Return the n-th interior ring of a Polygon.</p>
 : 
 :
 : @param $polygon node of one of GMLSF objects: gml:Polygon
 : @param $n index in the list of interior rings, zero based.
 : @return n-th interior ring. The node is the original node, not a copy.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:IndexOutsideRange
 : @error geo-err:GEOSError
 : @example test/Queries/geo/interior-ring-n1.xq
:)
declare function geo:interior-ring-n( $polygon as element(gml:Polygon), $n as xs:unsignedInt) as element(gml:LinearRing) external;

(:~
 : <p>Return the number of surface patches inside a gml:Surface.</p>
 : <p>This function has the same effect as num-geometries(), only it is restricted to gml:Surface.</p>
 : 
 :
 : @param $polyhedral-surface node of one of GMLSF objects: gml:Surface
 : @return the number of surface patches
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/num-patches1.xq
 : @example test/Queries/geo/num-patches2.xq
:)
declare function geo:num-patches($polyhedral-surface as element(gml:Surface)) as xs:integer external;

(:~
 : <p>Return the n-th Surface patch of a Surface.</p>
 : <p>Only polygonal Surfaces are supported, so a gml:PolygonPatch is returned.</p>
 : <p>The gml:PolygonPatch has the same content as gml:Polygon.</p>
 : <p>This function has the same effect as geometry-n(), only it is restricted to gml:Surface.</p>
 : 
 :
 : @param $polyhedral-surface node of one of GMLSF objects: gml:Surface
 : @param $n index in the list of surface patches, zero based.
 : @return n-th polygon patch. The node is the original node, not a copy.
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:IndexOutsideRange
 : @error geo-err:GEOSError
 : @example test/Queries/geo/patch-n1.xq
 : @example test/Queries/geo/patch-n2.xq
:)
declare function geo:patch-n($polyhedral-surface as element(gml:Surface),
																		$n as xs:unsignedInt) as element(gml:PolygonPatch) external;


(:~
 : <p>Return the list of PolygonPatches that share a boundary with the given $polygon.</p>
 : <p>The gml:PolygonPatch has the same content as gml:Polygon.</p>
 : <p>This function tests the exterior ring of each polygon patch if it overlaps
 : with the exterior ring of the given polygon.</p>
 : 
 :
 : @param $polyhedral-surface node of one of GMLSF objects: gml:Surface
 : @param $polygon, of type gml:Polygon or gml:PolygonPatch
 : @return the list of neibourghing gml:PolygonPatch-es
 : @error geo-err:UnrecognizedGeoObject
 : @error geo-err:UnsupportedSRSDimensionValue
 : @error geo-err:GEOSError
 : @example test/Queries/geo/bounding-polygons1.xq
 : @example test/Queries/geo/bounding-polygons2.xq
 : @example test/Queries/geo/bounding-polygons3.xq
:)
declare function geo:bounding-polygons($polyhedral-surface as element(gml:Surface),
																	 $polygon as element()) as element(gml:PolygonPatch)* external;
