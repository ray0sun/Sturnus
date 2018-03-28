/**
 * Created by raysun on 5/25/16.
 */
package ParticleSystem
{
public class ParticleLineEmitter extends ParticleEmitter
{
    public var x2:Number = 0;
    public var y2:Number = 0;

    public function ParticleLineEmitter(key:String = null, x:Number = 0, y:Number = 0, x2:Number = 0, y2:Number = 0, posDev:Number = 0, spawnDelay:Number = 1, lifeAvg:Number = 5, lifeDev:Number = 0, scaleAvg:Number = 1, scaleDev:Number = 0)
    {
        super(key, x, y, posDev, spawnDelay, lifeAvg, lifeDev, scaleAvg, scaleDev);
        this.x2 = x2;
        this.y2 = y2;
    }

    override public function emit(field:ParticleField, t:Number):void
    {
        time += t;
        if (time >= nextSpawn)
        {
            nextSpawn = time + getSpawnDelay();
            if (duration <= 0 || pause <= 0 || time % (pause + duration) <= duration)
            {
                for (var c:int = 0; c < Math.max(1, (t / getSpawnDelay()) * ParticleField.spawnRatio); c++)
                {
                    var ratio:Number = Math.random();
                    spawnFromPoint(ratio * x + (1 - ratio) * x2, ratio * y + (1 - ratio) * y2, field, null, 0, this);
                }
            }
        }
    }

    override public function emitForce(field:ParticleField, count:int = 0, k:int = -1, depth:int = 0):void
    {
        var i:int;
        var ratio:Number;
        if (count > 0)
        {
            for (i = 0; i < Math.max(1, count * ParticleField.spawnRatio); i++)
            {
                ratio = Math.random();
                spawnFromPoint(ratio * x + (1 - ratio) * x2, ratio * y + (1 - ratio) * y2, field, k, depth < 0 ? recursiveDepth : depth, this);
            }
        } else
        {
            for (i = 0; i < Math.max(1, forceCount * ParticleField.spawnRatio); i++)
            {
                ratio = Math.random();
                spawnFromPoint(ratio * x + (1 - ratio) * x2, ratio * y + (1 - ratio) * y2, field, k, depth < 0 ? recursiveDepth : depth, this);
            }
        }
    }
}
}
