classdef Fire < handle
    properties (Constant)
        epsilon double = 2*pi / 1000
        windVelocity = [2 0]
        fuelStrength = 0.2
    end
    properties
        xFront = [];
        yFront = [];
        time = 0;
        curveParm = [];

        UI
    end
    properties (Dependent)
        frontLine
        normalVector
    end
    methods
        function this = Fire()
            
        end
        function initialiseSparkFront(this)
            % The front is a line in x-y plane characterised by parm s (bad name change)?
            this.curveParm = -pi:this.epsilon:pi;
            this.xFront = this.epsilon*cos(this.curveParm)';
            this.yFront = this.epsilon*sin(this.curveParm)';
        end
        function frontLine = get.frontLine(this)
           frontLine = [this.xFront this.yFront];
        end
        function moveFrontInTime(this)
            calcChangeFact = 1 / this.epsilon ;
            
        end

        function changeFront(this, timeFactor)
           front = this.frontLine;
           fuelMovement =  this.fuelStrength + this.normalVector;
           frontMovement = this.windVelocity + fuelMovement;

           frontMovement(sum(frontMovement .* this.normalVector, 2) < 0, :) = 0;
           front = front + timeFactor * frontMovement;

           [this.xFront, this.yFront] = deal(front(:,1),front(:,2));
           this.time = this.time + timeFactor;
        end

        function normal = get.normalVector(this)
            deriv_XbyS = circshift(this.xFront, -1) - circshift(this.xFront, 1);
            deriv_YbyS = circshift(this.yFront, -1) - circshift(this.yFront, 1);

            scale = 1 ./ (deriv_XbyS.^2 +deriv_YbyS.^2).^(1/2);
            normal = scale .* [deriv_YbyS, -deriv_XbyS];
        end

        function showFront(this)
            if isempty(this.UI)
                this.UI.fig = figure();
                this.UI.ax  = axes(this.UI.fig);
                hold(this.UI.ax, 'on');

                xlim(this.UI.ax, [-25 25]);
                ylim(this.UI.ax, [-25 25]);
                daspect(this.UI.ax, [1 1 1]);      % equal scaling without changing the limits
                grid(this.UI.ax, 'on');
                this.UI.ax.XLimMode = 'manual';
                this.UI.ax.YLimMode = 'manual';

                this.UI.line = plot(this.UI.ax, NaN, NaN, 'LineWidth', 1.5);
            end

            set(this.UI.line, 'XData', [this.xFront; this.xFront(1)], ...
                'YData', [this.yFront; this.yFront(1)]);
            title(this.UI.ax, sprintf('t = %.2f', this.time));
            drawnow limitrate;
        end
    end
    methods (Static)
        function simulate()
            fire = Fire();
            fire.initialiseSparkFront();
            for iT = 0:0.05:10
                fire.showFront();
                fire.changeFront(0.05);
                pause(0.01)
            end
        end
    end
end