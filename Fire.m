classdef Fire < handle
    properties
        deltaSpace double = 2*pi / 10000
        deltaTime  double = 0.05
        r0 = 0.1
        xWind = 0.1
        yWind = 0.1
        fuelStrength = 0.01
    end
    properties
        xFront = [];
        yFront = [];
        normalVector = [];
        time = 0;
        curveParm = [];

        UI
    end
    properties (Dependent)
        frontLine
    end
    methods
        function this = Fire(simulationParms, fuelStrength, wind)
            if nargin < 1
                return
            end
            this.deltaTime = simulationParms.deltaTime;
            this.deltaSpace = simulationParms.deltaSpace;
            this.r0 = simulationParms.r0;

            this.xWind = wind.xWind;
            this.yWind = wind.yWind;
        end
        function createSparkFront(this)
            % The front is a line in x-y plane characterised by parm s (bad name change)?
            s  = linspace(-pi, pi, 1/this.deltaSpace +1);  s(end) = [];
            this.xFront = this.r0*cos(s)';
            this.yFront = this.r0*sin(s)';
        end
        function frontLine = get.frontLine(this)
           frontLine = [this.xFront this.yFront];
        end
        
        function changeFront(this, deltaTime)
           front = this.frontLine;
           this.setNormalVector();

           % Wind Movement = (wind dot normal ) * normal
           windMovX = this.xWind .* this.normalVector(:,1);
           windMovY = this.yWind .* this.normalVector(:,2);
           
           windMovement = (windMovX + windMovY) .* this.normalVector;
           fuelMovement =  this.fuelStrength .* this.normalVector;

           frontMovement = windMovement + fuelMovement;

           frontMovement(sum(frontMovement .* this.normalVector, 2) < 0, :) = 0;
           front = front + deltaTime * frontMovement;

           [this.xFront, this.yFront] = deal(front(:,1),front(:,2));
           this.time = this.time + deltaTime;
        end

        function normal = setNormalVector(this)
            deriv_XbyS = circshift(this.xFront, -1) - circshift(this.xFront, 1);
            deriv_YbyS = circshift(this.yFront, -1) - circshift(this.yFront, 1);

            scale = 1 ./ (deriv_XbyS.^2 +deriv_YbyS.^2).^(1/2);
            this.normalVector = scale .* [deriv_YbyS, -deriv_XbyS]; normal = this.normalVector;
        end
    end
    methods (Static)
        function simulate(numSteps)
            fire = Fire();
            fire.createSparkFront();
            for iT = 0:numSteps
                fire.changeFront(fire.deltaTime);
                Fire.showFront(fire, 'on');
                pause(0.01)
            end
        end
        function demonstrateInstability()
            % Instability of this solution when setting using the same
            % parameter for radius as differences in spatial set (as i naively did originally)

            % Also shows that we need a method with much stronger convergance
            deltaT = 0.05; deltaSpace = 0.000001;
            fire = Fire(deltaT, deltaSpace, deltaSpace);
            fire.createSparkFront();
            
            disp(['distance = angle * radius' newline])
            disp(['distance = deltaSpace * deltaSpace' newline])
            disp(['distance = ' num2str(deltaSpace) ' * ' num2str(deltaSpace) newline])
            disp('distance = 1 / deltaSpace')
        end
        function showFront(fire, visible)
            if isempty(fire.UI)
                fire.UI.fig = figure(Visible='off');
                fire.UI.ax  = axes(fire.UI.fig);
                fire.UI.ax.Color =   [0.00 0.27 0.13];     
                hold(fire.UI.ax, 'on');
                hold(fire.UI.ax, 'on');

                xlim(fire.UI.ax, [-5 10]);
                ylim(fire.UI.ax, [-5 10]);
                daspect(fire.UI.ax, [1 1 1]);      % equal scaling without changing the limits
                grid(fire.UI.ax, 'on');
                fire.UI.ax.XLimMode = 'manual';
                fire.UI.ax.YLimMode = 'manual';

                fire.UI.line = plot(fire.UI.ax, NaN, NaN, ...
                    'LineWidth', 3, ...               
                    'Color', [1 0.5 0]);
                fire.UI.oldLines = {};
                set(fire.UI.fig, 'Visible', visible)
            end

            fire.UI.oldLines = {fire.UI.line fire.UI.oldLines};

            if strcmp(visible, 'on')
                set(fire.UI.line, 'XData', [fire.xFront; fire.xFront(1)], ...
                    'YData', [fire.yFront; fire.yFront(1)]);
                title(fire.UI.ax, sprintf('t = %.2f', fire.time));
                drawnow limitrate;
            end
        end
   
    end
end