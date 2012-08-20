/*
 * This work is licensed under the Creative Commons Attribution 3.0
 * Unported License. To view a copy of this license, visit
 * http://creativecommons.org/licenses/by/3.0/ or send a letter to
 * Creative Commons, 444 Castro Street, Suite 900, Mountain View,
 * California, 94041, USA.
*/

package
{
    
/**
 *  A set of static functions that compute cubic bezier approximations to circular arcs.
 * 
 *  The createRectangularSegmentPathData() and createTriangularWedgePathData() functions 
 *  create an spark.primitives.Path data string that's typically used to renderer a filled arc.
 *  The createArcPathData() function creates a data string that's used to render a stroked arc.
 * 
 *  The createArc() method just returns a series of objects that represent the cubic bezier curves
 *  that approximate an arc.
 */    
public class PathArcUtils
{
    private static const EPSILON:Number = 0.00001;  // Roughly 1/1000th of a degree, see below    
    
    /**
     *  Returns a Path data string that defines a closed circular wedge centered at xc,yc with inner and outer radii
     *  of r1 and r2, beginning with angle a1 and ending with angle a2.  Angles are specified in degrees, radii and center
     *  point coordinates in pixels.   The caps argument is a String with two characters that define how the ends of the 
     *  circular wedge are joined: "||" - straight lines, "()" outward facing circular arcs, ")(" inward facing 
     *  circular arcs.
     * 
     *  Angle a2 is limited so that |a2 - a1| is <= 360.  If |a2 - a1| is zero (or very close), then null is returned.
     */    
    public static function createRectangularSegmentPathData(xc:Number, yc:Number, r1:Number, r2:Number, a1:Number, a2:Number, caps:String="()"):String
    {
        if (!caps || (caps.length < 2))
            caps = "()";
        
        // Drawing a filled Path fails if the ends of the arc segment overlap, spectacularly so if the
        // overlap goes beyond the radius ends.   Clip the a2 "end angle" here.
        
        const da:Number = Math.abs(a2 - a1);
        if (da > 360)
        {
            const sgn:Number = (a2 - a1) < 0 ? -1 : +1;
            a2 = (sgn * 360) + a1;
        }
        else if (da <= EPSILON)
        {
            return null;
        }
        
        const a1r:Number = a1 * (Math.PI / 180);
        const a2r:Number = a2 * (Math.PI / 180);
        const arc1:Array = createArc(r1, a1r, a2r).reverse(); 
        const arc2:Array = createArc(r2, a1r, a2r); 
        const capR:Number = (r2 - r1) / 2;
        
        var pathData:String = null;
        
        const arc1LastCurve:Object = arc1[arc1.length - 1];
        const arc1LastX:Number = arc1LastCurve.x1 + xc;
        const arc1LastY:Number = arc1LastCurve.y1 + yc;
        
        for each (var curve:Object in arc2)
        {
            if (!pathData)
            {
                const capX1:Number = ((r1 + capR) * Math.cos(a1r)) + xc;
                const capY1:Number = ((r1 + capR) * Math.sin(a1r)) + yc;
                const caps0:String = caps.charAt(0);
                
                pathData = "M " + arc1LastX + " " + arc1LastY;
                switch (caps0)
                {
                    case "(":
                        pathData += createArcPathData(capX1, capY1, capR, a1-180, a1);
                        break;
                    
                    case ")":
                        pathData += createArcPathData(capX1, capY1, capR, a1+180, a1);
                        break;

                    default: 
                        pathData += " L " + (curve.x1 + xc) + " " + (curve.y1 + yc); 
                }
            }
            
            pathData += 
                " C " + (curve.x2 + xc) + " " + (curve.y2 + yc) + 
                " " +   (curve.x3 + xc) + " " + (curve.y3 + yc) + 
                " " +   (curve.x4 + xc) + " " + (curve.y4 + yc); 
        }
        
        const arc1StartCurve:Object = arc1[0];
        const arc1StartX:Number = arc1StartCurve.x4 + xc;
        const arc1StartY:Number = arc1StartCurve.y4 + yc;
        
        const capX2:Number = ((r1 + capR) * Math.cos(a2r)) + xc;
        const capY2:Number = ((r1 + capR) * Math.sin(a2r)) + yc;
        const caps1:String = caps.charAt(1);
        
        switch (caps1)
        {
            case "(":
                pathData += createArcPathData(capX2, capY2, capR, a2, a2 - 180);
                break;
            
            case ")":
                pathData += createArcPathData(capX2, capY2, capR, a2, a2 + 180);
                break;
            
            default: 
                pathData += " L " + arc1StartX + " " + arc1StartY;
        } 
        
        for each (curve in arc1)
        {
            pathData += 
                " C " + (curve.x3 + xc) + " " + (curve.y3 + yc) + 
                " " +   (curve.x2 + xc) + " " + (curve.y2 + yc) + 
                " " +   (curve.x1 + xc) + " " + (curve.y1 + yc); 
        } 

        return pathData;        
    }
    
    /**
     *  Returns a Path data string that defines a filled triangular ("pie slice") wedge centered at xc,yc with radius r,
     *  beginning with angle a1 and ending with angle a2.  Angles are specified in degrees, radii and center
     *  point coordinates in pixels. 
     */       
    public static function createTriangularWedgePathData(xc:Number, yc:Number, r:Number, a1:Number, a2:Number):String
    {
        const a1r:Number = a1 * (Math.PI / 180);
        const a2r:Number = a2 * (Math.PI / 180);
        const curves:Array = createArc(r, a1r, a2r);
        var pathData:String = null;
        
        for each (var curve:Object in curves)
        {
            if (!pathData)
                pathData = "M " + xc + " " + yc + " L " + (curve.x1 + xc) + " " + (curve.y1 + yc);
            
            pathData += 
                " C " + (curve.x2 + xc) + " " + (curve.y2 + yc) + 
                " " +   (curve.x3 + xc) + " " + (curve.y3 + yc) + 
                " " +   (curve.x4 + xc) + " " + (curve.y4 + yc); 
        }
        
        pathData += " L " + xc + " " + yc + " Z";
        return pathData;
    }
    
    /**
     *  Returns a Path data string that defines a circular arc at xc,yc with radius r,
     *  beginning with angle a1 and ending with angle a2.  Angles are specified in degrees, radii and center
     *  point coordinates in pixels. 
     */     
    public static function createArcPathData(xc:Number, yc:Number, r:Number, a1:Number, a2:Number):String
    {
        const a1r:Number = a1 * (Math.PI / 180);
        const a2r:Number = a2 * (Math.PI / 180);
        const curves:Array = createArc(r, a1r, a2r);
        var pathData:String = null;
        
        for each (var curve:Object in curves)
        {
            if (!pathData)
                pathData =  "M " + (curve.x1 + xc) + " " + (curve.y1 + yc);
            
            pathData += 
                " C " + (curve.x2 + xc) + " " + (curve.y2 + yc) + 
                " " +   (curve.x3 + xc) + " " + (curve.y3 + yc) + 
                " " +   (curve.x4 + xc) + " " + (curve.y4 + yc); 
        }
        
        return pathData;
    }
    
    /**
     *  Return a array of objects that represent bezier curves which approximate the 
     *  circular arc centered at the origin, from startAngle to endAngle (radians) with 
     *  the specified radius.
     *  
     *  Each bezier curve is an object with four points, where x1,y1 and 
     *  x4,y4 are the arc's end points and x2,y2 and x3,y3 are the cubic bezier's 
     *  control points.
     */
    public static function createArc(radius:Number, startAngle:Number, endAngle:Number):Array
    {
        // normalize startAngle, endAngle to [-2PI, 2PI]
        
        const twoPI:Number = Math.PI * 2;
        const startAngleN:Number = startAngle % twoPI
        const endAngleN:Number = endAngle % twoPI;
        
        // Compute the sequence of arc curves, up to PI/2 at a time.  Total arc angle
        // is less than 2PI.
        
        const curves:Array = [];
        const piOverTwo:Number = Math.PI / 2.0;
        const sgn:Number = (startAngle < endAngle) ? +1 : -1; // clockwise or counterclockwise
        
        var a1:Number = startAngle;
        for (var totalAngle:Number = Math.min(twoPI, Math.abs(endAngleN - startAngleN)); totalAngle > EPSILON; ) 
        {
            var a2:Number = a1 + sgn * Math.min(totalAngle, piOverTwo);
            curves.push(createSmallArc(radius, a1, a2));
            totalAngle -= Math.abs(a2 - a1);
            a1 = a2;
        }
        
        return curves;
    }
    
    /**
     *  Cubic bezier approximation of a circular arc centered at the origin, 
     *  from (radians) a1 to a2, where a2-a1 < pi/2.  The arc's radius is r.
     * 
     *  Returns an object with four points, where x1,y1 and x4,y4 are the arc's end points
     *  and x2,y2 and x3,y3 are the cubic bezier's control points.
     * 
     *  This algorithm is based on the approach described in:
     *  A. Riškus, "Approximation of a Cubic Bezier Curve by Circular Arcs and Vice Versa," 
     *  Information Technology and Control, 35(4), 2006 pp. 371-378.
     */
    private static function createSmallArc(r:Number, a1:Number, a2:Number):Object
    {
        // Compute all four points for an arc that subtends the same total angle
        // but is centered on the X-axis
        
        const a:Number = (a2 - a1) / 2.0;
        
        const x4:Number = r * Math.cos(a);
        const y4:Number = r * Math.sin(a);
        const x1:Number = x4;
        const y1:Number = -y4;
        
        const q1:Number = x1*x1 + y1*y1;
        const q2:Number = q1 + x1*x4 + y1*y4;
        const k2:Number = 4/3 * (Math.sqrt(2 * q1 * q2) - q2) / (x1 * y4 - y1 * x4);
        
        const x2:Number = x1 - k2 * y1;
        const y2:Number = y1 + k2 * x1;
        const x3:Number = x2; 
        const y3:Number = -y2;
        
        // Find the arc points' actual locations by computing x1,y1 and x4,y4 
        // and rotating the control points by a + a1
        
        const ar:Number = a + a1;
        const cos_ar:Number = Math.cos(ar);
        const sin_ar:Number = Math.sin(ar);
        
        return {
            x1: r * Math.cos(a1), 
            y1: r * Math.sin(a1), 
            x2: x2 * cos_ar - y2 * sin_ar, 
            y2: x2 * sin_ar + y2 * cos_ar, 
            x3: x3 * cos_ar - y3 * sin_ar, 
            y3: x3 * sin_ar + y3 * cos_ar, 
            x4: r * Math.cos(a2), 
            y4: r * Math.sin(a2)
        };
    }
}
}