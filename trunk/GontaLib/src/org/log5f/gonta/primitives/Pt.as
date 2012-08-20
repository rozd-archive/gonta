package org.log5f.gonta.primitives
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.events.PropertyChangeEvent;
	
	import spark.core.DisplayObjectSharingMode;
	import spark.primitives.Ellipse;
	
	[Exclude(kind="property", name="left")]
	[Exclude(kind="property", name="top")]
	[Exclude(kind="property", name="right")]
	[Exclude(kind="property", name="bottom")]
	[Exclude(kind="property", name="width")]
	[Exclude(kind="property", name="height")]

	/**
	 * 
	 */
	public class Pt extends Ellipse
	{
		//----------------------------------------------------------------------
		//
		//	Constructor
		//
		//----------------------------------------------------------------------
		
		/** Constructor */
		public function Pt()
		{
			super();
		}
		
		//----------------------------------------------------------------------
		//
		//	Variables
		//
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		//
		//	Overridden properties
		//
		//----------------------------------------------------------------------
		
		//-----------------------------------
		//	drawX
		//-----------------------------------
		
		/** @inheritDoc */
		override protected function get drawX():Number
		{
			// If we don't share the display object, we will draw at 0,0
			// since the display object will be positioned at x,y
			if (this.displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
				return 0;
			
			var offset:Number = - this.size / 2;
			
			// Otherwise we draw at x,y since the display object will be
			// positioned at 0,0
			if (layoutFeatures != null && layoutFeatures.postLayoutTransformOffsets != null)
				x = this.x + layoutFeatures.postLayoutTransformOffsets.x + offset;
			
			return x + offset;
		}
		
		//----------------------------------
		//  drawY
		//----------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function get drawY():Number
		{
			// If we don't share the display object, we will draw at 0,0
			// since the display object will be positioned at x,y
			if (displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
				return 0;
			
			var offset:Number = - this.size / 2;
			
			// Otherwise we draw at x,y since the display object will be
			// positioned at 0,0
			if (layoutFeatures != null && layoutFeatures.postLayoutTransformOffsets != null)
				return y + layoutFeatures.postLayoutTransformOffsets.y + offset;
			
			return y + offset;
		}
		
		//----------------------------------
		//  x
		//----------------------------------
		
		/** @inheritDoc */
		override public function set x(value:Number):void
		{
			super.x = value;
			
			this.dispatchEvent(new Event("positionChange"));
		}
		
		//----------------------------------
		//  y
		//----------------------------------
		
		/** @inheritDoc */
		override public function set y(value:Number):void
		{
			super.y = value;
			
			this.dispatchEvent(new Event("positionChange"));
		}
		
		//----------------------------------------------------------------------
		//
		//	Properties
		//
		//----------------------------------------------------------------------
		
		//-----------------------------------
		//	center
		//-----------------------------------
		
		[Bindable("positionChange")]
		/**  */
		public function get center():Point
		{
			return new Point(this.x, this.y);
		}
		
		//-----------------------------------
		//	size
		//-----------------------------------
		
		/** @private */
		private var _size:Number ;
		
		[Bindable(event="propertyChange")]
		/**  */
		public function get size():Number 
		{
			return this._size;x
		}
		
		/** @private */
		public function set size(value:Number):void
		{
			if (value === this._size)
				return;
			
			var oldValue:Object = this._size;
			
			this._size = this.width = this.height = value;
			
			this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(
				this, "size", oldValue, value));
		}
		
		//----------------------------------------------------------------------
		//
		//	Overridden methods
		//
		//----------------------------------------------------------------------
		
		/** @inheritDoc */
		override protected function commitProperties():void
		{
			super.commitProperties();
		}
	}
}