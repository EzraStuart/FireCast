classdef InitialCondition < handle
    properties
        shape enumFrontShape = enumFrontShape.Spark

        r0       double = 0.1       % spark radius
        centre   double = [0 0]
        nMarkers double = 400      % front resolution (count, not a spacing)

        environment Environment
    end

    methods
        function this = InitialCondition(varargin)
            for iArg = 1:2:numel(varargin)
                this.(varargin{iArg}) = varargin{iArg+1};
            end
        end

        function setEnvironment(this, environment)
            this.environment = environment;
        end

        function [xFront, yFront] = getMarkerFront(this)
            switch this.shape
                case enumFrontShape.Spark
                    s = linspace(-pi, pi, this.nMarkers + 1);  s(end) = [];
                    xFront = this.centre(1) + this.r0 * cos(s)';
                    yFront = this.centre(2) + this.r0 * sin(s)';

                otherwise
                    error('InitialCondition:notImplemented', ...
                        'front not implemented for %s.', string(this.shape));
            end
        end

        function [fireSurface, fireFront] = getFireSurface(this)
            switch this.shape
                case enumFrontShape.Spark
                    mesh = this.environment.mesh;
                    xMesh = mesh(:,:,1); yMesh = mesh(:,:,2);
                    
                    fireSurface = xMesh.^2 + yMesh.^2 - this.r0^2;
                otherwise
                    error('InitialCondition:notImplemented', ...
                        'level set not implemented for %s.', string(this.shape));
            end

            if nargout == 2
                fireFront = fireSurface == 0;
            end
        end
    end
end
