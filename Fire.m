classdef Fire < handle
    properties (Dependent) % dependent on the environment
        dx
        dt
        xWind
        yWind
        fuelStrength
        r0
    end
    properties
        type             enumFireType
        environment      Environment
        initialCondition InitialCondition
    end
    properties
        xFront = [];
        yFront = [];
        normalVector = [];
        time = 0;

        UI
    end
    properties (Dependent)
        front
    end
    methods
        function this = Fire(environment, initialCondition)
            % Fire() uses the defaults; pass either object to override.
            if nargin < 1 || isempty(environment)
                environment = Environment();
            end
            if nargin < 2 || isempty(initialCondition)
                initialCondition = InitialCondition();
            end
            this.environment      = environment;
            this.initialCondition = initialCondition;
            this.initialCondition.setEnvironment(environment);
            this.reset();
        end

        function reset(this)
            [this.xFront, this.yFront] = this.initialCondition.getMarkerFront();
            this.normalVector = [];
            this.time = 0;
        end

        function dx = get.dx(this)
            dx = this.environment.dx;
        end
        function dt = get.dt(this)
            dt = this.environment.dt;
        end
        function xWind = get.xWind(this)
            xWind = this.environment.xWind;
        end
        function yWind = get.yWind(this)
            yWind = this.environment.yWind;
        end
        function f = get.fuelStrength(this)
            f = this.environment.fuelStrength;
        end
        function r0 = get.r0(this)
            r0 = this.initialCondition.r0;
        end

        function frontLine = get.front(this)
           frontLine = [this.xFront this.yFront];
        end

        function changeFront(this, dt)
           if nargin < 2 
               dt = this.dt; 
           end
           fFront = this.front;
           this.setNormalVector();

           % Wind Movement = (wind dot normal ) * normal
           windMovX = this.xWind .* this.normalVector(:,1);
           windMovY = this.yWind .* this.normalVector(:,2);

           windMovement = (windMovX + windMovY) .* this.normalVector;
           fuelMovement =  this.fuelStrength .* this.normalVector;

           frontMovement = windMovement + fuelMovement;

           frontMovement(sum(frontMovement .* this.normalVector, 2) < 0, :) = 0;
           fFront = fFront + dt * frontMovement;

           [this.xFront, this.yFront] = deal(fFront(:,1),fFront(:,2));
           this.time = this.time + dt;
        end

        function normal = setNormalVector(this)
            % Is there some clever recusrisive way to go through rest of
            % taylor expansion ?
            deriv_XbyS = circshift(this.xFront, -1) - circshift(this.xFront, 1);
            deriv_YbyS = circshift(this.yFront, -1) - circshift(this.yFront, 1);

            scale = 1 ./ (deriv_XbyS.^2 +deriv_YbyS.^2).^(1/2);
            this.normalVector = scale .* [deriv_YbyS, -deriv_XbyS]; normal = this.normalVector;
        end
    end
    methods (Static)
        function fire = simulate(numSteps, fire)
            if nargin < 1
                numSteps = 200; 
            end
            if nargin < 2
                fire = Fire(); 
            end
            Fire.showFront(fire, 'on');
            pause(0.05)
            for iT = 0:numSteps
                fire.changeFront();
                Fire.showFront(fire, 'on');
                pause(0.01)
            end
        end
        function demonstrateInstability()
            % Marker spacing on the spark is r0 * ds, NOT ds: radius and
            % parametric step are not interchangeable (as I originally
            % assumed by using one parameter for both).
            ic = InitialCondition(r0 = 1e-6, nMarkers = 1e6);
            ds = 2*pi / ic.nMarkers;

            disp('distance = angle * radius')
            disp(['distance = ds * r0 = ' num2str(ds) ' * ' num2str(ic.r0)])
            disp(['distance = ' num2str(ds * ic.r0) '   (eps = ' num2str(eps) ')'])

            % The normals survive even this spacing: on an exact circle the
            % sin(ds) factor cancels in the normalisation, so the central
            % difference returns the radial direction for any ds. What this
            % scheme actually lacks is marker redistribution - spacing only
            % bites once markers drift together off a circle.
        end
        function showFront(fire, visible)
            if isempty(fire.UI)
                d = [fire.environment.X fire.environment.Y];

                fire.UI.fig = uifigure(Visible='off');
                fire.UI.ax  = axes(fire.UI.fig);
                fire.UI.ax.Color =   [0.00 0.27 0.13];
                hold(fire.UI.ax, 'on');

                xlim(fire.UI.ax, d(1:2));
                ylim(fire.UI.ax, d(3:4));
                daspect(fire.UI.ax, [1 1 1]);      % equal scaling without changing the limits
                grid(fire.UI.ax, 'on');
                fire.UI.ax.XLimMode = 'manual';
                fire.UI.ax.YLimMode = 'manual';

                fire.UI.line = plot(fire.UI.ax, NaN, NaN, ...
                    'LineWidth', 3, ...
                    'Color', [1 0.5 0]);
            end
            set(fire.UI.fig, 'Visible', visible)

            if strcmp(visible, 'on')
                set(fire.UI.line, 'XData', [fire.xFront; fire.xFront(1)], ...
                    'YData', [fire.yFront; fire.yFront(1)]);
                title(fire.UI.ax, sprintf('t = %.2f', fire.time));
                drawnow limitrate;
            end
        end

    end
end
