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
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
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
		
		private var equacao:TextField;
		
		private var ordem:Array = [1, 1, 2, 3, 2, 3, 1, 3, 2, 1, 3, 2, 2, 3, 3, 2];
		private var index:int = 0;
		
		public function Main() 
		{
			
		}
		
		override protected function init():void 
		{
			var rollText:RollText = new RollText();
			orientacoesScreen.addChild(rollText);
			rollText.x = -260;
			rollText.y = -150;
			var scrollBar:Scrollbar = new Scrollbar(rollText);
			orientacoesScreen.addChild(scrollBar);
			
			finaliza = finaliza_stage;
			reinicia = reinicia_stage;
			certoErrado = certoErrado_stage;
			equacao = equacao_stage;
			
			pVertice = pVertice_stage;
			pRaiz1 = pRaiz1_stage;
			pRaiz2 = pRaiz2_stage;
			
			pVertice.mouseChildren = false;
			pRaiz1.mouseChildren = false;
			pRaiz2.mouseChildren = false;
			
			inicialVertice = new Point(pVertice.x, pVertice.y);
			inicialRaiz1 = new Point(pRaiz1.x, pRaiz1.y);
			inicialRaiz2 = new Point(pRaiz2.x, pRaiz2.y);
			
			concavidade = new ComboBox();
			concavidade.x = 175;
			concavidade.y = 495;
			concavidade.addItem( {label:"Selecione...", data:-1 } );
			concavidade.addItem( {label:"Para cima", data:"cima" } );
			concavidade.addItem( {label:"Para baixo", data:"baixo" } );
			
			vertice = new ComboBox();
			vertice.x = 175;
			vertice.y = 543;
			vertice.addItem( {label:"Selecione...", data:-1 } );
			vertice.addItem( {label:"Máximo", data:"maximo" } );
			vertice.addItem( {label:"Mínimo", data:"minimo" } );
			
			layerAtividade.addChild(concavidade);
			layerAtividade.addChild(vertice);
			
			createGraph();
			addListeners();
			reset();
			
			iniciaTutorial();
		}
		
		private var diffY:Number;
		private function createGraph():void 
		{
			xmin = -17;
			xmax = 17;
			var xsize:Number = 	640;
			var ysize:Number = 	395;
			var yRange:Number = Math.abs((xmin - xmax) * ysize / xsize);
			var ymin:Number = 	-yRange / 2;
			var ymax:Number = 	yRange / 2;
			diffY = Math.abs(ymin) + Math.abs(ymax);
			
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
			//graph.pan = false;
			//graph.buttonMode = true;
			//graph.addEventListener("initPan", startPan);
			graph.setAxesNameFormat(new TextFormat("arial", 12, 0x000000));
			graph.setAxisName(SimpleGraph.AXIS_X, "t");
			graph.setAxisName(SimpleGraph.AXIS_Y, "s");
			
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
		
		private var mousePos:Point;
		private var posXGraphInicial:Point = new Point();
		private var posYGraphInicial:Point = new Point();
		
		private function startPan(e:Event):void 
		{
			if (e.target is SimplePoint) return;
			//graph.addEventListener("stopPan", stopPan);
			mousePos = new Point(stage.mouseX, stage.mouseY);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, pan2);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopPan);
		}
		
		//private function panning(e:MouseEvent):void 
		private function pan2(e:MouseEvent):void 
		{
			var mousePosAtual:Point = new Point(stage.mouseX, stage.mouseY);
			var displacement:Point = new Point(mousePos.x - mousePosAtual.x, mousePos.y - mousePosAtual.y);
			var displacementGraph:Point = new Point(graph.pixel2x(0) - graph.pixel2x(displacement.x), graph.pixel2y(0) - graph.pixel2y(displacement.y));
			
			graph.setRange(graph.xmin - displacementGraph.x, graph.xmax - displacementGraph.x, graph.ymin - displacementGraph.y, graph.ymax - displacementGraph.y);
			
			mousePos.x = mousePosAtual.x;
			mousePos.y = mousePosAtual.y;
			
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
			
			graph.draw();
		}
		
		private function stopPan(e:Event):void 
		{
			//graph.removeEventListener("stopPan", stopPan);
			//stage.removeEventListener(MouseEvent.MOUSE_MOVE, panning);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, pan2);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopPan);
			//pan2(null);
			//panning(null);
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
			
			graph.addEventListener(MouseEvent.MOUSE_DOWN, startPan);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, verifyForLabel);
		}
		
		private var draggingPoint:SimplePoint;
		private function initDragPonto(e:MouseEvent):void 
		{
			if (finalizado) return;
			if (graph.pan) return;
			draggingPoint = SimplePoint(e.target);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDraggPonto);
			//draggingPoint.startDrag();
			stage.addEventListener(MouseEvent.MOUSE_MOVE, movingPonto);
		}
		
		private function movingPonto(e:MouseEvent):void 
		{
			var posMouseGraph:Point = new Point(graph.pixel2x(graph.mouseX), graph.pixel2y(graph.mouseY));
			
			var floorX:int = Math.floor(posMouseGraph.x);
			var ceilX:int = Math.ceil(posMouseGraph.x);
			var floorY:int = Math.floor(posMouseGraph.y);
			var ceilY:int = Math.ceil(posMouseGraph.y);
			
			var distff:Number = Point.distance(posMouseGraph, new Point(floorX, floorY));
			var distfc:Number = Point.distance(posMouseGraph, new Point(floorX, ceilY));
			var distcc:Number = Point.distance(posMouseGraph, new Point(ceilX, ceilY));
			var distcf:Number = Point.distance(posMouseGraph, new Point(ceilX, floorX));
			
			var minDist:Number = Math.min(distff, distfc, distcc, distcf);
			
			if (minDist <= 0.4) {
				switch (minDist) {
					case distff:
						draggingPoint.x = graph.x2pixel(floorX);
						draggingPoint.y = graph.y2pixel(floorY);
						break;
					case distfc:
						draggingPoint.x = graph.x2pixel(floorX);
						draggingPoint.y = graph.y2pixel(ceilY);
						break;
					case distcc:
						draggingPoint.x = graph.x2pixel(ceilX);
						draggingPoint.y = graph.y2pixel(ceilY);
						break;
					case distcf:
						draggingPoint.x = graph.x2pixel(ceilX);
						draggingPoint.y = graph.y2pixel(floorY);
						break;
					
				}
			}else{
				draggingPoint.x = graph.mouseX;
				draggingPoint.y = graph.mouseY;
			}
		}
		
		private function stopDraggPonto(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingPonto);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDraggPonto);
			//draggingPoint.stopDrag();
			
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
			if (finalizado) return;
			dragging = MovieClip(e.target);
			trace(dragging.name);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragg);
			dragging.startDrag();
		}
		
		private var pontosGrafico:Vector.<SimplePoint> = new Vector.<SimplePoint>();
		
		private function stopDragg(e:MouseEvent):void
		{
			trace(dragging.name);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragg);
			dragging.stopDrag();
			if (fundoGrafico.hitTestPoint(dragging.x, dragging.y)) {
				var posGraph:Point = graph.globalToLocal(new Point(dragging.x, dragging.y));
				var posX:Number = graph.pixel2x(posGraph.x);
				var posY:Number = graph.pixel2y(posGraph.y);
				var classe:Class = getDefinitionByName(getQualifiedClassName(dragging)) as Class;
				var pt:MovieClip = new classe();
				var g:SimplePoint = new SimplePoint(posX, posY, pt);
				g.mouseChildren = false;
				g.addEventListener(MouseEvent.MOUSE_DOWN, initDragPonto);
				g.buttonMode = true;
				pontosGrafico.push(g);
				g.related = dragging;
				graph.addPoint(g, false, true);
				graph.draw();
				encerraDragging(false);
			}else {
				encerraDragging(true);
			}
			
		}
		
		private function verifyForLabel(e:MouseEvent):void 
		{
			for each (var pt:SimplePoint in pontosGrafico) 
			{
				var dist:Number = Point.distance(new Point(pt.parent.mouseX, pt.parent.mouseY), new Point(pt.x, pt.y));
				
				if (dist < 10) {
					if (pt.graph.currentFrame == 1) pt.graph.gotoAndStop(2);
				}else {
					if (pt.graph.currentFrame == 2) pt.graph.gotoAndStop(1);
				}
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
			resposta.caso = ordem[index];
			index++;
			if (index >= ordem.length) index = 0;
			
			graph.addFunction(func, style);
			graph.draw();
			
			certoErrado.visible = false;
				
			lock(reinicia);
			//unlock(finalizaVermelha);
		}
		
		private var resposta:Object = new Object();
		
		private function getFunction(caso:int):GraphFunction 
		{
			var x0:Number = NaN;
			var x1:Number = NaN;
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
			
			//debug.text = "caso: " + caso;
			//debug.text += "\na: " + a;
			//debug.text += "\nb: " + b;
			//debug.text += "\nc: " + c;
			//debug.text += "\nxv: " + xv;
			//debug.text += "\nyv: " + yv;
			//debug.text += "\nX0: " + x0;
			//debug.text += "\nX1: " + x1;
			//debug.text += "\nn: " + n;
			//debug.text += "\nE: " + E;
			
			equacao.text = "Indique a posição do vértice e das raízes da equação: f(t) = " + a + "t²" + (b>=0?"+":"") + b + "t" + (c>=0?"+":"") + c;
			
			resposta.x0 = x0;
			resposta.x1 = x1;
			resposta.yv = yv;
			resposta.xv = xv;
			resposta.a = a;
			
			var f:Function = function(x:Number):Number {
				return a * Math.pow(x, 2) + b * x + c;
			}
			
			var func:GraphFunction = new GraphFunction(xmin, xmax, f);
			
			return func;
		}
		
		private var finalizado:Boolean = false;
		private function finalizar(e:MouseEvent = null):void
		{
			if(concavidade.selectedItem.data != -1 && vertice.selectedItem.data != -1){
				var correto:Boolean = true;
				var tolerancia = 0.5;
				var feed:String = "";
				
				//Avaliando a concavidade:
				var concavidadeSelecionada:String = concavidade.selectedItem.data;
				if (resposta.a >= 0 && concavidadeSelecionada == "cima") {
					feed += "A concavidade é \"para cima\". Quando dizemos isso, queremos dizer que a parte \"aberta\" do gráfico de s(t) está voltada para cima no plano cartesiano (veja o gráfico).\n";
				}else if (resposta.a < 0 && concavidadeSelecionada == "baixo") {
					feed += "A concavidade é \”para baixo\”. Quando dizemos isso, queremos dizer que a parte \"aberta\" do gráfico de s(t) está voltada para baixo no plano cartesiano (veja o gráfico).\n";
				}else {
					correto = false;
					feed += "A concavidade é " + (resposta.a >= 0 ? "\"para cima\"" : "\"para baixo\"") + ". Quando dizemos isso, queremos dizer que a parte \"aberta\" do gráfico de s(t) está voltada para " + (resposta.a >= 0 ? "cima" : "baixo") + " no plano cartesiano (veja o gráfico).\n";
				}
				
				//Avaliando o vértice máximo ou mínimo
				var verticeSelecionado:String = vertice.selectedItem.data;
				if (resposta.a >= 0 && verticeSelecionado == "minimo") {
					feed += "O vértice é um mínimo de s(t): observe no plano cartesiano que o vértice é o ponto mais baixo do gráfico de s(t). No caso da função polinomial do segundo grau, isto acontece sempre que a < 0.\n";
				}else if (resposta.a < 0 && verticeSelecionado == "maximo") {
					feed += "O vértice é um máximo de s(t): observe no plano cartesiano que o vértice é o ponto mais alto do gráfico de s(t). No caso da função polinomial do segundo grau, isto acontece sempre que a < 0.\n";
				}else {
					correto = false;
					feed += "O vértice é um " + (resposta.a >= 0 ? "mínimo" : "máximo") + " de s(t): observe no plano cartesiano que o vértice é o ponto mais " + (resposta.a >= 0 ? "baixo" : "alto") + " do gráfico de s(t). No caso da função polinomial do segundo grau, isto acontece sempre que a < 0.\n";
				}
				
				//Analisa o vértice no gráfico (ponto)
				var respostaVertice:Point = new Point(resposta.xv, resposta.yv);
				var verticeOnGraph:Point;
				var verticeSpliced:SimplePoint;
				for each (var ponto:SimplePoint in pontosGrafico) 
				{
					if (ponto.related == pVertice) {
						verticeOnGraph = new Point(ponto.xpos, ponto.ypos);
						verticeSpliced = pontosGrafico.splice(pontosGrafico.indexOf(ponto), 1)[0];
						break;
					}
				}
				
				if (verticeOnGraph == null) {
					feed += "A posição do vértice não foi indicada (veja o gráfico de f).\n";
					correto = false;
				}
				else {
					if (Point.distance(verticeOnGraph, respostaVertice) < tolerancia) feed += "O vértice foi posicionado corretamente.\n";
					else {
						feed += "O vértice foi posicionado incorretamente (veja o gráfico de f).\n";
						correto = false;
					}
				}
				
				//Analisa as raízes:
				var respostaRaizes:Array;
				var raiz1ok:Boolean = false;
				var raiz2ok:Boolean = false;
				switch(resposta.caso) {
					case 1:
						respostaRaizes = [new Point(resposta.x0, 0), new Point(resposta.x1, 0)];
						if (pontosGrafico.length == 0) {
							feed += "Nenhuma das duas raízes foi indicada. Veja no plano cartesiano que o gráfico de s(t) cruza o eixo t duas vezes. Esses cruzamentos indicam as duas raízes.";
						}else if (pontosGrafico.length == 1) {
							var raizPosicionada:SimplePoint = pontosGrafico[0];
							var raizPosOk:Boolean = false;
							var raizDireita:Boolean;
							lookRes2: for (var i:int = 0; i < respostaRaizes.length; i++) 
							{
								var respRaiz = respostaRaizes[i];
								if (Point.distance(respRaiz, new Point(raizPosicionada.xpos, raizPosicionada.ypos)) < tolerancia) {
									raizPosOk = true;
									if (i == 0) {
										if (respostaRaizes[0].x < respostaRaizes[1].x) raizDireita = false;
										else raizDireita = true;
									}else {
										if (respostaRaizes[0].x < respostaRaizes[1].x) raizDireita = true;
										else raizDireita = false;
									}
									break lookRes2;
								}
							}
							if (raizPosOk) {
								feed += "A raiz à " + (raizDireita ? "direita":"esquerda") + " está correta, mas a outra não foi indicada. Veja no plano cartesiano que o gráfico de s(t) cruza o eixo t duas vezes. Esses cruzamentos indicam as duas raízes.";
							}else{
								feed += "Uma das raízes foi posicionada incorretamente, mas a outra não foi indicada.\n";
							}
							correto = false;
						}else {
							var raiz1:SimplePoint;
							var raiz2:SimplePoint;
							for each (var item:SimplePoint in pontosGrafico) 
							{
								if (item.related == pRaiz1) raiz1 = item;
								else if (item.related == pRaiz2) raiz2 = item;
								lookRes1: for each (respRaiz in respostaRaizes) 
								{
									if (Point.distance(respRaiz, new Point(item.xpos, item.ypos)) < tolerancia) {
										if(item.related == pRaiz1) raiz1ok = true;
										else raiz2ok = true;
										respostaRaizes.splice(respostaRaizes.indexOf(respRaiz), 1);
										break lookRes1;
									}
									
								}
							}
							if (raiz1ok && raiz2ok) {
								feed += "As duas raízes foram indicadas corretamente.\n";
							}else if (raiz1ok) {
								if (raiz2.ypos != 0) {
									if (raiz2.xpos < raiz1.xpos) feed += "A raiz à direita está correta, mas a outra não: veja o gráfico de s(t) e lembre-se de que, por definição, a raiz é um ponto com ordenada nula, isto é, sobre o eixo t.";
									else feed += "A raiz à esquerda está correta, mas a outra não: veja o gráfico de s(t) e lembre-se de que, por definição, a raiz é um ponto com ordenada nula, isto é, sobre o eixo t.";
								}else {
									if (raiz2.xpos < raiz1.xpos) feed += "A raiz à direita está correta, mas a outra não: veja o gráfico de s(t).";
									else feed += "A raiz à esquerda está correta, mas a outra não: veja o gráfico de s(t).";
								}
								correto = false;
							}else if (raiz2ok) {
								if (raiz1.ypos != 0) {
									if (raiz1.xpos < raiz2.xpos) feed += "A raiz à direita está correta, mas a outra não: veja o gráfico de s(t) e lembre-se de que, por definição, a raiz é um ponto com ordenada nula, isto é, sobre o eixo t.";
									else feed += "A raiz à esquerda está correta, mas a outra não: veja o gráfico de s(t) e lembre-se de que, por definição, a raiz é um ponto com ordenada nula, isto é, sobre o eixo t.";
								}else {
									if (raiz1.xpos < raiz2.xpos) feed += "A raiz à direita está correta, mas a outra não: veja o gráfico de s(t).";
									else feed += "A raiz à esquerda está correta, mas a outra não: veja o gráfico de s(t).";
								}
								correto = false;
							}else {
								feed += "As duas raízes foram indicadas incorretamente.\n";
								correto = false;
							}
						}
						break;
					case 2:
						if (pontosGrafico.length == 0) {
							feed += "A raiz (de multiplicidade 2) não foi indicada. Veja no plano cartesiano que o gráfico de s(t) apenas toca o eixo t, sem cruzá-lo. Neste caso, temos ainda duas raízes, mas elas têm a mesma abscissa.";
						}else if (pontosGrafico.length == 1) {
							
							if (Point.distance(new Point(pontosGrafico[0].xpos, pontosGrafico[0].ypos), new Point(respostaRaizes[0].x, respostaRaizes[0].y)) < tolerancia) {
								feed += "A raiz (de multiplicidade 2) foi posicionada corretamente.\n";
							}else {
								feed += "A raiz (de multiplicidade 2) foi posicionada incorretamente. Veja o gráfico de s(t).\n";
							}
							correto = false;
						}else {
							for each (var item2:SimplePoint in pontosGrafico) 
							{
								lookRes3: for each (var respRaiz2:Point in respostaRaizes) 
								{
									if (Point.distance(respRaiz2, new Point(item2.xpos, item2.ypos)) < tolerancia) {
										if(item2.related == pRaiz1) raiz1ok = true;
										else raiz2ok = true;
										respostaRaizes.splice(respostaRaizes.indexOf(respRaiz), 1);
										break lookRes3;
									}
									
								}
							}
							if (raiz1ok && raiz2ok) {
								feed += "As duas raízes foram indicadas corretamente..\n";
							}else if(raiz1ok || raiz2ok){
								feed += "Uma das raízes foi posicionada corretamente, mas a outra não: veja no plano cartesiano que o gráfico de s(t) apenas toca o eixo t, sem cruzá-lo. Neste caso, temos ainda duas raízes, mas elas têm a mesma abscissa.\n";
								correto = false;
							}else {
								feed += "As duas raízes foram indicadas incorretamente. Veja no plano cartesiano que o gráfico de s(t) apenas toca o eixo t, sem cruzá-lo. Neste caso, temos ainda duas raízes, mas elas têm a mesma abscissa.\n";
								correto = false;
							}
						}
						break;
					case 3:
						if (pontosGrafico.length == 0) {
							feed += "Nenhuma raiz foi indicada, o que está correto, pois s(t) não tem raiz: seu gráfico não cruza o eixo t.\n";
						}else if(pontosGrafico.length == 1){
							feed += "Uma raiz foi indicada, mas s(t) não tem raiz, pois seu gráfico não cruza o eixo t.\n";
							correto = false;
						}else {
							feed += "Duas raízes foram indicadas, mas s(t) não tem raiz, pois seu gráfico não cruza o eixo t.\n";
							correto = false;
						}
						break;
				}
				
				if(verticeSpliced != null) pontosGrafico.push(verticeSpliced);
				
				if (correto) {
					//Certo
					certoErrado.gotoAndStop(2);
				}else {
					//Errado
					certoErrado.gotoAndStop(1);
				}
				
				feedbackScreen.setText(feed);
				
				finalizado = true;
				certoErrado.visible = true;
				unlock(reinicia);
				concavidade.enabled = false;
				vertice.enabled = false;
				//lock(finalizaVermelha);
			}else {
				feedbackScreen.setText("Informe ambos, a concavidade e o vértice para avaliar.");
			}
		}
		
		override public function reset(e:MouseEvent = null):void 
		{
			resetPontos();
			sortExec();
			finalizado = false;
			concavidade.enabled = true;
			vertice.enabled = true;
			concavidade.selectedItem = { label:"Selecione...", data: -1 };
			vertice.selectedItem = { label:"Selecione...", data: -1 };
		}
		
		private function resetPontos():void 
		{
			for each (var item:SimplePoint in pontosGrafico) 
			{
				graph.removePoint(item);
				item.related.visible = true;
			}
			
			pontosGrafico.splice(0, pontosGrafico.length);
			
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