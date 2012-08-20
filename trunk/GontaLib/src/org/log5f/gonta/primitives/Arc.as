package org.log5f.gonta.primitives
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import mx.events.PropertyChangeEvent;
	
	import spark.primitives.Path;
	
	/** 
	 * 
	 * 
	 * @see http://hansmuller-flex.blogspot.com/2011/10/more-about-approximating-circular-arcs.html
	 */
	public class Arc extends Path
	{
		//----------------------------------------------------------------------
		//
		//	Class constants
		//
		//----------------------------------------------------------------------
		
		private static const UNDEFIEND:int = -1;
		
		//----------------------------------------------------------------------
		//
		//	Constructor
		//
		//----------------------------------------------------------------------
		
		/** Constructor */
		public function Arc()
		{
			super();
		}

		//----------------------------------------------------------------------
		//
		//	Varaibles
		//
		//----------------------------------------------------------------------
		
		/** @private */
		private var arcChanged:Boolean = false;
		
		//----------------------------------------------------------------------
		//
		//	Properties
		//
		//----------------------------------------------------------------------
		
		//-----------------------------------
		//	centerX
		//-----------------------------------
		
		/** @private */
		private var _centerX:Number;
		
		[Bindable(event="propertyChange")]
		/** The X coordinate of center of circle that using for drawing angle */
		public function get centerX():Number 
		{
			return this._centerX;
		}
		
		/** @private */
		public function set centerX(value:Number):void
		{
			if (value === this._centerX)
				return;
			
			var oldValue:Object = this._centerX;
			
			this._centerX = value;
			
			this.arcChanged = true;
			this.invalidateProperties();
			
			this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(
				this, "centerX", oldValue, value));
		}
		
		//-----------------------------------
		//	centerY
		//-----------------------------------
		
		/** @private */
		private var _centerY:Number;
		
		[Bindable(event="propertyChange")]
		/** The Y coordinate of center of circle that using for drawing angle */
		public function get centerY():Number 
		{
			return this._centerY;
		}
		
		/** @private */
		public function set centerY(value:Number):void
		{
			if (value === this._centerY)
				return;
			
			var oldValue:Object = this._centerY;
			
			this._centerY = value;
			
			this.arcChanged = true;
			this.invalidateProperties();
			
			this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(
				this, "centerY", oldValue, value));
		}
		
		//-----------------------------------
		//	startAngle
		//-----------------------------------
		
		/** @private */
		private var _startAngle:int;
		
		[Bindable(event="propertyChange")]
		/** Start angle for arc. */
		public function get startAngle():int
		{
			return this._startAngle;
		}
		
		/** @private */
		public function set startAngle(value:int):void
		{
			if (value === this._startAngle)
				return;
			
			const oldValue:int = this._startAngle;
			
			this._startAngle = value;
			
			this.arcChanged = true;
			this.invalidateProperties();
			
			this.dispatchEvent(PropertyChangeEvent.
				createUpdateEvent(this, "startAngle", oldValue, value));
		}
		
		//-----------------------------------
		//	endAngle
		//-----------------------------------
		
		/** @private */
		private var _endAngle:int;
		
		[Bindable(event="propertyChange")]
		/** End angle for arc. */
		public function get endAngle():int
		{
			return this._endAngle;
		}
		
		/** @private */
		public function set endAngle(value:int):void
		{
			if (value === this._endAngle)
				return;
			
			const oldValue:int = this._endAngle;
			
			this._endAngle = value;
			
			this.arcChanged = true;
			this.invalidateProperties();
			
			this.dispatchEvent(PropertyChangeEvent.
				createUpdateEvent(this, "endAngle", oldValue, value));
		}
		
		//-----------------------------------
		//	radius
		//-----------------------------------
		
		/** @private */
		private var _radius:int = UNDEFIEND;
		
		[Bindable(event="propertyChange")]
		/** Distance from circle center where arc is drawing. */
		public function get radius():int
		{
			return this._radius;
		}
		
		/** @private */
		public function set radius(value:int):void
		{
			if (value === this._radius)
				return;
			
			const oldValue:int = this._radius;
			
			this._radius = value;
			
			this.arcChanged = true;
			this.invalidateProperties();
			
			this.dispatchEvent(PropertyChangeEvent.
				createUpdateEvent(this, "radius", oldValue, value));
		}
		
		//-----------------------------------
		//	weight
		//-----------------------------------
		
		/** @private */
		private var _weight:int = UNDEFIEND;
		
		[Bindable(event="propertyChange")]
		/** Weigth of arch */
		public function get weight():int
		{
			return this._weight;
		}
		
		/** @private */
		public function set weight(value:int):void
		{
			if (value === this._weight)
				return;
			
			const oldValue:int = this._weight;
			
			this._weight = value;
			
			this.arcChanged = true;
			this.invalidateProperties();
			
			this.dispatchEvent(PropertyChangeEvent.
				createUpdateEvent(this, "weight", oldValue, value));
		}
		
		//----------------------------------------------------------------------
		//
		//	Overridden methods
		//
		//----------------------------------------------------------------------
		
		/**  */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (this.arcChanged)
			{
				this.arcChanged = false;
				
				const r:int = this.radius == UNDEFIEND ? 
							  uint(Math.sqrt(this.width * this.height)) :
							  this.radius;
				
				if (r <= 0) return;
				
				if (this.weight == UNDEFIEND)
				{
					this.data = PathArcUtils.
						createArcPathData(centerX || 0, centerY || 0, r, startAngle, endAngle);
//					
//					// The base GraphicElement class has cleared the graphics for us.    
//					var g:Graphics = (drawnDisplayObject as Sprite).graphics;
//					
//					beginDraw(g);
//					draw(g);
//					endDraw(g);
				}
				else
				{
					this.data = PathArcUtils.
						createRectangularSegmentPathData(centerX || 0, centerY || 0, r, 
							r - weight, startAngle, endAngle);
				}
			}
		}
	}
}