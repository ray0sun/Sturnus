/**
 * Created by raysun on 5/24/16.
 */
package ParticleSystem
{
import starling.display.BlendMode;
import starling.display.Image;
import starling.display.Quad;
import starling.display.QuadBatch;
import starling.display.Sprite;

//TODO Enable in game
/*
DEFINE::MOBILE
{
    import com.mobscience.match.match;
}
*/

/*
 container for the particles and emitters:
 -lifetimes
 -boundaries
 -universal properties (wind, gravity...)
 -holds the actual quad batch and image asset handling
 -only full field effect teleport to mirrored edges
 */
public class ParticleField extends Sprite
{
    //Set to true to speed up debug testing
    private static const DISABLED:Boolean = false;
    public static var fps:Number = 0;
    public static var spawnRatio:Number = 1;
    public static var forceSpawn:Boolean = false;

    //String keys convert into int when using add() for faster usage
    //When emitter tries to emit it'll try to use ikey (which is converted using this table from it's own key array at first use)
    public static var ikey:int = 0;
    public static var keyTable:Object = {};

    //needs to be in the same coordinates as the field obviously
    private static var imagePool:Vector.<Image> = new <Image>[];
    private static var imageWidths:Vector.<Number> = new <Number>[];
    private static var imageHeights:Vector.<Number> = new <Number>[];

    private var particlePool:Vector.<Particle>;
    private var particles:Vector.<Particle>;
    private var emitters:Vector.<ParticleEmitter>;

    private var boundary:Quad;
    private var disp:QuadBatch;
    private var dispAdd:QuadBatch;

    public function ParticleField(width:Number, height:Number)
    {
        particlePool = new <Particle>[];
        particles = new <Particle>[];
        emitters = new <ParticleEmitter>[];

        boundary = new Quad(Math.max(width, 1), Math.max(height, 1), 0xff0000);
        boundary.alpha = 0;
        addChild(boundary);

        disp = new QuadBatch();
        addChild(disp);

        dispAdd = new QuadBatch();
        addChild(dispAdd);
    }

    //creates a particle with the key named asset
    public function spawn(key:int, x:Number = 0, y:Number = 0, vx:Number = 0, vy:Number = 0, sclx:Number = 1, scly:Number = 1, alpha:Number = 1, life:Number = 5, birth:Number = 0.3, death:Number = 0.7):Particle
    {
        if (key < 0 || DISABLED)
        {
            return null;
        }
        var p:Particle;

        var img:Image = imagePool[key];
        var imgWidth:Number = imageWidths[key];
        var imgHeight:Number = imageHeights[key];
        if (!img)
        {
            return null;
        }

        if (particlePool.length > 0)
        {
            p = particlePool.pop();
            p.init(imagePool[key], imgWidth, imgHeight, x, y, vx, vy, sclx, scly, alpha, life, birth, death);
        } else
        {
            p = new Particle(imagePool[key], imgWidth, imgHeight, x, y, vx, vy, sclx, scly, alpha, life, birth, death);
        }

        if (p)
        {
            particles.push(p);
        }

        return p;
    }

    //moves all emitter centers to x,y
    public function move(x:Number, y:Number):void
    {
        var emitterCount:int = emitters.length;
        for (var i:int = 0; i < emitterCount; ++i)
        {
            emitters[i].x = x;
            emitters[i].y = y;
        }
    }

    //moves all emitter relative to target
    public function moveRelative(x:Number, y:Number, target:ParticleEmitter):void
    {
        var dx:Number = x - target.x;
        var dy:Number = y - target.y;
        var emitterCount:int = emitters.length;
        for (var i:int = 0; i < emitterCount; ++i)
        {
            emitters[i].x += dx;
            emitters[i].y += dy;
        }
    }

    public function onEnterFrame(time:Number, xoff:Number = 0, yoff:Number = 0):void
    {
        emit(time);
        fps = (1 / time) * 0.2 + fps * 0.8;
        if (!forceSpawn)
        {
            spawnRatio = Math.min(1, fps / 60);
            spawnRatio = Math.pow(spawnRatio, (60 - fps) / 12);

            //Temp limiter
            spawnRatio = spawnRatio * 0.8;
        }
        for (var i:int = 0; i < particles.length; i++)
        {
            particles[i].update(time);
            if (particles[i].life >= particles[i].lifeMax)
            {
                if (particles[i].originalEmitter && particles[i].recursiveDepth > 0)
                {
                    (particles[i].originalEmitter as ParticleEmitter).x = particles[i].x;
                    (particles[i].originalEmitter as ParticleEmitter).y = particles[i].y;
                    (particles[i].originalEmitter as ParticleEmitter).emitForce(this, 0, -1, particles[i].recursiveDepth - 1);
                }
                particlePool.push(particles.removeAt(i));
            }
        }
        draw(xoff, yoff);
    }

    public function resize(width:Number, height:Number):void
    {
        boundary.width = width;
        boundary.height = height;
    }

    public static function keyIndex(key:String):int
    {
        return keyTable[key] != null ? keyTable[key] : -1;
    }

    //adds an asset to the dictionary for use
    public function add(key:String, img:Image):void
    {
        if(!keyTable[key]){
            keyTable[key] = ikey++;
            imagePool[keyTable[key]] = img;
            imageWidths[keyTable[key]] = img.width;
            imageHeights[keyTable[key]] = img.height;
        }
    }

    public function addEmitter(emitter:ParticleEmitter):void
    {
        emitters.push(emitter);
        emitter.parentField = this;
    }

    public function removeEmitter(emitter:ParticleEmitter):void
    {
        var idx:int = emitters.indexOf(emitter);
        if (idx >= 0)
        {
            emitters.removeAt(idx).parentField = null;
        }
    }

    public function removeEmitters():void
    {
        emitters.length = 0;
    }

    public function removeParticles():void
    {
        particles.length = 0;
        particlePool.length = 0;
    }

    public function containsEmitter(emitter:ParticleEmitter):Boolean
    {
        return emitters.indexOf(emitter) >= 0
    }

    private function emit(time:Number):void
    {
        var emitterCount:int = emitters.length;
        for (var i:int = 0; i < emitterCount; ++i)
        {
            emitters[i].emit(this, time);
            emitters[i].xPrev = emitters[i].x;
            emitters[i].yPrev = emitters[i].y;
        }
    }

    private function draw(xoff:Number = 0, yoff:Number = 0):void
    {
        //TODO Enable in game
        /*
        DEFINE::MOBILE
        {
            if (!match.appActive)
            {
                return;
            }
        }
        */

        disp.reset();
        dispAdd.reset();

        var particleCount:int = particles.length;
        for (var i:int = 0; i < particleCount; ++i)
        {
            var instance:Image = (particles[i] as Particle).getBatchInstance();
            if (instance.blendMode == BlendMode.ADD)
            {
                dispAdd.addImage(instance);
            } else
            {
                disp.addImage(instance);
            }
        }

        disp.x = xoff;
        disp.y = yoff;
        dispAdd.x = xoff;
        dispAdd.y = yoff;
    }
}
}
