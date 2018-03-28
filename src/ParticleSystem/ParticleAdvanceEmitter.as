/**
 * Created by raysun on 1/24/17.
 */
package ParticleSystem
{
import flash.geom.Point;

public class ParticleAdvanceEmitter extends ParticleEmitter
{
    //TODO uses a circle radius setting along a bezier curve to determing emit position
    //TODO uses circle angle to determine velo if only 1 point, otherwise use bezier

    private static var tEpsilon:Number = 0.01;
    private var bezierEmitterSnap:String;
    private var tCurrent:Number;
    private var pCurrent:Point;
    private var oCurrent:Point;
    private var bezierSet:Boolean = false;
    private var randomAngle:Number = 0;
    private var randomDist:Number = 0;

    //This are used to control beam/snake like emission with movement through the bezier path
    //Specify the ends in realtime, can't really put it in the spec though
    private var bezTStart:Number = 0;
    private var bezTDiff:Number = 1;

    public function ParticleAdvanceEmitter(key:String = null, x:Number = 0, y:Number = 0, posDev:Number = 0, spawnDelay:Number = 1, lifeAvg:Number = 5, lifeDev:Number = 0, scaleAvg:Number = 1, scaleDev:Number = 0)
    {
        super(key, x, y, posDev, spawnDelay, lifeAvg, lifeDev, scaleAvg, scaleDev);
    }

    override public function emit(field:ParticleField, t:Number):void
    {
        initBezier();
        time += t;
        if (hasBezEmitter())
        {
            if (time >= nextSpawn)
            {
                nextSpawn = time + getSpawnDelay();
                if (duration <= 0 || pause <= 0 || time % (pause + duration) <= duration)
                {
                    for (var c:int = 0; c < Math.max(1, (t / getSpawnDelay()) * ParticleField.spawnRatio); c++)
                    {
                        tCurrent = randomT();
                        pCurrent = getBezierEmitter(tCurrent);
                        circularShift();
                        spawnFromPoint(pCurrent.x + oCurrent.x, pCurrent.y + oCurrent.y, field, -1, 0, this);
                    }
                }
            }
        }
    }

    override public function emitForce(field:ParticleField, count:int = 0, k:int = -1, depth:int = 0):void
    {
        initBezier();
        var i:int;
        if (hasBezEmitter())
        {
            if (count > 0)
            {
                for (i = 0; i < Math.max(1, count * ParticleField.spawnRatio); i++)
                {
                    tCurrent = randomT();
                    pCurrent = getBezierEmitter(tCurrent);
                    circularShift();
                    spawnFromPoint(pCurrent.x + oCurrent.x, pCurrent.y + oCurrent.y, field, k, depth < 0 ? recursiveDepth : depth, this);
                }
            } else
            {
                for (i = 0; i < Math.max(1, forceCount * ParticleField.spawnRatio); i++)
                {
                    tCurrent = randomT();
                    pCurrent = getBezierEmitter(tCurrent);
                    circularShift();
                    spawnFromPoint(pCurrent.x + oCurrent.x, pCurrent.y + oCurrent.y, field, k, depth < 0 ? recursiveDepth : depth, this);
                }
            }
        }
    }

    override protected function initVelo():Point
    {
        var vx:Number = 0;
        var vy:Number = 0;
        var magnitude:Number = randomDeviation(veloMagnitude, veloMagnitudeVariance);
        if (magnitude > 0)
        {
            var pDelta:Point;
            var rotation:Number;
            if (tCurrent > 0.5)
            {
                pDelta = getBezierEmitter(tCurrent - tEpsilon);
                rotation = Math.atan2(pCurrent.y - pDelta.y, pCurrent.x - pDelta.x) + randomDeviation2(veloDirection, veloDirectionVariance) + (circularVelocity ? randomAngle : 0);
                vx = magnitude * Math.cos(rotation);
                vy = magnitude * Math.sin(rotation);
            } else
            {
                pDelta = getBezierEmitter(tCurrent + tEpsilon);
                rotation = Math.atan2(pDelta.y - pCurrent.y, pDelta.x - pCurrent.x) + randomDeviation2(veloDirection, veloDirectionVariance) + (circularVelocity ? randomAngle : 0);
                vx = magnitude * Math.cos(rotation);
                vy = magnitude * Math.sin(rotation);
            }
        }
        return new Point(vx, vy);
    }

    //TODO give dev ability to modify emitter
    //Array of Point

    //initBezier won't be used after this since external code will begin handling the guide points
    public function setBezier(...pts):void
    {
        bezierSet = true;
        if (pts.length <= 0)
        {
            hasBezierEmitter = false;
        } else
        {
            bezierEmitterN = [];
            for (var i:int = 0; i < pts.length; i++)
            {
                var choose:Number = chooses(pts.length - 1, i);
                var pt:Point = new Point(Number(pts[i].x) * choose, Number(pts[i].y) * choose);
                bezierEmitterN.push(pt);
            }
            hasBezierEmitter = true;
        }
    }

    public function setBezierArray(pts:Array):void
    {
        bezierSet = true;
        if (pts.length <= 0)
        {
            hasBezierEmitter = false;
        } else
        {
            bezierEmitterN = [];
            for (var i:int = 0; i < pts.length; i++)
            {
                var choose:Number = chooses(pts.length - 1, i);
                var pt:Point = new Point(Number(pts[i].x) * choose, Number(pts[i].y) * choose);
                bezierEmitterN.push(pt);
            }
            hasBezierEmitter = true;
        }
    }

    public function setBezierRange(start:Number, end:Number):void
    {
        bezTStart = Math.max(0, start);
        bezTDiff = Math.min(1, end) - bezTStart;
    }

    private function circularShift():void
    {
        if (!oCurrent)
        {
            oCurrent = new Point();
        }
        randomAngle = Math.random() * Math.PI * 2;
        randomDist = Math.random() * (outerRadius - innerRadius) + innerRadius;
        oCurrent.x = randomDist * Math.cos(randomAngle);
        oCurrent.y = randomDist * Math.sin(randomAngle);
    }

    private function initBezier():void
    {
        if (bezierSet)
        {
            return;
        }

        if (bezierEmitter == "")
        {
            hasBezierEmitter = false;
        } else if (bezierEmitter != bezierEmitterSnap)
        {
            bezierEmitterSnap = new String(bezierEmitter);
            var points:Array = bezierEmitter.split(">");
            bezierEmitterN = [];
            for (var i:int = 0; i < points.length; i++)
            {
                var pair:Array = points[i].split(",");
                var choose:Number = chooses(points.length - 1, i);
                var pt:Point = new Point(Number(pair[0]) * choose, Number(pair[1]) * choose);
                bezierEmitterN.push(pt);
            }
            hasBezierEmitter = true;
        }
    }

    private function randomT():Number
    {
        return bezTStart + bezTDiff * Math.random();
    }
}
}
