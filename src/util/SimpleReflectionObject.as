/**
 * Created by raysun on 9/20/16.
 */
package util
{
    public class SimpleReflectionObject
    {
        public function SimpleReflectionObject(object:Object = null):void
        {
            if(object != null)
            {
                fromJSONObject(object);
            }
        }

        public function fromJSONObject(object:Object):void
        {
            ObjectUtil.fromJSONObject(this, object);
        }

        public function toJSONObject():Object
        {
            return ObjectUtil.toJSONObject(this);
        }

        public function dump():void
        {
            trace(JSON.stringify(toJSONObject()));
        }
    }
}
