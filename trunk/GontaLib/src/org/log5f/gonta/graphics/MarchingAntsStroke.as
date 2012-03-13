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
	
	/**
	 * The MarchingAntsStroke class implements <i>Marching Ants</i> effect, that 
	 * can be used for selectino tools. This class can be used as usual stroke:
	 * 
	 * <pre>
	 * ...
	 * &lt;s:Rect width="100" height="100"&gt;
	 *     &lt;s:stroke&gt;
	 *         &lt;graphics:MarchingAntsStroke /&gt;
	 *     &lt;/s:stroke&gt;
	 * &lt;/s:Rect&gt;
	 * ...
	 * </pre>
	 * 
	 * @mxml
	 *
	 * <p>The <code>&lt;mx:MarchingAntsStroke&gt;</code> tag inherits all the 
	 * tag attributes of its superclass, and adds the following tag attributes:</p>
	 * 
	 * <pre>
	 *  &lt;graphics:MarchingAntsStroke
	 *    <b>Properties</b>
	 *    interval="100"
	 *  /&gt;
	 *  </pre>
	 * 
	 * @see http://en.wikipedia.org/wiki/Marching_ants Marching ants
	 */
	public class MarchingAntsStroke extends SolidColorStroke
	{
		//----------------------------------------------------------------------
		//
		//  Implementation notes
		//
		//----------------------------------------------------------------------
		
		/*
		
		The current implementaion of "Marching ants" effect based on drawing 
		patterns that contains diagonal lines.
		
		MarchingAntsStroke shares patterns, that generated using common settings,
		for all of instances, for performance reason.
		
		*/
		
		//----------------------------------------------------------------------
		//
		//	Class cosntants
		//
		//----------------------------------------------------------------------
		
		//-----------------------------------
		//	Class costants: Default values
		//-----------------------------------
		
		/** Default number of segments */
		private static const SEGEMENT:uint = 4;
		
		/** Default colors */
		private static const COLORS:Vector.<uint> = 
			Vector.<uint>([0xFFFFFF, 0x000000]);
		
		//----------------------------------------------------------------------
		//
		//	Class variables
		//
		//----------------------------------------------------------------------
		
		/** 
		 * List of patterns (BitmapData) that used for simulating of "marching 
		 * ants" effect.
		 */
		private static var patterns:Vector.<BitmapData>;
		
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
		
		/** 
		 * Creates patterns (BitmapData instances) and put it to 
		 * <code>patterns</code> list.
		 */
		private static function initialize():void
		{
			const PATTERNS:uint = SEGEMENT * SEGEMENT;
			const SIZE:uint = SEGEMENT * SEGEMENT;
			
			patterns = new Vector.<BitmapData>(PATTERNS);
			
			for (var p:int = 0; p < PATTERNS; p++)
			{
				var bmd:BitmapData = new BitmapData(SIZE, SIZE, false, COLORS[0]);
				
				var j:int = 0;
				
				var k:int = 0;
				var l:int = 0;
				
				for (j = 0; j < SIZE; j++)
				{
					l = j % (SEGEMENT * 2);
					
					var n:uint = SIZE + SEGEMENT + p;
					for (var i:int = 0; i < n; i++)
					{
						if (i % SEGEMENT == 0)
							k = i / SEGEMENT;
						
						if (k % 2 == 0)
						{
							bmd.setPixel(i + (SEGEMENT - l) - p, j, COLORS[1]);
						}
					}
				}
				
				patterns[p] = bmd;
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
		
		//-----------------------------------
		//	Variables: 
		//-----------------------------------
		
		/** Stores index of current pattern. */
		private var displacement:uint = 0;
		
		//-----------------------------------
		//	Variables: Utils
		//-----------------------------------
		
		/** Timer for redrawing stroke. */
		private var timer:Timer;
		
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
		/** 
		 * The delay in milliseconds between stroke redrawing.
		 * 
		 * @default 60
		 */
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
			
			this.initTimer();
			
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
		
		/** @inheritDoc */
		override public function apply(graphics:Graphics, bounds:Rectangle, origin:Point):void
		{
			graphics.drawGraphicsData(Vector.<IGraphicsData>([this.createGraphicsStroke(bounds, origin)]));
		}
		
		/** @inheritDoc */
		override public function createGraphicsStroke(targetBounds:Rectangle, targetOrigin:Point):GraphicsStroke
		{
			if (this.displacement == 0)
				this.displacement = patterns.length;
			
			this.displacement--;
			
			var graphicsStroke:GraphicsStroke = new GraphicsStroke(); 
			graphicsStroke.thickness = weight;  
			graphicsStroke.miterLimit = miterLimit; 
			graphicsStroke.pixelHinting = pixelHinting;
			graphicsStroke.scaleMode = scaleMode;
			
			// There is a bug in Drawing API-2 where if no caps is 
			// specified, a value of 'none' is used instead of 'round'
			graphicsStroke.caps = (!caps) ? CapsStyle.ROUND : caps;
			
			const bmd:BitmapData = patterns[this.displacement];
			
			// Give the GraphicsStroke a GraphicsSolidFill corresponding to the 
			// SolidColorStroke's color and alpha values
			var graphicsSolidFill:GraphicsBitmapFill = new GraphicsBitmapFill();
			graphicsSolidFill.bitmapData = bmd;
			graphicsSolidFill.repeat = true;
			graphicsStroke.fill = graphicsSolidFill;
			
			return graphicsStroke;
		}
		
		//----------------------------------------------------------------------
		//
		//	Methods
		//
		//----------------------------------------------------------------------
		
		/** @private */
		private function initTimer():void
		{
			if (this.interval == 0)
			{
				if (this.timer)
				{
					this.timer.stop();
					this.timer.removeEventListener(TimerEvent.TIMER, timerHandler);
					this.timer = null;
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
		
		/** Notifies target that stroke need to be redrawn. */
		private function notify():void
		{
			this.dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE));
		}
		
		//----------------------------------------------------------------------
		//
		//	Handlers
		//
		//----------------------------------------------------------------------
		
		/** @private */
		protected function timerHandler(event:TimerEvent):void
		{
			this.notify();
		}
	}
}