package {
	import cepa.graph.GraphPoint;
	import flash.display.MovieClip;
	
	public class SimplePoint extends GraphPoint {
		
		private var _graph:MovieClip;
		private var _related:MovieClip;
		
		public function SimplePoint (x:Number, y:Number, visual:MovieClip) : void {
			super(x, y);
			graph = visual;
			addChild(visual);
		}
		
		public function get related():MovieClip 
		{
			return _related;
		}
		
		public function set related(value:MovieClip):void 
		{
			_related = value;
		}
		
		public function get graph():MovieClip 
		{
			return _graph;
		}
		
		public function set graph(value:MovieClip):void 
		{
			_graph = value;
		}
		
	}
}