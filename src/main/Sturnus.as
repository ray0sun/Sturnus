/**
 * Created by raysun on 11/23/15.
 */
package main
{
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;

public class Sturnus extends Sprite
{
    public static const w:Number = 1600;
    public static const h:Number = 900;
    public static var instance:Sturnus;
    public static var scale:Image;

    public function Sturnus()
    {
        Singleton.instance.setup(loadApp);
        addEventListener(starling.events.Event.ENTER_FRAME, onEnterFrame);
        instance = this;
    }

    private function onEnterFrame(e:EnterFrameEvent):void
    {
    }

    private function loadApp(loaded:Number):void
    {
        if (loaded >= 1)
        {
        }
    }
}
}
