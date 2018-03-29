/**
 * Created by raysun on 11/24/15.
 */
package main {
import flash.filesystem.File;

import starling.utils.AssetManager;

public class Singleton {
    private static var _instance:Singleton;

    public var assetManager:AssetManager;

    public function Singleton() {}

    public static function get instance():Singleton {
        if(!_instance) {
            _instance = new Singleton();
        }
        return _instance;
    }

    public function setup(callBack:Function):void {
        //var appDirStore:File = File.applicationStorageDirectory;  //use for save configs and such
        var appDir:File = File.applicationDirectory;
        assetManager = new AssetManager();
        assetManager.enqueue(appDir.resolvePath("assets/out"));
        assetManager.loadQueue(callBack);
    }
}
}
