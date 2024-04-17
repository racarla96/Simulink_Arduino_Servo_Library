classdef ServoDriver < realtime.internal.SourceSampleTime ...
        & coder.ExternalDependency 
    
    % Block to control a servo with a resolution of 1 us.
    % The library behind limits the output between 500 us and 2500 us.
    
    % Copyright 2016-2018 The MathWorks, Inc.
    %#codegen
    %#ok<*EMCA>
    
    properties

    end
    
    properties (Nontunable)
        pin = int32(3);
        min_us = int32(1000);
        max_us = int32(2000);
    end
    
    properties (Access = private)
        % Pre-computed constants.
    end

    properties (Access = protected)
        id = 0;
    end
    
    methods
        % Constructor
        function obj = ServoDriver(varargin)
            % Support name-value pair arguments when constructing the object.
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupImpl(obj) %#ok<MANU>
            if isempty(coder.target)
                % Place simulation setup code here
            else
                % Call C-function implementing device initialization
                id = int32(0);
                coder.cinclude('ServoDriver.h');
                coder.ceval('ServoDriver_Init', coder.wref(id), int32(obj.pin));
                obj.id = id;
            end
        end
        
        function stepImpl(obj, us)   %#ok<MANU>
            if isempty(coder.target)
                % Place simulation output code here
            else
                % Call C-function implementing device output
                coder.ceval('ServoDriver_Step', int32(obj.id), us, int32(obj.min_us), int32(obj.max_us));
            end
        end
        
        function releaseImpl(obj) %#ok<MANU>
            if isempty(coder.target)
                % Place simulation termination code here
            else
                % Call C-function implementing device termination
                %coder.ceval('source_terminate');
            end
        end
    end
    
    methods (Access=protected)
        %% Define output properties
        function num = getNumInputsImpl(~)
            num = 1;
        end
        
        function num = getNumOutputsImpl(~)
            num = 0;
        end
        
        function flag = isInputSizeMutableImpl(~,~)
            flag = false;
        end
        
        function flag = isInputComplexityMutableImpl(~,~)
            flag = false;
        end
        
        function validateInputsImpl(~, us)
            if isempty(coder.target)
                % Run input validation only in Simulation
                validateattributes(us,{'int32'},{'scalar'},'','us');
            end
        end
        
        function icon = getIconImpl(~)
            % Define a string as the icon for the System block in Simulink.
            icon = 'ServoDriver';
        end    
    end
    
    methods (Static, Access=protected)
        function simMode = getSimulateUsingImpl(~)
            simMode = 'Interpreted execution';
        end
        
        function isVisible = showSimulateUsingImpl
            isVisible = false;
        end
    end
    
    methods (Static)
        function name = getDescriptiveName()
            name = 'ServoDriver';
        end
        
        function b = isSupportedContext(context)
            b = context.isCodeGenTarget('rtw');
        end
        
        function updateBuildInfo(buildInfo, context)
            if context.isCodeGenTarget('rtw')
                % Update buildInfo
                srcDir = fullfile(fileparts(mfilename('fullpath')),'src'); %#ok<NASGU>
                includeDir = fullfile(fileparts(mfilename('fullpath')),'include');
                libDir =  fullfile(fileparts(mfilename('fullpath')),'libraries');
                libDirA =  fullfile(fileparts(mfilename('fullpath')),'libraries/Servo-1.2.1/src');

                % Include header files
                addIncludePaths(buildInfo,includeDir);
                addIncludePaths(buildInfo,libDir);
                addIncludePaths(buildInfo,libDirA);

                % Include source files
                addSourceFiles(buildInfo,'ServoDriver.cpp',srcDir);

                boardInfo = arduino.supportpkg.getBoardInfo;
        
                switch boardInfo.Architecture
                    case 'avr'
                        % Add SPI Library - For AVR Based
                        ideRootPath = arduino.supportpkg.getAVRRoot;
                        addIncludePaths(buildInfo, fullfile(ideRootPath, 'hardware', 'arduino', 'avr', 'libraries', 'SPI', 'src'));
                        srcFilePath = fullfile(ideRootPath, 'hardware', 'arduino', 'avr', 'libraries', 'SPI', 'src');
                        fileNameToAdd = {'SPI.cpp'};
                        addSourceFiles(buildInfo, fileNameToAdd, srcFilePath);
                
                        % Add Wire / I2C Library - For AVR Based
                        addIncludePaths(buildInfo, fullfile(ideRootPath, 'hardware', 'arduino', 'avr', 'libraries', 'Wire', 'src'));
                        addIncludePaths(buildInfo, fullfile(ideRootPath, 'hardware', 'arduino', 'avr', 'libraries', 'Wire', 'src', 'utility'));
                        srcFilePath = fullfile(ideRootPath, 'hardware', 'arduino', 'avr', 'libraries', 'Wire', 'src');
                        fileNameToAdd = {'Wire.cpp'};
                        addSourceFiles(buildInfo, fileNameToAdd, srcFilePath);
                        srcFilePath = fullfile(ideRootPath, 'hardware', 'arduino', 'avr', 'libraries', 'Wire', 'src', 'utility');
                        fileNameToAdd = {'twi.c'};
                        addSourceFiles(buildInfo, fileNameToAdd, srcFilePath);

                        % Include source files
                        libDirA_arch =  fullfile(fileparts(mfilename('fullpath')),'libraries/Servo-1.2.1/src/avr');
                        addSourceFiles(buildInfo,'Servo.cpp',libDirA_arch);
                    
                    case 'sam'
                        % Add SPI Library - For SAM Based
                        libSAMPath = arduino.supportpkg.getSAMLibraryRoot;
                        addIncludePaths(buildInfo, fullfile(libSAMPath, 'SPI','src'));
                        srcFilePath = fullfile(libSAMPath, 'SPI','src');
                        fileNameToAdd = {'SPI.cpp'};
                        addSourceFiles(buildInfo, fileNameToAdd, srcFilePath);
                
                        % Add Wire / I2C Library - For SAM Based
                        addIncludePaths(buildInfo, fullfile(libSAMPath, 'Wire', 'src'));
                        srcFilePath= fullfile(libSAMPath, 'Wire', 'src');
                        fileNameToAdd = {'Wire.cpp'};
                        addSourceFiles(buildInfo, fileNameToAdd, srcFilePath);

                        % Include source files
                        libDirA_arch =  fullfile(fileparts(mfilename('fullpath')),'libraries/Servo-1.2.1/src/sam');
                        addSourceFiles(buildInfo,'Servo.cpp',libDirA_arch);
                
    %                 case 'samd'
    %                     % Add SPI Library - For SAMD Based
    %                     libSAMDPath = arduino.supportpkg.getSAMDLibraryRoot;
    %                     addIncludePaths(buildInfo, fullfile(libSAMDPath, 'SPI'));
    %                     srcFilePath = fullfile(libSAMDPath, 'SPI');
    %                     fileNameToAdd = {'SPI.cpp'};
    %                     addSourceFiles(buildInfo, fileNameToAdd, srcFilePath);
    %             
    %                     % Add Wire / I2C Library - For SAMD Based
    %                     addIncludePaths(buildInfo, fullfile(libSAMDPath, 'Wire'));
    %                     srcFilePath= fullfile(libSAMDPath, 'Wire');
    %                     fileNameToAdd = {'Wire.cpp'};
    %                     addSourceFiles(buildInfo, fileNameToAdd, srcFilePath);
                
                    otherwise
                        warning('Unexpected board type. Check again.')
                    end


                % Use the following API's to add include files, sources and
                % linker flags
                %addIncludeFiles(buildInfo,'source.h',includeDir);
                %addSourceFiles(buildInfo,'source.c',srcDir);
                %addLinkFlags(buildInfo,{'-lSource'});
                %addLinkObjects(buildInfo,'sourcelib.a',srcDir);
                %addCompileFlags(buildInfo,{'-D_DEBUG=1'});
                %addDefines(buildInfo,'MY_DEFINE_1')
            end
        end
    end
end
