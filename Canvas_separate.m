%% Canvas Separate
% Take submitted files from Canvas, separate into folders, and remove
% Canvas-added text from file names.
%
% John Miller, 2020-05-11

clear

% Ask user for folder on which to operate
disp('Enter a folder with files inside (press Enter')
disp('to use Current Folder):')
user_dir = input('','s');

% Get a list of all files & folders in Current Folder or user folder
if isempty(user_dir)
    % If user doesn't give folder, use Current Folder
    all_files_folders = dir;
    user_dir = '.';
else
    % Check for valid folder name
    if isfolder(user_dir)
        all_files_folders = dir(user_dir);
    else
        error('Not a valid folder.')
    end
end
    
% --- Separate files and folders ---
% Find all of the folders (directories) in the list
temp = {};
[temp{1:length(all_files_folders),1}] = deal(all_files_folders.isdir);
isdir_array = cell2mat(temp);
% Put into separate structs
files = all_files_folders(~isdir_array);
folders = all_files_folders(isdir_array);

% Remove "." and ".." by converting the names to a cell array and then
% finding those strings and deleting the corresponding entries
temp = {};
[temp{1:length(folders),1}] = deal(folders.name);
dot_idx = strcmp(temp,'.');
ddot_idx = strcmp(temp,'..');
folders(dot_idx | ddot_idx) = [];


% --- Work thru all files, allow user to decide about each one ---

run_all = 0;
run_one = 0;

for current_file = 1:length(files)

    % Print the name
    files(current_file)
    
    % Ask the user if they want to move this file
    if ~run_all
        run_one = input('Do you want to operate on this file? (0=no, 1=yes, 2=yes to all) ');
        if run_one == 2
            run_all = 1;
        end
    end
        
    % If user wants to, rename and put file into folder
    if run_one
        
        % Separate filename based on underscore characters
        [filename_split,split_pts] = regexp(files(current_file).name,'_','split');

        % Note: Canvas filename structure is:
        %   lastfirst_#####_#######_originalfilename.extension
        % OR if it's after the due date:
        %   lastfirst_late_#####_#######_originalfilename.extension

        % Get student's name
        name = filename_split{1};
        % Get the original file's name (with underscores)
        if strcmp(filename_split{2},'late')
            % Account for late submission in file name
            original_filename = files(current_file).name(split_pts(4)+1:end)
        else
            original_filename = files(current_file).name(split_pts(3)+1:end)
        end

        % Note: file/directory functions below will issue error if
        % operation is not valid

        % Create folder with student's name
        % (If it already exists, warning will be issued, but operation
        % will continue)
        mkdir(user_dir,name)

        % Move file into student's folder and rename
        movefile([user_dir '/' files(current_file).name],[user_dir '/' name '/' original_filename])
    end
end

disp('Done. No more files.')
