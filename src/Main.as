package 
{
	import BaseAssets.BaseMain;
	import BaseAssets.events.BaseEvent;
	import BaseAssets.tutorial.CaixaTexto;
	import cepa.graph.DataStyle;
	import cepa.graph.GraphFunction;
	import cepa.graph.GraphPoint;
	import cepa.graph.rectangular.SimpleGraph;
	import fl.controls.ComboBox;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain
	{
		private var graph:SimpleGraph;
		private var xmin:Number;
		private var xmax:Number;
		
		private var func:GraphFunction;
		private var style:DataStyle = new DataStyle();
		
		private var concavidade:ComboBox;
		private var vertice:ComboBox;
		
		private var finaliza:SimpleButton;
		private var reinicia:SimpleButton;
		private var certoErrado:MovieClip;
		
		private var pVertice:MovieClip;
		private var pRaiz1:MovieClip;
		private var pRaiz2:MovieClip;
		
		private var inicialVertice:Point;
		private var inicialRaiz1:Point;
		private var inicialRaiz2:Point;
		
		private var ordem:Array = [1, 1, 2, 3, 2, 3, 1, 3, 2, 1, 3, 2, 2, 3, 3, 2];
		private var index:int = 0;
		
		public function Main() 
		{
			
		}
		
		override protected function init():void 
		{
			finaliza = finaliza_stage;
			reinicia = reinicia_stage;
			certoErrado = certoErrado_stage;
			
			pVertice = pVertice_stage;
			pRaiz1 = pRaiz1_stage;
			pRaiz2 = pRaiz2_stage;
			
			inicialVertice = new Point(pVertice.x, pVertice.y);
			inicialRaiz1 = new Point(pRaiz1.x, pRaiz1.y);
			inicialRaiz2 = new Point(pRaiz2.x, pRaiz2.y);
			
			concavidade = new ComboBox();
			concavidade.x = 165;
			concavidade.y = 515;
			concavidade.addItem( {label:"Para cima", data:1 } );
			concavidade.addItem( {label:"Para baixo", data:2 } );
			
			vertice = new ComboBox();
			vertice.x = 165;
			vertice.y = 550;
			vertice.addItem( {label:"Máximo", data:1 } );
			vertice.addItem( {label:"Mínimo", data:2 } );
			
			layerAtividade.addChild(concavidade);
			layerAtividade.addChild(vertice);
			
			createGraph();
			addListeners();
			reset();
			
			iniciaTutorial();
		}
		
		private function createGraph():void 
		{
			xmin = -17;
			xmax = 17;
			var xsize:Number = 	640;
			var ysize:Number = 	420;
			var yRange:Number = Math.abs((xmin - xmax) * ysize / xsize);
			var ymin:Number = 	-yRange / 2;
			var ymax:Number = 	yRange / 2;
			
			var tickSize:Number = 2;
			
			graph = new SimpleGraph(xmin, xmax, xsize, ymin, ymax, ysize);
			graph.x = ((stage.stageWidth - xsize) / 2) + 5;
			graph.y = 48;
			
			graph.enableTicks(SimpleGraph.AXIS_X, true);
			graph.enableTicks(SimpleGraph.AXIS_Y, true);
			graph.setTicksDistance(SimpleGraph.AXIS_X, tickSize);
			graph.setTicksDistance(SimpleGraph.AXIS_Y, tickSize);
			graph.setSubticksDistance(SimpleGraph.AXIS_X, tickSize / 2);
			graph.setSubticksDistance(SimpleGraph.AXIS_Y, tickSize / 2);
			graph.resolution = 0.1;
			graph.grid = true;
			graph.pan = false;
			//graph.buttonMode = true;
			graph.addEventListener("initPan", startPan);
			graph.setAxesNameFormat(new TextFormat("arial", 12, 0x000000));
			graph.setAxisName(SimpleGraph.AXIS_X, "x");
			graph.setAxisName(SimpleGraph.AXIS_Y, "Y");
			
			layerAtividade.addChild(graph);
			graph.draw();
			
			//var graphBorder:Sprite = new Sprite();
			//graphBorder.graphics.lineStyle(1, 0x000000);
			//graphBorder.graphics.drawRect(0, 0, xsize, ysize);
			//graphBorder.x = graph.x;
			//graphBorder.y = graph.y;
			//addChild(graphBorder);
			
			style.color = 0xFF0000;
			style.alpha = 1;
			style.stroke = 2;
		}
		
		private function changePan(e:MouseEvent):void
		{
			graph.pan = !graph.pan;
			graph.buttonMode = graph.pan;
			
			if (graph.pan) {
				panButton.gotoAndStop(2);
			}else {
				panButton.gotoAndStop(1);
			}
		}
		
		private function startPan(e:Event):void 
		{
			graph.addEventListener("stopPan", stopPan);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, panning);
		}
		
		private function panning(e:MouseEvent):void 
		{
			xmin = graph.xmin;
			xmax = graph.xmax;
			func.xmin = xmin;
			func.xmax = xmax;
			for each (var item:SimplePoint in pontosGrafico) 
			{
				if (item.xpos < xmin || item.xpos > xmax || item.ypos < graph.ymin || item.ypos > graph.ymax) {
					item.visible = false;
				}else {
					item.visible = true;
				}
			}
		}
		
		private function stopPan(e:Event):void 
		{
			graph.removeEventListener("stopPan", stopPan);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, panning);
			panning(null);
		}
		
		private function addListeners():void 
		{
			finaliza.addEventListener(MouseEvent.CLICK, finalizar);
			reinicia.addEventListener(MouseEvent.CLICK, reset);
			
			pVertice.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			pRaiz1.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			pRaiz2.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			
			pVertice.buttonMode = true;
			pRaiz1.buttonMode = true;
			pRaiz2.buttonMode = true;
			
			panButton.addEventListener(MouseEvent.CLICK, changePan);
			panButton.buttonMode = true;
		}
		
		private var draggingPoint:SimplePoint;
		private function initDragPonto(e:MouseEvent):void 
		{
			if (graph.pan) return;
			draggingPoint = SimplePoint(e.target);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDraggPonto);
			draggingPoint.startDrag();
		}
		
		private function stopDraggPonto(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDraggPonto);
			draggingPoint.stopDrag();
			
			if (fundoGrafico.hitTestPoint(draggingPoint.x + graph.x, draggingPoint.y + graph.y)) {
				var posGraph:Point = new Point(draggingPoint.x, draggingPoint.y);
				var posX:Number = graph.pixel2x(posGraph.x);
				var posY:Number = graph.pixel2y(posGraph.y);
				var pt:Ponto = new Ponto();
				draggingPoint.xpos = posX;
				draggingPoint.ypos = posY;
				graph.draw();
			}else {
				graph.removePoint(draggingPoint);
				pontosGrafico.splice(pontosGrafico.indexOf(draggingPoint), 1);
				//graph.removeChild(draggingPoint);
				draggingPoint.related.visible = true;
				draggingPoint = null;
			}
			
		}
		
		private var dragging:MovieClip;
		private function initDrag(e:MouseEvent):void 
		{
			dragging = MovieClip(e.target);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragg);
			dragging.startDrag();
		}
		
		private var pontosGrafico:Vector.<SimplePoint> = new Vector.<SimplePoint>();
		
		private function stopDragg(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragg);
			dragging.stopDrag();
			if (fundoGrafico.hitTestPoint(dragging.x, dragging.y)) {
				var posGraph:Point = graph.globalToLocal(new Point(dragging.x, dragging.y));
				var posX:Number = graph.pixel2x(posGraph.x);
				var posY:Number = graph.pixel2y(posGraph.y);
				var pt:Ponto = new Ponto();
				var g:SimplePoint = new SimplePoint(posX, posY, pt);
				g.mouseChildren = false;
				g.addEventListener(MouseEvent.MOUSE_DOWN, initDragPonto);
				pontosGrafico.push(g);
				g.related = dragging;
				graph.addPoint(g);
				graph.draw();
				encerraDragging(false);
			}else {
				encerraDragging(true);
			}
			
		}
		
		private function encerraDragging(visivel:Boolean):void 
		{
			dragging.visible = visivel;
			if (dragging == pVertice) {
				dragging.x = inicialVertice.x;
				dragging.y = inicialVertice.y;
			}else if (dragging == pRaiz1) {
				dragging.x = inicialRaiz1.x;
				dragging.y = inicialRaiz1.y;
			}else {
				dragging.x = inicialRaiz2.x;
				dragging.y = inicialRaiz2.y;
			}
			dragging = null;
		}
		
		private function sortExec():void 
		{
			if (func != null) graph.removeFunction(func);
			
			func = getFunction(ordem[index]);
			index++;
			if (index >= ordem.length) index = 0;
			
			graph.addFunction(func, style);
			graph.draw();
			
			certoErrado.visible = false;
				
			lock(reinicia);
			//unlock(finalizaVermelha);
		}
		
		private function getFunction(caso:int):GraphFunction 
		{
			var x0:Number;
			var x1:Number;
			var xv:Number;
			var yv:Number;
			var a:Number;
			var b:Number;
			var c:Number;
			var n:Number;
			var E:Number;
			
			var rangeInteiros:int = 10;
			
			switch (caso) {
				case 1:
					E = Math.ceil(Math.random() * rangeInteiros);
					yv = (Math.random() > 0.5 ? 1 : -1) * E;
					n = Math.ceil(Math.random() * E);
					x0 = (Math.random() > 0.5 ? 1 : -1) * Math.floor(Math.random() * rangeInteiros);
					x1 = x0 + 2 * n;
					xv = (x0 + x1) / 2;
					a = ( -4 * yv) / Math.pow((x1 - x0), 2);
					break;
				case 2:
					yv = 0;
					xv = (Math.random() > 0.5 ? 1 : -1) * Math.floor(Math.random() * rangeInteiros);
					a = (Math.random() > 0.5 ? 1 : -1) * Math.ceil(Math.random() * rangeInteiros);
					break;
				case 3:
					xv = (Math.random() > 0.5 ? 1 : -1) * Math.floor(Math.random() * rangeInteiros);
					yv = (Math.random() > 0.5 ? 1 : -1) * Math.floor(Math.random() * rangeInteiros);
					if (yv >= 0) a = Math.ceil(Math.random() * rangeInteiros);
					else a = -Math.ceil(Math.random() * rangeInteiros);
					break;
			}
			
			b = -2 * a * xv;
			c = yv + (a * xv * xv);
			
			var f:Function = function(x:Number):Number {
				return a * Math.pow(x, 2) + b * x + c;
			}
			
			var func:GraphFunction = new GraphFunction(xmin, xmax, f);
			
			return func;
		}
		
		
		private function finalizar(e:MouseEvent = null):void
		{
			if(true){
				var correto:Boolean = true;
				var tolerancia = 1 / 100;
				var feed:String;
				
				if (correto) {
					//Certo
					feed = "Correto!";
					certoErrado.gotoAndStop(2);
				}else {
					//Errado
					certoErrado.gotoAndStop(1);
					feed = "Errado";
				}
				
				//feedbackScreen.setText(feed);
				
				certoErrado.visible = true;
				unlock(reinicia);
				//lock(finalizaVermelha);
			}else {
				feedbackScreen.setText("Informe ambos os coeficientes linear e angular para avaliar.");
			}
		}
		
		override public function reset(e:MouseEvent = null):void 
		{
			sortExec();
		}
		
		
		//---------------- Tutorial -----------------------
		
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		private var tutoSequence:Array;
		
		override public function iniciaTutorial(e:MouseEvent = null):void  
		{
			blockAI();
			
			tutoPos = 0;
			if(balao == null){
				balao = new CaixaTexto();
				layerTuto.addChild(balao);
				balao.visible = false;
				
				tutoSequence = ["Veja aqui as orientações.",
								"Os gráficos de duas funções do primeiro grau, escolhidas aleatoriamente pelo software, são exibidos aqui (uma em vermelho e outra em verde).",
								"Caso não esteja vendo algum desses gráficos, arraste o plano cartesiano para cima ou para baixo.",
								"Analise os gráficos acima e, com base neles, indique nos campos apropriados abaixo os valores dos coeficientes linear e angular.",
								"Pressione \"avaliar\" para verificar sua resposta.",
								"Pressione \"nova reta\" para que o software exiba um novo gráfico.",
								"Faça o mesmo para a reta verde.",
								"Pressione este botão para reiniciar este tutorial."];
				
				pointsTuto = 	[new Point(650, 535),
								new Point(180 , 180),
								new Point(250 , 250),
								new Point(165 , 475),
								new Point(170 , 564),
								new Point(262 , 564),
								new Point(490 , 475),
								new Point(650 , 490)];
								
				tutoBaloonPos = [[CaixaTexto.RIGHT, CaixaTexto.LAST],
								["", ""],
								["", ""],
								[CaixaTexto.BOTTON, CaixaTexto.FIRST],
								[CaixaTexto.BOTTON, CaixaTexto.FIRST],
								[CaixaTexto.BOTTON, CaixaTexto.CENTER],
								[CaixaTexto.BOTTON, CaixaTexto.LAST],
								[CaixaTexto.RIGHT, CaixaTexto.CENTER]];
			}
			balao.removeEventListener(BaseEvent.NEXT_BALAO, closeBalao);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(BaseEvent.NEXT_BALAO, closeBalao);
			balao.addEventListener(BaseEvent.CLOSE_BALAO, iniciaAi);
		}
		
		private function closeBalao(e:Event):void 
		{
			tutoPos++;
			if (tutoPos >= tutoSequence.length) {
				balao.removeEventListener(BaseEvent.NEXT_BALAO, closeBalao);
				balao.visible = false;
				iniciaAi(null);
			}else {
				balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
				balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			}
		}
		
		private function iniciaAi(e:BaseEvent):void 
		{
			balao.removeEventListener(BaseEvent.CLOSE_BALAO, iniciaAi);
			balao.removeEventListener(BaseEvent.NEXT_BALAO, closeBalao);
			unblockAI();
		}
		
	}

}