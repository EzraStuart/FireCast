classdef LevelSetFire < Fire
    properties
        fireSurface
    end

    methods
        function this = LevelSetFire(environment, initialCondition)
            % Fire() uses the defaults; pass either object to override.
            if nargin < 1 || isempty(environment)
                environment = Environment();
            end
            if nargin < 2 || isempty(initialCondition)
                initialCondition = InitialCondition();
            end
            this = this@Fire(environment, initialCondition)
        end
        
        function reset(this)
            this.type = enumFireType.levelSet;
            this.fireSurface = this.initialCondition.getFireSurface();
        end


        function changeFront(this)
            this.moveFireSurface();
            this.setXYFronts();
        end

        function moveFireSurface(this)
            [deriv, d] = this.getSpatialDerivCD();
            
            windMov = this.xWind .* deriv(:,:,1) + this.yWind .* deriv(:,:,2);
            fuelMov = this.fuelStrength .* d;
            surfaceMov = windMov + fuelMov; 

            this.fireSurface = this.fireSurface - this.dt * surfaceMov;
            this.time = this.time + this.dt;
        end

        function setXYFronts(this)
            contourMat = contourc(this.environment.x, this.environment.y, this.fireSurface,[0 0]);

            if isempty(contourMat)
                error('No more fire!!')
            end

            this.xFront = contourMat(1,2:end)';
            this.yFront = contourMat(2,2:end)';
        end

        function frontIdx = getFrontIdx(this)
            frontIdx = abs(this.fireSurface) < 10*eps;
        end

        function [n, d] = getNormalVectorCD(this)
            d = this.getSpatialDerivCD();

            n = d ./ (d(:,:,1).^2 + d(:,:,2).^2).^(1/2);
        end
        
        function [deriv, d] = getSpatialDerivCD(this) 
            dX = nan(size(this.fireSurface)); dY = dX;
            dX(2:end-1,:) = this.fireSurface(3:end, :) - this.fireSurface(1:end-2, :);
            dY(:,2:end-1) = this.fireSurface(:, 3:end) - this.fireSurface(:, 1:end-2);

            % Boundary Condition:
            dX(1,:) = dX(2,:); dX(end,:) = dX(end - 1,:);
            dY(:,1) = dY(:,2); dY(:, end) = dY(:,end-1);

            deriv = cat(3, dX, dY) ./ (2 * this.dx);
            d = (deriv(:,:,1).^2 + deriv(:,:,2).^2).^(1/2);
        end
    end
    methods (Static)
        function fire = simulate(numSteps, fire)
            if nargin < 1
                numSteps = 20000; 
            end
            if nargin < 2
                fire = LevelSetFire();
                fire.setXYFronts();
            end
            Fire.showFront(fire, 'on');
            pause(0.05)
            for iT = 0:numSteps
                fire.changeFront();

                Fire.showFront(fire, 'on');
                pause(0.01)
            end
        end
    end
end