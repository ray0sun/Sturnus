/**
 * Created by raysun on 11/23/15.
 */
package main
{
import feathers.display.Scale9Image;
import feathers.textures.Scale9Textures;

import flash.geom.Rectangle;

import starling.core.StatsDisplay;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.ResizeEvent;

public class Sturnus extends Sprite
{
    public static var instance:Sturnus;
    public static var w:Number;
    public static var h:Number;

    private static var tm:Sprite;

    public function Sturnus()
    {
        instance = this;
        Singleton.instance.setup(loadApp);
        addEventListener(starling.events.Event.ENTER_FRAME, onEnterFrame);
    }

    public static function onResize(e:ResizeEvent):void
    {
        w = e.width;
        h = e.height;

        if(tm){
            tm.width = 0.2 * w;
            tm.height = 0.2 * h;
        }
    }

    private function onEnterFrame(e:EnterFrameEvent):void
    {

    }

    private function loadApp(loaded:Number):void
    {
        if (loaded >= 1)
        {
            tm = new Scale9Image(new Scale9Textures(Singleton.instance.assetManager.getTexture("rainbow_ring_01"), new Rectangle(65,65,5,5))) as Sprite;
            addChild(tm);
        }
    }
}
}
