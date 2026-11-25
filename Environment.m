classdef Environment < handle
    properties
        coords enumCoordinateSystem = enumCoordinateSystem.Cart

        dx           double = 0.01      
        dt           double = 0.2
        fuelStrength double = 0.01
        xWind        double = 0.1
        yWind        double = 0.1
    end
    properties 
        X = [-2 20]
        Y = [-2 20]
    end
    properties (Dependent)
        metric
        mesh
        x
        y
    end

    methods
        function this = Environment(varargin)
            for iArg = 1:2:numel(varargin)
                this.(varargin{iArg}) = varargin{iArg+1};
            end
        end

        function metric = get.metric(this)
            switch this.coords
                case CoordinateSystem.Cart
                    metric = eye(2);
                otherwise
                    error('Environment:notImplemented', ...
                        'metric not implemented for %s.', string(this.coords));
            end
        end

        function mesh = get.mesh(this)
            [meshX, meshY] = meshgrid(this.x, this.y);
            mesh = cat(3, meshX, meshY);
        end
        
        function x = get.x(this)
            x = Environment.getDomain(this.X, this.dx);
        end

        function y = get.y(this)
            y= Environment.getDomain(this.Y, this.dx);
        end

        function setUp(this)
            switch this.coords
                case CoordinateSystem.Cart
                    this.setUpCartesian();
                otherwise
                    error('Environment:notImplemented', ...
                        'setUp not implemented for %s.', string(this.coords));
            end
        end

        function setUpCartesian(this)
            d = this.domain;
            this.x = d(1):this.dx:d(2);
            this.y = d(3):this.dx:d(4);

            [this.X, this.Y] = ndgrid(this.x, this.y);
        end
    end
    methods (Static)
        function dom = getDomain(x, dx)
            nX = (diff(x) / dx) + 1;
            dom = linspace(x(1), x(2), nX);
        end
    end
end
