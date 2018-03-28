package main
{

import flash.display.Sprite;
import flash.geom.Rectangle;

import starling.core.Starling;
import starling.events.Event;
import starling.events.ResizeEvent;

[SWF(width="1280", height="720", frameRate="60", backgroundColor="#000000")]

public class Main extends Sprite
{
    private var starling:Starling;

    public function Main()
    {
        starling = new Starling(Sturnus, stage);
        starling.start();
        Starling.current.stage.addEventListener(Event.RESIZE, onResize);
        Starling.current.showStatsAt("right", "bottom");
    }

    private function onResize(e:ResizeEvent):void
    {
        if (Math.min(e.width, e.height) > 200)
        {
            Starling.current.viewPort = new Rectangle(0, 0, e.width, e.height);
            Starling.current.stage.stageWidth = e.width;
            Starling.current.stage.stageHeight = e.height;
            Starling.current.showStatsAt("right", "bottom");
            Sturnus.onResize(e);
        }
    }
}
}
