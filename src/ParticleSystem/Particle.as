/**
 * Created by raysun on 5/24/16.
 */
package ParticleSystem
{
import flash.geom.Point;

import starling.display.BlendMode;

import starling.display.Image;

/*
 singular particles:
 -image ref and quadbatch functions
 -velocity
 -other utils?
 */
public class Particle
{
    public static const Epsilon:Number = 0.001;

    //if the particle should follow the particle field draw offset or not (default follows)
    public var gravity:Number = 0;

    public var img:Image;
    public var x:Number;
    public var y:Number;
    public var vx:Number;
    public var vy:Number;
    public var sclx:Number;
    public var scly:Number;
    public var life:Number;
    public var lifeMax:Number;
    public var alpha:Number;
    public var birth:Number;
    public var death:Number;

    public var jitter:Number = 0;
    public var jitterRange:Number = 0;
    public var jitterSpeed:Number = 0;
    public var jitterDamp:Number = 0;

    public var rotation:Number = 0;
    public var attractionDelay:Number = 0;

    public var jitterAlt:Boolean = true;        //use pure directional acceleration instead of using distance
    public var allowOvershoot:Boolean = false;  //if the particles have a final dest, don't let distance increase (only decrease)
    public var alphaScaleBirth:Boolean = true;  //if the particle scale should be multiplied by alpha during birth
    public var alphaScaleDeath:Boolean = true;  //if the particle scale should be multiplied by alpha during death
    public var veloRotation:Number = 1;
    public var forceRotation:Number = 0;
    public var dying:Boolean = false;

    public var originalEmitter:ParticleEmitter;
    public var recursiveDepth:int = 0;
    public var tx:Number;
    public var ty:Number;
    private var lifeRatio:Number;
    private var baseAlpha:Number;
    private var jitterCount:Number;
    private var width:Number;
    private var height:Number;
    private var finalTarget:Point;
    private var finalAttraction:Number;
    private var minDist:Number = Number.MAX_VALUE;

    //temp vals
    private var d:Number;
    private var dx:Number;
    private var dy:Number;
    private var len:Number;

    private var cacheW:Number;
    private var cacheH:Number;

    private var dim:Number;
    private var targRotation1:Number;
    private var rotDiff1:Number;
    private var targRotation2:Number;
    private var rotDiff2:Number;
    private var targRotation3:Number;
    private var rotDiff3:Number;
    private var prevRotation:Number;
    private var veloRotaionInverse:Number;

    public function Particle(img:Image, imgWidth:Number, imgHeight:Number, x:Number = 0, y:Number = 0, vx:Number = 0, vy:Number = 0, sclx:Number = 1, scly:Number = 1, alpha:Number = 1, life:Number = 5, birth:Number = 0.3, death:Number = 0.7)
    {
        init(img, imgWidth, imgHeight, x, y, vx, vy, sclx, scly, alpha, life, birth, death);
    }

    public function init(img:Image, imgWidth:Number, imgHeight:Number, x:Number = 0, y:Number = 0, vx:Number = 0, vy:Number = 0, sclx:Number = 1, scly:Number = 1, alpha:Number = 1, life:Number = 5, birth:Number = 0.3, death:Number = 0.7):void
    {
        gravity = 0;

        this.img = img;
        this.img.alignPivot();
        this.x = x;
        this.y = y;
        this.vx = vx;
        this.vy = vy;
        this.sclx = sclx;
        this.scly = scly;
        this.alpha = alpha;
        this.baseAlpha = alpha;
        this.life = 0;
        this.lifeMax = life;
        this.birth = birth;
        this.death = death;

        cacheW = imgWidth;
        cacheH = imgHeight;

        jitter = 0;
        jitterRange = 0;
        jitterSpeed = 0;
        jitterDamp = 0;

        jitterAlt = true;
        allowOvershoot = false;
        alphaScaleBirth = true;
        alphaScaleDeath = true;
        veloRotation = 1;
        forceRotation = 0;
        dying = false;

        setRotationVars();

        tx = 0;
        ty = 0;

        jitterCount = 0;
        attractionDelay = 0;
        finalTarget = null;
        finalAttraction = 0;
        minDist = Number.MAX_VALUE;

        originalEmitter = null;
        recursiveDepth = 0;
    }

    public function setRotationVars():void
    {
        veloRotaionInverse = 1 - veloRotation;
        rotation = veloRotation > 0 ? Math.atan2(vy, vx) : Math.random() * Math.PI * 2;
        prevRotation = rotation;
    }

    public function setFinalTarget(x:Number, y:Number, attraction:Number = 0.1):void
    {
        finalTarget = new Point(x, y);
        finalAttraction = attraction;
    }

    public function update(time:Number):void
    {
        life += time;
        lifeRatio = life / lifeMax;

        width = cacheW * sclx;
        height = cacheH * scly;
        dim = Math.max(width, height);

        if (jitter > 0 && jitterCount < jitter && jitterCount / jitter <= lifeRatio)
        {
            jitterCount += 1;
            tx = x + (Math.random() - 0.5) * jitterRange * dim;
            ty = y + (Math.random() - 0.5) * jitterRange * dim;
        }

        if (tx && ty)
        {
            if (jitterAlt)
            {
                dx = tx - x;
                dy = ty - y;
                len = 1 / Math.max(Math.sqrt(dx * dx + dy * dy), Epsilon);
                vx += dx * len * jitterSpeed * dim;
                vy += dy * len * jitterSpeed * dim;
            } else
            {
                vx += (tx - x) * jitterSpeed;
                vy += (ty - y) * jitterSpeed;
            }
        }

        if (finalTarget && life > attractionDelay)
        {
            dx = finalTarget.x - x;
            dy = finalTarget.y - y;
            d = Math.max(Math.sqrt(dx * dx + dy * dy), Epsilon);
            len = 1 / d;
            vx += dx * len * finalAttraction * dim;
            vy += dy * len * finalAttraction * dim;
            if ((d > minDist) && !dying)
            {
                life = lifeMax + 1;
                dying = true;
            } else
            {
                minDist = d;
            }
        }

        vy += gravity * dim;
        vx *= jitterDamp;
        vy *= jitterDamp;
        x += vx;
        y += vy;

        if (lifeRatio < birth)
        {
            alpha = lifeRatio / birth;
        } else if (lifeRatio < death)
        {
            alpha = 1;
        } else
        {
            alpha = (1 - lifeRatio) / (1 - death);
        }
    }

    public function getBatchInstance():Image
    {
        img.rotation = 0;
        img.x = x;
        img.y = y;

        if (originalEmitter && originalEmitter.hasBezScale())
        {
            var sclBezier:Number = originalEmitter.getBezierScale(lifeRatio);
            img.scaleX = sclx * sclBezier;
            img.scaleY = scly * sclBezier;
        } else if ((alphaScaleBirth && lifeRatio < birth) || (alphaScaleDeath && lifeRatio >= death))
        {
            img.scaleX = sclx * Math.max(0.05, alpha);
            img.scaleY = scly * Math.max(0.05, alpha);
        } else
        {
            img.scaleX = sclx;
            img.scaleY = scly;
        }

        if (originalEmitter && originalEmitter.hasBezAlpha())
        {
            img.alpha = originalEmitter.getBezierAlpha(lifeRatio);
        } else
        {
            img.alpha = alpha;
        }

        if (forceRotation != 0)
        {
            img.rotation = prevRotation + forceRotation;
        } else
        {
            targRotation1 = Math.atan2(vy, vx);
            targRotation2 = Math.atan2(vy, vx) + Math.PI * 2;
            targRotation3 = Math.atan2(vy, vx) - Math.PI * 2;
            rotDiff1 = Math.abs(targRotation1 - prevRotation);
            rotDiff2 = Math.abs(targRotation2 - prevRotation);
            rotDiff3 = Math.abs(targRotation3 - prevRotation);
            switch (Math.min(rotDiff1, rotDiff2, rotDiff3))
            {
            case rotDiff1:
                img.rotation = prevRotation * veloRotaionInverse + targRotation1 * veloRotation;
                break;
            case rotDiff2:
                img.rotation = prevRotation * veloRotaionInverse + targRotation2 * veloRotation;
                break;
            case rotDiff3:
                img.rotation = prevRotation * veloRotaionInverse + targRotation3 * veloRotation;
                break;
            }
        }

        if (originalEmitter)
        {
            img.color = originalEmitter.tint;
            switch (originalEmitter.blendMode)
            {
            case BlendMode.NORMAL:
                img.blendMode = BlendMode.NORMAL;
                break;
            case BlendMode.ADD:
                img.blendMode = BlendMode.ADD;
                break;
            }
        } else
        {
            img.color = 0xffffff;
            img.blendMode = BlendMode.NORMAL;
        }

        prevRotation = img.rotation;
        return img;
    }
}
}
