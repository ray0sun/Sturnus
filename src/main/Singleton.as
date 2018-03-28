/**
 * Created by raysun on 11/24/15.
 */
package main {
import flash.events.Event;
import flash.filesystem.File;

import starling.utils.AssetManager;

public class Singleton {
    private static var _instance:Singleton;
    private var loadCallBack:Function;

    public var loaded:Number;
    public var assetManager:AssetManager;

    public function Singleton() {}

    public static function get instance():Singleton {
        if(!_instance) {
            _instance = new Singleton();
        }
        return _instance;
    }

    public function setup(callBack:Function):void {
        setupAssetManager(callBack);
    }

    private function setupAssetManager(callBack:Function):void {
        var f:File = new File();
        f.addEventListener(Event.SELECT, onDirSelect);
        f.browseForDirectory("Select asset directory");
        loadCallBack = callBack;
    }

    private function onDirSelect(e:Event):void {
        assetManager = new AssetManager();
        assetManager.enqueue(e.target);
        assetManager.loadQueue(loadCallBack);
    }
}
}
