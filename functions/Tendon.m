classdef Tendon
    properties
        lengthPx
        diameterPx
        radiusPx
        scaleXY
        scaleZ
        length
        diameter
        radius
        volume
        depthPx
        depth
    end
    methods
%         function volume = calculateVolume(obj, radius, length)
%             theta = 2 * acos( (radius-radius*2/3) / radius );
%             segmentArea = (theta - sin(theta)) / 2 * radius^2;
%             volume = segmentArea * length;
%         end
        
        function volume = calculateVolume(obj)
            theta = 2 * acos( (obj.radius-obj.depth) / obj.radius );
            segmentArea = (theta - sin(theta)) / 2 * obj.radius^2;
            volume = segmentArea * obj.length;
        end 
        
        function obj = Tendon(len, dia, parameters)
            if nargin > 0
                if isnumeric(len) && isnumeric(dia) && isnumeric(parameters.scale) && length(parameters.scale)==3
                    obj.lengthPx = len;
                    obj.diameterPx = dia;
                    obj.scaleXY = parameters.scale(1);
                    obj.scaleZ = parameters.scale(3);
                    obj.radiusPx = obj.diameterPx/2;
                    
                    obj.depth = parameters.measurementDepth;
                    obj.depthPx = obj.depth / obj.scaleZ;
                    
                    obj.length = obj.lengthPx * obj.scaleXY;
                    obj.diameter = obj.diameterPx * obj.scaleXY;
                    obj.radius = obj.diameter/2;
                    obj.volume = obj.calculateVolume();
                    
                    
                    
                else
                    error('Values must be numeric')
                end
            end
        end  
    end
end