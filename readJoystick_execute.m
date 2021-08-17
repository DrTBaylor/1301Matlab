%% readJoystick Execute
% Try running student scripts, separated into sub-folders. Student
% files can have any name. The user will be presented a list and may
% choose which files to execute.
%
% This file should be in the top-level folder, along with the
% following functions: 
%   * bear_icon.m
%   * draw_slingshot.m
%   * draw_target.m
%   * trajectory.m
%
% See also READJOYSTICK_SEPARATE
%
% John Miller, 2020-05-01


%% Execute each student's code

clear

% Setup Arduino for use with student functions
a = arduino();
pin_btn = 'D5';
pin_x = 'A0';
pin_y = 'A2';
a.configurePin(pin_btn,'pullup');

figure(1), clf
axis([0 100 0 60])


% --- Gets lists of files and folders ---
% Get a list of all files & folders in Current Folder
all_files_folders = dir;

% Find all of the folders (directories) in the list and put into separate structs
files = all_files_folders(~[all_files_folders.isdir]);
folders = all_files_folders([all_files_folders.isdir]);

% Remove "." and ".." by converting the names to a cell array and then
% finding those strings and deleting the corresponding entries
temp = {};
[temp{1:length(folders),1}] = deal(folders.name);
dot_idx = strcmp(temp,'.');
ddot_idx = strcmp(temp,'..');
folders(dot_idx | ddot_idx) = [];

% Print list of files in Current Folder
%disp('Note: Files in Current Folder: ')
%temp = {};
%[temp{1:length(files),1}] = deal(files.name);
%disp(temp)

% Always run once
user_continue = 1;

while user_continue
    
    % Print list of folders in Current Folder
    fprintf('Folders in Current Folder:\n')
    for n = 1:length(folders)
        fprintf('%4i)  %s\n',n,folders(n).name)
    end
    
    % Specify the folder to find student's code
    % Can be number (1, 2, 3...) or name ("studenttest")
    desired_folder = input('Enter folder number or name: ');
    
    % If user enters number, use that value (i.e. do nothing)
    % If user enters name, search for it
    if ~isnumeric(desired_folder)
        % Find matching folder name
        temp = {};
        [temp{1:length(folders),1}] = deal(folders.name);
        desired_idx = strncmp(temp,desired_folder,length(desired_folder));
        % If more than one match, error.  If not, use that index value.
        if length(desired_idx) > 1
            error('More than one folder matches that name.')
        else
            % Only 1 match
            desired_folder = find(desired_idx);
        end
    end
    
    % Store in variable to simplify code
    student_folder = folders(desired_folder).name;
    
    % Print for user to know
    fprintf('\nSpecified folder = "%s"\n\n',student_folder)
    
    % Add student folder to ML Path so it can search for function
    student_fullpath = [pwd '\' student_folder];
    addpath(student_fullpath)
    
    % Attempt to run student's function
    try
        [mag,ang] = readJoystick(10,45,a,pin_x,pin_y,pin_btn)
    catch e
        warning(e.identifier,'Error while running "%s":\n%s\n%s on line %i.',...
            student_folder,...
            e.message, e.stack(1).name, e.stack(1).line )
    end
    
%     
%     % Get list of files inside the specified folder
%     student_files = dir([student_folder '/*.*']);
%     temp = {};
%     [temp{1:length(student_files),1}] = deal(student_files.name);
%     dot_idx = strcmp(temp,'.');
%     ddot_idx = strcmp(temp,'..');
%     student_files(dot_idx | ddot_idx) = [];
%     
%     % Print the folder name and files inside
%     fprintf('Files in folder "%s":\n',student_folder)
%     for n = 1:length(student_files)
%         fprintf('%4i)  %s\n',n,student_files(n).name)
%     end
%     file_num_to_open = input('Execute which file? ');
%     
%     % Get file extension
%     [~,~,file_extension] = fileparts(student_files(file_num_to_open).name);
%     
%     % Assemble full relative file path
%     file_to_open = [student_folder '\' student_files(file_num_to_open).name];
%     
%     % Use file extension to determine action
%     % Note: lower() converts all characters to lowercase
%     switch lower(file_extension)
%         case {'.jpg','.jpeg','.png','.gif','.bmp','.tif','.tiff'}
%             % --- Open image in figure window ---
%             % Note: Use arbitrarily high figure number to avoid
%             % being overwritten by student's code (i.e. they will most
%             % likely use 1, 2, 3, etc.
%             figure(11)
%             imshow(file_to_open)
%         
%         case {'.doc','.docx','.xls','.xlsx','.txt'}
%             % --- Open other documents in Windows ---
%             winopen(file_to_open)
%             
%         case '.m'
%             % --- Attempt to execute student code ---
%             run_file = 1;   % Always run once
%             while run_file
%                 try
%                     % Specify and bring up figure window (different
%                     % from image above)
%                     figure(12), clf
% 
%                     % Open the file in the Editor to read code (have to close
%                     % manually)
%                     edit(file_to_open)
% 
%                     % Note: run temporarily changes the current folder. This is
%                     % why the top-level folder needs to be added to the Path.
%                     %run([student_folder '\' student_files(file_to_run).name])
% 
%                     % Run in separate function, so student code accesses
%                     % separate workspace (to protect this script's
%                     % variables)
%                     runStudentCode(file_to_open)
%                 catch e
%                     warning(e.identifier,'Error while running "%s":\n%s\n%s on line %i.',...
%                         file_to_open,...
%                         e.message, e.stack(1).name, e.stack(1).line )
%                 end
%                 % Ask user whether to run again
%                 run_file = input('Do you want to run this file again? (1=yes,0=no) ');
%             end
% 
%         otherwise
%             error('File extension %s not recognized',file_extension)
%     end


    % Remove student folder that was added to path
    rmpath(student_fullpath)

    user_continue = input('Do you want to run another file? (1=yes,0=no) ');
end


%% Local workspace function
% Note: In ver 2017a, you must run this entire script (F5) in order
% for it to recognize the local function. Running just the upper
% section does not work.

function runStudentCode(RSC_filename)
% RUNSTUDENTCODE Runs student script in separate workspace.

%     try 
        % Note: run temporarily changes the Current Folder
        run(RSC_filename)
%     catch RSC_err
        % Return error struct instead of printing:
        %warning('There was an error while running "%s":',RSC_filename)
        %fprintf('%s\n', RSC_err.identifier)
        %fprintf('%s\n', RSC_err.message)
%     end

end