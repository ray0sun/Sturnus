/**
 * Created by raysun on 7/28/16.
 */
package ParticleSystem
{
import main.Singleton;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;

import ui.AssetList;
import ui.AssetListElement;

public class ParticleEffects
{
    public function ParticleEffects()
    {
    }

    public static function initField(field:ParticleField):void
    {
        for each(var asset:AssetListElement in AssetList.assets)
        {
            field.add(asset.id, new Image(Singleton.instance.assetManager.getTexture(asset.id)));
        }
    }
}
}
