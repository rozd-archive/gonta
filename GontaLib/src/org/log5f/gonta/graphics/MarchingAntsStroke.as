package org.log5f.gonta.graphics
{
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import mx.events.PropertyChangeEvent;
	import mx.graphics.SolidColorStroke;
	
	public class MarchingAntsStroke extends SolidColorStroke
	{
		//----------------------------------------------------------------------
		//
		//	Class variables
		//
		//----------------------------------------------------------------------
		
		private static const SEGEMENT:uint = 4;
		
		private static const COLORS:Vector.<uint> = 
			Vector.<uint>([0xFFFFFF, 0x000000]);
		
		public static var bmds:Vector.<BitmapData>;
		
		//----------------------------------------------------------------------
		//
		//	Static initialization
		//
		//----------------------------------------------------------------------
		
		{
			initialize();
		}
		
		//----------------------------------------------------------------------
		//
		//	Class functions
		//
		//----------------------------------------------------------------------
		
		private static function initialize():void
		{
			const STEPS:uint = SEGEMENT * SEGEMENT;
			const SIZE:uint = SEGEMENT * SEGEMENT;
			
			bmds = new Vector.<BitmapData>(STEPS);
			
			for (var b:int = 0; b < STEPS; b++)
			{
				var bmd:BitmapData = new BitmapData(SIZE, SIZE, false, COLORS[0]);
				
				var j:int = 0;
				
				var k:int = 0;
				var l:int = 0;
				
				for (j = 0; j < SIZE; j++)
				{
					l = j % (SEGEMENT * 2);
					
					var n:uint = SIZE + SEGEMENT + b;
					for (var i:int = 0; i < n; i++)
					{
						if (i % SEGEMENT == 0)
							k = i / SEGEMENT;
						
						if (k % 2 == 0)
						{
							bmd.setPixel(i + (SEGEMENT - l) - b, j, COLORS[1]);
						}
					}
				}
				
				bmds[b] = bmd;
			}
		}
		
		//----------------------------------------------------------------------
		//
		//	Constructor
		//
		//----------------------------------------------------------------------
		
		/** Constructor */
		public function MarchingAntsStroke()
		{
			super();
			
			this.initTimer();
		}
		
		//----------------------------------------------------------------------
		//
		//	Variables
		//
		//----------------------------------------------------------------------
		
		private var displacement:uint = 0;
		
		private var timer:Timer;
		
		private var origin:Point;
		private var bounds:Rectangle;
		private var graphics:Graphics;
		
		//----------------------------------------------------------------------
		//
		//	Properties
		//
		//----------------------------------------------------------------------
		
		//-----------------------------------
		//	interval
		//-----------------------------------
		
		/** @private */
		private var _interval:uint = 60;
		
		[Bindable(event="propertyChange")]
		/** TODO (mrozdobudko): TBD */
		public function get interval():uint
		{
			return this._interval;
		}
		
		/** @private */
		public function set interval(value:uint):void
		{
			if (value === this._interval)
				return;
			
			const oldValue:uint = this._interval;
			
			this._interval = value;
			
			this.dispatchEvent(PropertyChangeEvent.
				createUpdateEvent(this, "interval", oldValue, value));
		}
		
		//----------------------------------------------------------------------
		//
		//	Overridden methods
		//
		//----------------------------------------------------------------------
		
		//-----------------------------------
		//	Overridden methods: SolidColorStroke
		//-----------------------------------
		
		override public function apply(graphics:Graphics, targetBounds:Rectangle, targetOrigin:Point):void
		{
			this.graphics = graphics;
			this.origin = targetOrigin;
			this.bounds = targetBounds;
			
			this.draw();
		}
		
		override public function createGraphicsStroke(targetBounds:Rectangle, targetOrigin:Point):GraphicsStroke
		{
			var graphicsStroke:GraphicsStroke = new GraphicsStroke(); 
			graphicsStroke.thickness = weight;  
			graphicsStroke.miterLimit = miterLimit; 
			graphicsStroke.pixelHinting = pixelHinting;
			graphicsStroke.scaleMode = scaleMode;
			
			// There is a bug in Drawing API-2 where if no caps is 
			// specified, a value of 'none' is used instead of 'round'
			graphicsStroke.caps = (!caps) ? CapsStyle.ROUND : caps;
			
			const bmd:BitmapData = bmds[this.displacement];
			
			// Give the GraphicsStroke a GraphicsSolidFill corresponding to the 
			// SolidColorStroke's color and alpha values
			var graphicsSolidFill:GraphicsBitmapFill = new GraphicsBitmapFill();
			graphicsSolidFill.bitmapData = bmd;
			graphicsSolidFill.repeat = true;
			graphicsStroke.fill = graphicsSolidFill;
			
			this.displacement++;
			
			if (this.displacement == bmds.length)
				this.displacement = 0;
				
			return graphicsStroke;
		}
		
		//----------------------------------------------------------------------
		//
		//	Methods
		//
		//----------------------------------------------------------------------
		
		private function initTimer():void
		{
			if (this.interval == 0)
			{
				if (this.timer)
				{
					this.timer.stop();
					this.timer.removeEventListener(TimerEvent.TIMER, timerHandler);
				}
			}
			else
			{
				if (!this.timer)
				{
					const timer:Timer = new Timer(this.interval);
					timer.addEventListener(TimerEvent.TIMER, timerHandler, false, 0, true);
					timer.start();
				}
				else
				{
					this.timer.delay = this.interval;
				}
			}
		}
		
		private function draw():void
		{
			graphics.drawGraphicsData(Vector.<IGraphicsData>([this.createGraphicsStroke(this.bounds, this.origin)]));
		}
		
		//----------------------------------------------------------------------
		//
		//	Handlers
		//
		//----------------------------------------------------------------------
		
		protected function timerHandler(event:TimerEvent):void
		{
			this.dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE));
		}
	}
}