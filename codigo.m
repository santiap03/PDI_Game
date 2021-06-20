classdef codigo < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        Fondo                  matlab.ui.control.Image
        m11                    matlab.ui.control.Image
        m12                    matlab.ui.control.Image
        m21                    matlab.ui.control.Image
        m22                    matlab.ui.control.Image
        m23                    matlab.ui.control.Image
        m31                    matlab.ui.control.Image
        m32                    matlab.ui.control.Image
        m41                    matlab.ui.control.Image
        m42                    matlab.ui.control.Image
        m52                    matlab.ui.control.Image
        m51                    matlab.ui.control.Image
        VelocidadxSliderLabel  matlab.ui.control.Label
        VelocidadxSlider       matlab.ui.control.Slider
        StartButton            matlab.ui.control.Button
        ball                   matlab.ui.control.Image
        GaugeLabel             matlab.ui.control.Label
        Gauge                  matlab.ui.control.LinearGauge
        StopButton             matlab.ui.control.Button
        statusEditFieldLabel   matlab.ui.control.Label
        statusEditField        matlab.ui.control.EditField
        ScoreLabel             matlab.ui.control.Label
        StatusEditField1       matlab.ui.control.EditField
    end

%--------------------------------------------------------------------------
%------- JUEGO FALL DWON-------------------------------------------
%------- Por: Santiago Alvarez Pinzon    santiago.alvarezp@udea.edu.co --------------
%-------      Profesor auxiliar Universidad de Antioquia  -----------------
%-------      CC 1152463106 -------------------
%-------      Sebastian Larrea Henao    sebastian.larrea@udea.edu.co --------------
%-------      CC 1020491334 -------------------
%------- Curso Básico de Procesamiento de Imágenes y Visión Artificial-----
%------- Octubre 2020--------------------------------------------------
%--------------------------------------------------------------------------   

    
    methods (Access = private)
        
        
        
        
        
        function results = ballmove(app)
            %--------------------------------------------------------------------------
            %-- 4. Movimiento de la pelota  ---------------------
            %--------------------------------------------------------------------------
            global score; global px; global py;global levels; global heights; global holes, global maxl;global stop;%Definicion de las variables globales
            heights= [levels{1}(2).Position(2)+19 levels{2}(2).Position(2)+19 levels{3}(2).Position(2)+19 levels{4}(2).Position(2)+19 levels{5}(2).Position(2)+19 ];% vector de las alturas de los niveles
            %---- Limites horizontales de la imagen para la pelota -------------------------

            if((px<= app.Fondo.Position(1)  && app.VelocidadxSlider.Value<0) | ((px+20)>= (app.Fondo.Position(1)+246)  &&  app.VelocidadxSlider.Value>0 ))%Condiciones de bordes horizontales para hacer a la velocidad 0
                px=px;%La pelota no se desplaza hacia afuera si se encuentra en un borde
            else
                px=px+app.VelocidadxSlider.Value*2;%De otra forma se desplaza en funcion del valor de entrada
            end
            if(py >= heights(maxl) && ~(py==heights(maxl)))%Condicion de caida libre de la pelota con respecto al nivel que tiene debajo
                py=py-5;%Descenso de la pelota
            end
            %---- Paso por agujeros -------------------------

            b1=~(holes(maxl,1)<=px && px<=holes(maxl,2))  ;%Condiciones que identifican si la pelota pasa por el agujero izquierdo
            b2=~(holes(maxl,3)<=px  && px<=holes(maxl,4));%Condiciones que identifican si la pelota pasa por el agujero derecho
            if(py<= (heights(maxl)+1) && b1 && b2)%Si no se cumple la Condicion de caida por agujeros la pelota sube con el bloque que tiene debajo
                py= heights(maxl)+1;%Pasos que sube la pelota junto con el nivel que tiene debajo apuntado por maxl
            end

            %---- Identificacion de los niveles -------------------------

            xh= heights(heights>py);%Vector que identifica alturas de nivel superiores a la de la pelota
            xa= heights(heights==py);%Vector que identifica alturas de nivel iguales a la de la pelota
            if(isempty(xh)==1)%Si no hay ningun nivel sobre la pelota se asigna el bloque mas alto al puntero maxl
                maxl=find(heights==max(heights));%maxl indica que nivel tiene debajo la pelota
            elseif(isempty(xa)==0)%Condicion, si la pelota se encuentra justo sobre un nivel, el cursor apunta a ese nivel
                maxl=heights(heights==py);%Maxl apunta al nivel con la misma posicion que la pelota
            else
                maxl=find(heights==min(xh))+1; %Maxl apunta al nivel anterior al de menor altura que supere la altura de la pelota
                if(maxl==6)%Si se pasa al ultimo nivel, se apunta al primero de nuevo
                    maxl=1;%Maxl apunta al primer valor del vector de alturas
                end
            %---- Puntuacion -------------------------
                score=score+1;
                app.StatusEditField1.Value=num2str(score);
            end
            app.Gauge.Value=maxl;%Lee el valor de maxl en el gauge
            %if(py== heights(maxl))
             %   py=100;
            %end
            %---- Condicion te perdida -------------------------

            if(py>=338)%Si la pelota sobrepasa cierto limite superior se termina el juego
                stop=1;%Se activa la bandera de stop
                app.statusEditField.Value="Game over";%Se muestra el mensaje game over
                app.ball.Visible='off';%Desaparece la pelota
            end
            
            set(app.ball,'Position', [px py 20 20]);%Actualiza el valor de la ubicacion de la pelota
