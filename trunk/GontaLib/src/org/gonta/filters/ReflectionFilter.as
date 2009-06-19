////////////////////////////////////////////////////////////////////////////////
// Gonta Flex Library
// MIT License
// max.rozdobudko@gmail.com
////////////////////////////////////////////////////////////////////////////////

package org.gonta.filters
{
	import flash.display.Shader;
	
	import spark.filters.ShaderFilter;
	
	/**
	 * Creates an reflection of target object.
	 */
	public dynamic class ReflectionFilter extends ShaderFilter
	{
		//----------------------------------------------------------------------
		//
		//	Class constants
		//
		//----------------------------------------------------------------------
		
		[Embed(source="shaders/Reflection.pbj", mimeType="application/octet-stream")]
		/**
		 * The default shader for reflection effect.
		 */
		public static const SHADER:Class;
		
		//----------------------------------------------------------------------
		//
		//	Constructor
		//
		//----------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function ReflectionFilter(shader:Shader=null)
		{
			shader = shader || new Shader(new SHADER());
			
			super(shader);
			
			this.bottomExtension = 40;
		}
		
		//----------------------------------------------------------------------
		//
		//	Properties
		//
		//----------------------------------------------------------------------
		
		//-----------------------------------
		//	filter
		//-----------------------------------
		
		/**
		 * @private
		 * Storage for the filter property.
		 */
		private var _filter:ShaderFilter;

		/**
		 * The internal Shader filter.
		 */
		protected function get filter():ShaderFilter
		{
			if (!this._filter)
				this._filter = new ShaderFilter(this.shader);
			
			return this._filter;
		}
		
		//-----------------------------------
		//	height
		//-----------------------------------
		
		/**
		 * The start pixel by <i>y</i> from that drawing reflection.
		 * Usualy this is height of source image.
		 * 
		 * @default 40;
		 */
		public function get y():Number
		{
			return this.imageHeight;
		}

		/**
		 * @private
		 */
		public function set y(value:Number):void
		{
			this.imageHeight = value;
		}
		
		//-----------------------------------
		//	height
		//-----------------------------------
		
		/**
		 * The height of reflection in pixels. Valid values from 0.0 to 4096.0 
		 * by default is 40.
		 * 
		 * @default 40;
		 */
		public function get height():Number
		{
			return this.reflectionHeight;
		}

		/**
		 * @private
		 */
		public function set height(value:Number):void
		{
			this.bottomExtension = value;
			
			this.reflectionHeight = value;
		}
		
		//-----------------------------------
		//	alpha
		//-----------------------------------
		
		/**
		 * The alpha of a reflection. Valid values from 0.0 to 1.0.
		 * 
		 * @default 0.5
		 */
		public function get alpha():Number
		{
			return this.reflectionAlpha;
		}

		/**
		 * @private
		 */
		public function set alpha(value:Number):void
		{
			this.reflectionAlpha = value;
		}
	}
}