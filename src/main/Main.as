package main {

import flash.display.Sprite;
import flash.geom.Rectangle;

import starling.core.Starling;
import starling.events.Event;
import starling.events.ResizeEvent;

[SWF(width="1600",height="900",frameRate="60",backgroundColor="#000000")]

public class Main extends Sprite {
    private var starling:Starling;

    public function Main() {
        starling = new Starling(Sturnus, stage);
        starling.start();
        Starling.current.stage.addEventListener(Event.RESIZE, onResize);
    }

    private function onResize(e:ResizeEvent):void {
        Starling.current.viewPort = new Rectangle(0, 0, e.width, e.height);
    }
}
}
