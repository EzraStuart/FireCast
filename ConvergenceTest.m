classdef ConvergenceTest
    methods (Static)
        
        function runCircleTest()
            [ic, env] = ConvergenceTest.setUpCircle();
            ConvergenceTest.runSimulations(ic, env);
        end

        function [ic, env] = setUpCircle()
            ic = InitialCondition();
            ic.r0 = 0.5; ic.shape = enumFrontShape.Spark;

            env = Environment();
            env.setWind([0 0]);
            env.fuelStrength = 1;
        end

        function runSimulations(ic, env)
            dx = [0.05 0.025 0.0125 0.00625];
            accL1 = [];
            accLInf = [];
            for iDx = dx
                env.dx = iDx;
                env.dt = 0.5*iDx;
                ic.setEnvironment(env);

                disp(['New Fire' newline 'dx: ' num2str(iDx) newline 'dt: ' num2str(env.dt)])

                iFire = LevelSetFire(env, ic);

                for iTS = 1:(1 / env.dt)
                    iFire.moveFireSurfaceUW();
                end
                env.dt = 1 - iFire.time;
                iFire.moveFireSurfaceUW();

                iFire.setXYFronts();

                iFront = iFire.front;
                iDiff = zeros(size(iFront, 1),1);
                for iR = 1:size(iFront, 1)
                    iNorm = norm(iFront(iR,:));

                    iDiff(iR) = abs(1.5 - iNorm);
                end
                iMean = mean(iDiff); iMax = max(iDiff);

                disp(['Mean Diff: ' num2str(iMean)])
                disp(['Max Diff: ' num2str(iMax)])
                disp(['Min Diff: ' num2str(min(iDiff))])
                disp(newline)

                if ~isempty(accLInf)
                    disp(['Order of accuracy L1: ' num2str(log2(accL1 / iMean))])
                    disp(['Order of accuracy LInf: ' num2str(log2(accLInf / iMax))])
                end
                accL1 = iMean; accLInf = iMax;
                disp([newline newline newline])

                Fire.showFront(iFire, 'on');
            end
        end
    end
end