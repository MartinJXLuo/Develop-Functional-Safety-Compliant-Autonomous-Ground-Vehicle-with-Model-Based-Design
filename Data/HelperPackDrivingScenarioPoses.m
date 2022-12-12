classdef HelperPackDrivingScenarioPoses < matlab.System
    % HelperPackDrivingScenarioPoses packs Driving Scenario Compatible
    % poses into "BusActors" bus format. 
    %
    % NOTE: The name of this System Object and it's functionality may
    % change without notice in a future release, or the System Object
    % itself may be removed.
    %
    
    % Copyright 2022 The MathWorks, Inc.

    properties(Nontunable)
        EgoActorID = 1;
      

        ActorProfiles = struct(...
                    'ActorID',1,...
                    'ClassID',1,...
                    'Length',4.7,...
                    'Width',1.8,...
                    'Height',1.4,...
                    'OriginOffset',[0 0 0],...
                    'FrontOverhang',0,...
                    'RearOverhang',0,...
                    'Wheelbase',0,...
                    'Color',[0 0 0]);

        DefaultActorPoses = Simulink.Bus.createMATLABStruct("BusActors");
    end

    methods(Access = protected)

        function TargetPoses = stepImpl(obj, time, msgs)
            
            % Initialize outputs
            TargetPoses = obj.DefaultActorPoses;
            TargetPoses.Time = time;
            
            % Extract actor poses
            actors = msgs';
            numActors = length(actors);
            
            % Assign the output bus with the information from actors
            TargetPoses.NumActors = numActors-1;
            iTarget = 1;
            for i = 1:numActors
                if actors(i).ActorID ~= obj.EgoActorID
                
                    TargetPoses.Actors(iTarget).ActorID  = double(actors(i).ActorID);
                    TargetPoses.Actors(iTarget).Velocity = actors(i).Velocity;
                    TargetPoses.Actors(iTarget).Roll     = actors(i).Roll;
                    TargetPoses.Actors(iTarget).Pitch    = actors(i).Pitch;
                    TargetPoses.Actors(iTarget).Yaw      = actors(i).Yaw;
                    TargetPoses.Actors(iTarget).AngularVelocity = actors(i).AngularVelocity;
                    TargetPoses.Actors(iTarget).Position = actors(i).Position;

                    iTarget = iTarget + 1;
                end
            end
        end

        function num = getNumInputsImpl(~)
            num = 2;
        end

        function num = getNumOutputsImpl(~)
            num = 1;
        end

        function interface = getInterfaceImpl(~)
            import matlab.system.interface.*;
            interface = [Input("Time", Data), ...
                Input("Msg", Message),...
                Output("TargetPoses", Data)];
        end         

        function icon = getIconImpl(~)
                icon = "HelperPack" + newline + "DrivingScenarioPoses";
        end

        function out1 = getOutputSizeImpl(obj)
            out1 = [1 1];
        end

        function out1 = getOutputDataTypeImpl(~)            
            out1 = "BusActors";
        end

        function out1 = isOutputComplexImpl(~)
            out1 = false;
        end

        function out1 = isOutputFixedSizeImpl(~)
            out1 = true;
        end        
    end

    methods(Access = protected, Static)
        function simMode = getSimulateUsingImpl
            % Return only allowed simulation mode in System block dialog
            simMode = "Interpreted execution";
        end

        function flag = showSimulateUsingImpl
            % Return false if simulation mode hidden in System block dialog
            flag = false;
        end
    end    
end
