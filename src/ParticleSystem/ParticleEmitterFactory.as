/**
 * Created by raysun on 8/24/16.
 */
package ParticleSystem
{
public class ParticleEmitterFactory
{
    public static function createEmitter(dataObject:Object):ParticleEmitter
    {
        var emitter:ParticleEmitter = new ParticleEmitter();
        emitter.fromJSONObject(dataObject);
        return emitter;
    }

    public static function createLineEmitter(dataObject:Object):ParticleLineEmitter
    {
        var emitter:ParticleLineEmitter = new ParticleLineEmitter();
        emitter.fromJSONObject(dataObject);
        emitter.x2 = emitter.x;
        emitter.y2 = emitter.x;
        return emitter;
    }

    public static function createAdvanceEmitter(dataObject:Object):ParticleAdvanceEmitter
    {
        var emitter:ParticleAdvanceEmitter = new ParticleAdvanceEmitter();
        emitter.fromJSONObject(dataObject);
        return emitter;
    }

    public function ParticleEmitterFactory()
    {
    }
}
}
