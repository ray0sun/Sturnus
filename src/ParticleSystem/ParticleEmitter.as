/**
 * Created by raysun on 5/24/16.
 */
package ParticleSystem
{

import flash.geom.Point;

import starling.display.BlendMode;

import util.SimpleReflectionObject;

/*
 Emitter that spawns particles:
 -point (circle)
 -line
 -rect
 -handles juggling it's own set of particles
 */
public class ParticleEmitter extends SimpleReflectionObject
{
    //average + a random ratio of the absolute value
    public static function randomDeviation(avg:Number, dev:Number):Number
    {
        return avg + ((Math.random() - 0.5) * Math.abs(avg) * dev);
    }

    //average + a random selection in range
    public static function randomDeviation2(avg:Number, range:Number):Number
    {
        return avg + ((Math.random() - 0.5) * Math.abs(range));
    }

    //returns n choose k
    public static function chooses(n:int, k:int):Number
    {
        if (k == 0 || k == n)
        {
            return 1;
        }
        k = Math.min(k, n - k);
        var c:int = 1;
        for (var i:int = 0; i < k; i++)
        {
            c = c * (n - i) / (i + 1);
        }
        return c;
    }

    public var forceCount:int = 1;

    public var x:Number = 0;
    public var y:Number = 0;
    public var xPrev:Number = -9999;
    public var yPrev:Number = 0;
    private var segRatio:Number;
    private var invRatio:Number;

    public var key:Array;
    protected var ikeyInit:Boolean = false;
    protected var ikey:Vector.<int>;
    public var posDev:Number;
    public var spawnDelay:Number;
    public var lifeAvg:Number;
    public var lifeDev:Number;
    public var scaleAvg:Number;
    public var scaleDev:Number;
    public var pause:Number = 0;
    public var duration:Number = 0;

    public var bezierScale:String = "";
    private var bezierScaleSnap:String;
    private var hasBezierScale:Boolean = false;
    private var bezierScaleN:Vector.<Number>;

    public var bezierAlpha:String = "";
    private var bezierAlphaSnap:String;
    private var hasBezierAlpha:Boolean = false;
    private var bezierAlphaN:Vector.<Number>;

    public var bezierEmitter:String = "";
    protected var hasBezierEmitter:Boolean = false;
    protected var bezierEmitterN:Array;

    public var outerRadius:Number = 0;
    public var innerRadius:Number = 0;
    public var circularVelocity:Boolean = false;

    public var jitter:Number = 0;
    public var jitterRange:Number = 0;
    public var jitterSpeed:Number = 0;
    public var jitterDamp:Number = 1;
    public var jitterAlt:Boolean = true;

    public var alphaScaleBirth:Boolean = true;
    public var alphaScaleDeath:Boolean = true;

    public var forceRotation:Number = 0;
    public var veloRotation:Number = 1;
    public var veloMagnitude:Number = 0;
    public var veloMagnitudeVariance:Number = 0;
    public var veloDirection:Number = 0;
    public var veloDirectionVariance:Number = 0;

    public var gravity:Number = 0;

    public var targetX:Number = 0;
    public var targetY:Number = 0;

    public var tint:uint = 0xffffff;
    public var blendMode:String = BlendMode.NORMAL;

    public var birth:Number = 0.3;
    public var death:Number = 0.7;

    public var finalTarget:Point;
    public var finalAttraction:Number;
    public var allowOvershoot:Boolean = false;
    public var attractionDelay:Number = 0;
    public var attractionDelayVar:Number = 0;

    public var recursiveDepth:int = 0;

    protected var time:Number = 0;
    protected var nextSpawn:Number = 0;

    public var parentField:ParticleField;

    public function ParticleEmitter(key:String = null, x:Number = 0, y:Number = 0, posDev:Number = 0, spawnDelay:Number = 1, lifeAvg:Number = 5, lifeDev:Number = 0, scaleAvg:Number = 1, scaleDev:Number = 0)
    {
        this.x = x;
        this.y = y;
        this.key = [];
        clearKey();
        if (key)
        {
            this.key.push(key);
        }
        this.posDev = posDev;
        this.spawnDelay = spawnDelay;
        this.lifeAvg = lifeAvg;
        this.lifeDev = lifeDev;
        this.scaleAvg = scaleAvg;
        this.scaleDev = scaleDev;
    }

    //typically used in editor to clear ikey refs
    public function clearKey():void
    {
        this.ikeyInit = false;
        this.ikey = new <int>[];
    }

    //once a field is read with the texture name to int table this is called when we first need it
    public function setKey():void
    {
        var idx:int;
        for(var i:int=0; i<key.length; i++){
            idx = ParticleField.keyIndex(key[i]);
            if(idx >= 0){
                ikey.push(idx);
            }
        }
        ikeyInit = true;
    }

    public function getRandomKey():int
    {
        if (!ikeyInit)
        {
            setKey();
        }
        var randIdx:int = Math.floor(Math.random() * ikey.length);
        return ikey[Math.min(ikey.length - 1, Math.max(0, randIdx))];
    }

    public function emit(field:ParticleField, t:Number):void
    {
        time += t;
        if (time >= nextSpawn)
        {
            nextSpawn = time + getSpawnDelay();
            if (duration <= 0 || pause <= 0 || time % (pause + duration) <= duration)
            {
                for (var c:int = 0; c < Math.max(1, (t / getSpawnDelay()) * ParticleField.spawnRatio); c++)
                {
                    segRatio = xPrev == -9999 ? 1 : Math.random();
                    invRatio = 1 - segRatio;
                    spawnFromPoint(x * segRatio + invRatio * xPrev, y * segRatio + invRatio * yPrev, field, -1, 0, this);
                }
            }
        }
    }

    public function emitForce(field:ParticleField, count:int = 0, k:int = -1, depth:int = -1):void
    {
        var i:int;
        if (count > 0)
        {
            for (i = 0; i < Math.max(1, count * ParticleField.spawnRatio); i++)
            {
                spawnFromPoint(x, y, field, k, depth < 0 ? recursiveDepth : depth, this);
            }
        } else
        {
            for (i = 0; i < Math.max(1, forceCount * ParticleField.spawnRatio); i++)
            {
                spawnFromPoint(x, y, field, k, depth < 0 ? recursiveDepth : depth, this);
            }
        }
    }

    public function hasBezScale():Boolean
    {
        return hasBezierScale;
    }

    public function getBezierScale(t:Number):Number
    {
        return getBezier(t, bezierScaleN);
    }

    public function hasBezAlpha():Boolean
    {
        return hasBezierAlpha;
    }

    public function getBezierAlpha(t:Number):Number
    {
        return getBezier(t, bezierAlphaN);
    }

    public function hasBezEmitter():Boolean
    {
        return hasBezierEmitter;
    }

    public function getBezierEmitter(t:Number):Point
    {
        return getBezierPoint(t, bezierEmitterN);
    }

    public static function getBezier(t:Number, c:Vector.<Number>):Number
    {
        var ret:Number = 0;
        for (var i:int = 0; i < c.length; i++)
        {
            ret += c[i] * Math.pow(1 - t, c.length - 1 - i) * Math.pow(t, i);
        }
        return ret;
    }

    public function setJitter(count:Number = 0, range:Number = 0, speed:Number = 0, damp:Number = 0, alt:Boolean = true):void
    {
        jitter = count;
        jitterRange = range;
        jitterSpeed = speed;
        jitterDamp = damp;
        jitterAlt = alt;
    }

    public function setVelocity(magnitude:Number = 0, variance:Number = 0, angle:Number = 0, range:Number = 0):void
    {
        veloMagnitude = magnitude;
        veloMagnitudeVariance = variance;
        veloDirection = angle;
        veloDirectionVariance = range;
    }

    public function setFinalTarget(tx:Number, ty:Number, attraction:Number = 0.1, delay:Number = 0, delayVar:Number = 0):void
    {
        if (!finalTarget)
        {
            finalTarget = new Point(tx, ty);
        }
        finalTarget.setTo(tx, ty);
        finalAttraction = attraction;
        attractionDelay = delay;
        attractionDelayVar = delayVar;
    }

    protected function initVelo():Point
    {
        var vx:Number = 0;
        var vy:Number = 0;
        var magnitude:Number = randomDeviation(veloMagnitude, veloMagnitudeVariance);
        if (magnitude > 0)
        {
            var rotation:Number = randomDeviation2(veloDirection, veloDirectionVariance);
            vx = magnitude * Math.cos(rotation);
            vy = magnitude * Math.sin(rotation);
        }
        return new Point(vx, vy);
    }

    protected function spawnFromPoint(px:Number, py:Number, field:ParticleField, k:int = -1, depth:int = 0, origin:ParticleEmitter = null):void
    {
        var coef:Array;
        if (bezierScale == "" || bezierScale == null)
        {
            hasBezierScale = false;
        } else if (bezierScale != bezierScaleSnap)
        {
            bezierScaleSnap = String(bezierScale);
            coef = bezierScale.split(",");
            bezierScaleN = new <Number>[];
            for (var i:int = 0; i < coef.length; i++)
            {
                bezierScaleN.push(Number(coef[i]) * chooses(coef.length - 1, i));
            }
            hasBezierScale = true;
        }

        if (bezierAlpha == "" || bezierAlpha == null)
        {
            hasBezierAlpha = false;
        } else if (bezierAlpha != bezierAlphaSnap)
        {
            bezierAlphaSnap = String(bezierAlpha);
            coef = bezierAlpha.split(",");
            bezierAlphaN = new <Number>[];
            for (var j:int = 0; j < coef.length; j++)
            {
                bezierAlphaN.push(Number(coef[j]) * chooses(coef.length - 1, j));
            }
            hasBezierAlpha = true;
        }

        var scale:Number = randomDeviation(scaleAvg, scaleDev);
        var life:Number = randomDeviation(lifeAvg, lifeDev);

        var velo:Point = initVelo();

        var p:Particle = field.spawn(k >= 0 ? k : getRandomKey(), randomDeviation2(px, posDev), randomDeviation2(py, posDev), velo.x, velo.y, scale, scale, 0, life, birth, death);
        if (!p)
        {
            return;
        }

        if (targetX && targetY)
        {
            p.jitter = 0;
            p.jitterRange = 0;
            p.jitterSpeed = jitterSpeed;
            p.jitterDamp = jitterDamp;
            p.jitterAlt = 0;
            p.tx = targetX;
            p.ty = targetY;
        } else
        {
            p.jitter = jitter;
            p.jitterRange = jitterRange;
            p.jitterSpeed = jitterSpeed;
            p.jitterDamp = jitterDamp;
            p.jitterAlt = jitterAlt;
        }

        p.alphaScaleBirth = alphaScaleBirth;
        p.alphaScaleDeath = alphaScaleDeath;
        p.veloRotation = veloRotation;
        p.forceRotation = forceRotation;

        p.setRotationVars();

        p.gravity = gravity;

        p.recursiveDepth = depth;
        p.originalEmitter = origin;

        if (finalTarget)
        {
            p.setFinalTarget(finalTarget.x, finalTarget.y, finalAttraction);
            p.allowOvershoot = allowOvershoot;
            p.attractionDelay = randomDeviation(attractionDelay, attractionDelayVar);
        }
    }

    protected function getSpawnDelay():Number
    {
        return Math.max(spawnDelay, 0.001);
    }

    private function getBezierPoint(t:Number, c:Array):Point
    {
        var ret:Point = new Point();
        for (var i:int = 0; i < c.length; i++)
        {
            var co:Number = Math.pow(1 - t, c.length - 1 - i) * Math.pow(t, i);
            ret.x += c[i].x * co;
            ret.y += c[i].y * co;
        }
        return ret;
    }
}
}
