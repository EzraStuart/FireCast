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
            this.moveFireSurfaceUW();
            this.setXYFronts();
        end

        function moveFireSurfaceCD(this)
            [deriv, d] = this.getSpatialDerivCD();
            
            windMov = this.xWind .* deriv(:,:,1) + this.yWind .* deriv(:,:,2);
            fuelMov = this.fuelStrength .* d;
            surfaceMov = windMov + fuelMov; 

            this.fireSurface = this.fireSurface - this.dt * surfaceMov;
            this.time = this.time + this.dt;
        end

        function moveFireSurfaceUW(this)
            [deriv, d] = this.getSpatialDerivUW();
            
            fuelMov = this.fuelStrength .* d(:,:,:,2); % Fuel strength always pos

            % w dot grad
            xWindMov = max(this.xWind, 0) .* deriv(:,:,1,1) + min(this.xWind, 0) .* deriv(:,:,1,2);
            yWindMov = max(this.yWind, 0) .* deriv(:,:,2,1) + min(this.yWind, 0) .* deriv(:,:,2,2);

            % Enforce entropy condition
            windMov = max(xWindMov + yWindMov, 0);

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

        function [deriv, d] = getSpatialDerivUW(this)
            dXMinus = nan(size(this.fireSurface)); dYMinus = dXMinus;

            dXMinus(2:end, :) = this.fireSurface(2:end, :) - this.fireSurface(1:end-1,:);
            dXPlus = circshift(dXMinus, -1, 1);

            dYMinus(:, 2:end) = this.fireSurface(:, 2:end) - this.fireSurface(:, 1:end-1);
            dYPlus = circshift(dYMinus, -1, 2);


            % Impose a boundary condition:
            dXMinus(1,:) = dXMinus(2,:); dYMinus(:, 1) = dYMinus(:, 2);
            dXPlus(end,:) = dXPlus(end-1,:); dYPlus(:,end) = dYPlus(:,end-1);

            dMinus = cat(3, dXMinus, dYMinus);
            dPlus = cat(3, dXPlus, dYPlus);
            deriv = cat(4, dMinus, dPlus) ./ this.dx;

            dAbsPlus = (sum(max(deriv(:,:,:,1), 0).^2 + min(deriv(:,:,:,2),0).^2, 3)).^(1/2);
            dAbsMinus = (sum(min(deriv(:,:,:,1), 0).^2 + max(deriv(:,:,:,2),0).^2, 3)).^(1/2);

            d = cat(4, dAbsMinus, dAbsPlus);
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