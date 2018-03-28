/**
 * Created by raysun on 9/20/16.
 */
package util
{
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    import org.as3commons.reflect.Type;
    import org.as3commons.reflect.Variable;

    public class ObjectUtil
    {
        public function ObjectUtil()
        {
        }

        public static function getCallee ( calltStackIndex:int = 3 ) : String
        {
            var stackTrace:Array = new Error().getStackTrace().split( "\n" , calltStackIndex +2 );
            trace(JSON.stringify(stackTrace));
            if(stackTrace.length && stackTrace[calltStackIndex])
            {
                var stackLine:String = stackTrace[calltStackIndex];
                var objectMethod:Array = stackLine.match( /\w*\/*\w*\(\)/g);
                if(objectMethod.length && objectMethod[0])
                    return objectMethod[0];
            }
            return null;
        }

        public static function objectToArray(object:Object):Array
        {
            var array:Array = [];

            for (var id:String in object)
            {
                if (object[id]) array.push(object[id]);
            }

            return array;
        }

        public static function objectKeyToArray(object:Object):Array
        {
            var array:Array = [];

            for (var id:String in object)
            {
                array.push(id);
            }

            return array;
        }

        public static function dictionaryToArray(dict:Dictionary):Array
        {
            var array:Array = [];

            for (var id:Object in dict)
            {
                if (dict[id]) array.push(dict[id]);
            }

            return array;
        }

        public static function vectorToArray(iterable:*):Array
        {
            var arr:Array = [];
            for each (var element:* in iterable)
                arr.push(element);
            return arr;
        }

        public static function concatObjectsToArray(... objects):Array
        {
            var array:Array = [];

            for (var i:int = 0; i < objects.length; i++)
            {
                var object:Object = objects[i];
                array = array.concat(objectToArray(object));
            }

            return array;
        }

        public static function concatObjectsToObject(... objects):Object
        {
            var result:Object = {};

            for (var i:int = 0; i < objects.length; i++)
            {
                var object:Object = objects[i];

                for (var id:String in object)
                {
                    result[id] = object[id];
                }
            }

            return result;
        }

        public static function concatArrayWithoutDuplicate(array1:Array, array2:Array):Array
        {
            var result:Array = [];
            var arr:Array = array1;

            if (!array1 || !array1.length)
                arr = array2;
            if (!arr || !arr.length)
                return result;

            var obj:*;
            var i:int = arr.length;
            while (--i > -1)
            {
                obj = arr[i];
                if (result.indexOf(obj) == -1)
                    result.push(obj);

                if (i == 0 && arr == array1)
                {
                    if (!array2)
                        break;

                    arr = array2;
                    i = arr.length;
                }
            }

            return result;
        }

        public static function isEmptyObject(object:Object):Boolean
        {
            if (object == null) return true;

            for (var id:String in object)
            {
                return false;
            }

            return true;
        }

        public static function isNullValuesObject(object:Object):Boolean
        {
            if (object == null) return true;

            for (var id:String in object)
            {
                if(object[id] !== null)
                    return false;
            }

            return true;
        }

        public static function numOfProperty(object:Object):int
        {
            var num:int = 0;

            for (var id:String in object)
            {
                num++;
            }

            return num;
        }

        public static function objectLength(myObject:Object):int {
            var size:int = 0;
            for (var s:String in myObject) {
                size++;
            }
            return size;
        }

        public static function cloneObject(object:Object):Object
        {
            var clone:ByteArray = new ByteArray();
            clone.writeObject(object);
            clone.position = 0;
            return(clone.readObject());
        }

        public static function fromJSONObject(target:Object, json:Object):void
        {
            var type:Type = Type.forInstance(target);
            for each(var k:* in type.fields)
            {
                if(k is Variable)
                {
                    if(json.hasOwnProperty(k.name))
                        target[k.name] = json[k.name];
                }
            }
        }

        public static function toJSONObject(target:Object):Object
        {
            var obj:Object = {};
            var type:Type = Type.forInstance(target);
            for each(var k:* in type.fields)
            {
                if(k is Variable)
                {
                    obj[k.name] = target[k.name];
                }
            }
            return obj;
        }

        public static function validJSON(text:String):Boolean
        {
            if (/^[\],:{}\s]*$/.test(text.replace(/\\["\\\/bfnrtu]/g, '@').
                            replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']').
                            replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {
                return true;
            }else{
                return false;
            }
        }

        public static function objectValuesFromPropertyNames(obj:Object):Object
        {
            var o:Object = {};
            for (var s:String in obj){
                o[s] = s;
            }
            return o;
        }

        public static function inArray( needle:*, haystack:Array ):Boolean
        {
            // Search variable needle in array haystack
            var itemIndex:int = haystack.indexOf( needle );
            return ( itemIndex < 0 ) ? false : true;
        }
    }
}