end
        
        function results = setup(app)
            global score;
            global px; global py;global levels; global heights, global holes;global maxl; %Definicion de las variables globales
            app.ball.Visible='on';%Hace visible la pelota
            app.VelocidadxSlider.Visible="on";%Hace visible  el slider
            score=0;
            px=300;%Posiciones iniciales de la pelota x
            py=338;%Posiciones iniciales de la pelota y
            maxl=1;%Inicializa el apuntador de nivel bajo la pelota
            levels= {[0  app.m11 app.m12 ], [ 0 app.m21 app.m22 app.m23 ], [0 app.m31 app.m32 ],  [0 app.m41 app.m42], [0 app.m51 app.m52]};% Crea el vector de objetos graficos de bloques
            heights= [levels{1}(2).Position(2)+19 levels{2}(2).Position(2)+19 levels{3}(2).Position(2)+19 levels{4}(2).Position(2)+19 levels{5}(2).Position(2)+19 ];%Crea el vector de alturas de los bloques y les suma el grosor de los mismos
            holes= [290 310 0 0; 271 299 369 391; 299 333 430 441; 350 369 0 0;290 362 0 0 ];%Vector de ubicacion de los agujeroos
            app.statusEditField.Value="Jugando";%Muestra el mensaje jugando
            
            %PDI-----------------------------------------------------------
            global ee;global cam; %Mascara para alterar la morfologia y objeto camara
            cam=webcam;%Conexion con la camara
            ee=strel('square',3);%Mascara cuadrada
            %-----------------------------------------------------------
            
        end
        
        function results = block_move(app)
            %--------------------------------------------------------------------------
            %-- 5. Movimiento de los bloques  ---------------------
            %--------------------------------------------------------------------------
            global levels;%Posiciones iniciales de la pelota x
            for i=1:length(levels)%Recorrido de niveles de bloques  
                for j=2:length(levels{i})%Recorrido de bloques por nivel                           
                    if levels{i}(j).Position(2)>= 338%Si la ubicacion de un bloque sobrepasa el tope se reinicia
                       set(levels{i}(j), 'Position', [levels{i}(j).Position(1) 90 levels{i}(j).Position(3) levels{1}(2).Position(4)] )%Reinicia la posicion del bloque i,j
                    else %Si no, se aumenta la posicion y para subir cada bloque constantemente
                    set(levels{i}(j), 'Position', [levels{i}(j).Position(1) levels{i}(j).Position(2)+0.6 levels{i}(j).Position(3) levels{1}(2).Position(4)] )%Mueve el bloque i,j
                    end
                end
                    
            end         
        end%end function
        
        function results = posicion1(app)
            %--------------------------------------------------------------------------
            %-- 3. Obtencion de velocidad a traves de la camara  ---------------------
            %--------------------------------------------------------------------------
            global ee; global cam;
            q=snapshot(cam);


           % Conversion a HSV
            I = rgb2hsv(q);
    
            % Limites para H
            channel1Min = 0.931;
            channel1Max = 0.000;
    
            % Limites de mascara para S
            channel2Min = 0.751;
            channel2Max = 1.000;
    
           % Limites de mascara para V
            channel3Min = 0.541;
            channel3Max = 0.871;
    
            % Imagen filtrada a partir de los limites 
             qf_bw = ( (I(:,:,1) >= channel1Min) | (I(:,:,1) <= channel1Max) ) & ...
            (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
            (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
         
            for j=1:12
              qf_bw=imerode(qf_bw,ee);%Deformacion para eliminar manchas irrelevantes
            end
            for j=1:5
              qf_bw=imdilate(qf_bw,ee);%Reformacion de la figura principal
            end
            
            cla reset;
            %imagesc(flip(qf_bw,2));%Muestra de la imagen resultante
            s = regionprops(qf_bw,'centroid');%Localizacion de los centroides 
            centroids = cat(1,s.Centroid);
            if isempty(centroids)%Si no hay nada en la imagen la localizacion es 0
                x = 0
            else%Se localiza el centroide mayor en la ventana de 0 a 1280
                x = 1280 - centroids(1)           
            end
            a= (x-640)*(5/640);%A partir de la ubicacion del objeto de control se define la velocidad de la pelota entre -5 y 5
            x=round(a);%Elimina decimales de x
            app.VelocidadxSlider.Value=x;%Se asigna el valor al slider para visualizar la velocidad
    
                end
    end%end methods   
            
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            %--------------------------------------------------------------------------
            %--1. Inicializo el sistema -----------------------------------------------
            %--------------------------------------------------------------------------
            global stop;%Definicion como variable global
            stop=0;%Apaga la bandera de stop al presionar start
            setup(app);%Activa la funcion de setup
            %dbstop if caught error%Debug
            %--------------------------------------------------------------------------
            %--2. Ciclo inifinito "Jugando" controlado por la bandera stop -----------------------------------------------
            %--------------------------------------------------------------------------
            while(stop==0)%
               block_move(app);%Mueve los bloques
               ballmove(app); %mueve la pelota
               drawnow;%Actualiza los graficos y los callback
               posicion1(app);
               pause(0.001);%delay                     
            end
            
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            %--------------------------------------------------------------------------
            %-- 6. Stop  ---------------------
            %--------------------------------------------------------------------------
            global stop;%Definicion como variable global
            stop=1;%Si se presiona stop, se detiene el juego
            app.statusEditField.Value="Stop";%Muestra el mensaje stop

        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            %Callback de cierre de la ventana
            clear cam;%Cierre de la camara
            delete(app)%Elimina toda la app
            clear camObject;
            clear all;%Limpia el workspace
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Color = [0 0.4471 0.7412];
            app.UIFigure.Position = [100 100 668 369];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Resize = 'off';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create Fondo
            app.Fondo = uiimage(app.UIFigure);
            app.Fondo.Position = [219 79 246 279];
            app.Fondo.ImageSource = '102 - Copy.jpg';

            % Create m11
            app.m11 = uiimage(app.UIFigure);
            app.m11.Position = [219 311 72 19];
            app.m11.ImageSource = 'wood1.png';

            % Create m12
            app.m12 = uiimage(app.UIFigure);
            app.m12.Position = [329 311 131 19];
            app.m12.ImageSource = 'wood3.png';

            % Create m21
            app.m21 = uiimage(app.UIFigure);
            app.m21.Position = [219 260 50 19];
            app.m21.ImageSource = 'wood2.png';

            % Create m22
            app.m22 = uiimage(app.UIFigure);
            app.m22.Position = [318 260 52 19];
            app.m22.ImageSource = 'wood2.png';

            % Create m23
            app.m23 = uiimage(app.UIFigure);
            app.m23.Position = [413 260 47 19];
            app.m23.ImageSource = 'wood2.png';

            % Create m31
            app.m31 = uiimage(app.UIFigure);
            app.m31.Position = [219 204 81 19];
            app.m31.ImageSource = 'wood1.png';

            % Create m32
            app.m32 = uiimage(app.UIFigure);
            app.m32.Position = [352 204 79 19];
            app.m32.ImageSource = 'wood1.png';

            % Create m41
            app.m41 = uiimage(app.UIFigure);
            app.m41.Position = [219 157 131 19];
            app.m41.ImageSource = 'wood3.png';

            % Create m42
            app.m42 = uiimage(app.UIFigure);
            app.m42.Position = [396 156 69 19];
            app.m42.ImageSource = 'wood1.png';

            % Create m52
            app.m52 = uiimage(app.UIFigure);
            app.m52.Position = [381 110 79 19];
            app.m52.ImageSource = 'wood1.png';

            % Create m51
            app.m51 = uiimage(app.UIFigure);
            app.m51.Position = [219 110 72 19];
            app.m51.ImageSource = 'wood1.png';

            % Create VelocidadxSliderLabel
            app.VelocidadxSliderLabel = uilabel(app.UIFigure);
            app.VelocidadxSliderLabel.HorizontalAlignment = 'right';
            app.VelocidadxSliderLabel.Visible = 'off';
            app.VelocidadxSliderLabel.Position = [106 -53 67 22];
            app.VelocidadxSliderLabel.Text = 'Velocidad x';

            % Create VelocidadxSlider
            app.VelocidadxSlider = uislider(app.UIFigure);
            app.VelocidadxSlider.Limits = [-5 5];
            app.VelocidadxSlider.Visible = 'off';
            app.VelocidadxSlider.Position = [229 55 213 3];

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.Position = [518 328 100 22];
            app.StartButton.Text = 'Start';

            % Create ball
            app.ball = uiimage(app.UIFigure);
            app.ball.Position = [299 337 20 20];
            app.ball.ImageSource = 'pngwing.com.png';

            % Create GaugeLabel
            app.GaugeLabel = uilabel(app.UIFigure);
            app.GaugeLabel.HorizontalAlignment = 'center';
            app.GaugeLabel.Visible = 'off';
            app.GaugeLabel.Position = [524 128 42 22];
            app.GaugeLabel.Text = 'Gauge';

            % Create Gauge
            app.Gauge = uigauge(app.UIFigure, 'linear');
            app.Gauge.Limits = [0 6];
            app.Gauge.Visible = 'off';
            app.Gauge.Position = [484 165 112.312512397766 39.6000003814697];

            % Create StopButton
            app.StopButton = uibutton(app.UIFigure, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Visible = 'off';
            app.StopButton.Position = [518 287 100 22];
            app.StopButton.Text = 'Stop';

            % Create statusEditFieldLabel
            app.statusEditFieldLabel = uilabel(app.UIFigure);
            app.statusEditFieldLabel.HorizontalAlignment = 'right';
            app.statusEditFieldLabel.FontSize = 20;
            app.statusEditFieldLabel.FontWeight = 'bold';
            app.statusEditFieldLabel.FontColor = [0.6353 0.0784 0.1843];
            app.statusEditFieldLabel.Position = [23 211 64 25];
            app.statusEditFieldLabel.Text = 'status';

            % Create statusEditField
            app.statusEditField = uieditfield(app.UIFigure, 'text');
            app.statusEditField.Position = [23 174 165 22];
            app.statusEditField.Value = 'Presione Start para empezar';

            % Create ScoreLabel
            app.ScoreLabel = uilabel(app.UIFigure);
            app.ScoreLabel.HorizontalAlignment = 'center';
            app.ScoreLabel.FontSize = 20;
            app.ScoreLabel.FontWeight = 'bold';
            app.ScoreLabel.FontColor = [0.6353 0.0784 0.1843];
            app.ScoreLabel.Position = [23 290 61 25];
            app.ScoreLabel.Text = 'Score';

            % Create StatusEditField1
            app.StatusEditField1 = uieditfield(app.UIFigure, 'text');
            app.StatusEditField1.Position = [36 250 98 22];
            app.StatusEditField1.Value = '0';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = codigo

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end