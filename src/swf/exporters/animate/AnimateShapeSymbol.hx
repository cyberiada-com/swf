package swf.exporters.animate;

import openfl.display.BitmapData;
import openfl.display.CapsStyle;
import openfl.display.GradientType;
import openfl.display.InterpolationMethod;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.Shape;
import openfl.display.SpreadMethod;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(swf.exporters.animate.AnimateLibrary)
@:access(openfl.display.CapsStyle)
@:access(openfl.display.GradientType)
@:access(openfl.display.InterpolationMethod)
@:access(openfl.display.JointStyle)
@:access(openfl.display.LineScaleMode)
@:access(openfl.display.SpreadMethod)
class AnimateShapeSymbol extends AnimateSymbol
{
	public var commands:Array<AnimateShapeCommand>;
	public var rendered:Shape;

	public function new()
	{
		super();
	}

	private override function __createObject(library:AnimateLibrary):Shape
	{
		var shape = new Shape();
		var graphics = shape.graphics;

		if (rendered != null)
		{
			graphics.copyFrom(rendered.graphics);
			return shape;
		}

		for (command in commands)
		{
			switch (command)
			{
				case BeginFill(color, alpha):
					graphics.beginFill(color, alpha);

				case BeginBitmapFill(bitmapID, matrix, repeat, smooth):
					#if lime
					var bitmapSymbol:AnimateBitmapSymbol = cast library.symbols.get(bitmapID);
					var bitmap = library.getImage(bitmapSymbol.path);

					if (bitmap != null)
					{
						graphics.beginBitmapFill(BitmapData.fromImage(bitmap), matrix, repeat, smooth);
					}
					#end

				case BeginGradientFill(fillType, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio):
					#if flash
					var colors:Array<UInt> = cast colors;
					#end
					graphics.beginGradientFill(GradientType.fromInt(fillType), colors, alphas, ratios, matrix, SpreadMethod.fromInt(spreadMethod),
						InterpolationMethod.fromInt(interpolationMethod), focalPointRatio);

				case CurveTo(controlX, controlY, anchorX, anchorY):
					graphics.curveTo(controlX, controlY, anchorX, anchorY);

				case EndFill:
					graphics.endFill();

				case LineStyle(thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit):
					if (thickness != null)
					{
						graphics.lineStyle(thickness, color, alpha, pixelHinting, LineScaleMode.fromInt(scaleMode), CapsStyle.fromInt(caps),
							JointStyle.fromInt(joints), miterLimit);
					}
					else
					{
						graphics.lineStyle();
					}

				case LineTo(x, y):
					graphics.lineTo(x, y);

				case MoveTo(x, y):
					graphics.moveTo(x, y);
			}
		}

		commands = null;
		rendered = new Shape();
		rendered.graphics.copyFrom(shape.graphics);

		return shape;
	}
}
