function run_matlab_tests(build_dir, source_dir)
% run_matlab_tests  Run all MATLAB tests for mwrap.
%
%   run_matlab_tests(BUILD_DIR, SOURCE_DIR) runs the example and unit tests
%   using MEX binaries from BUILD_DIR and test scripts from SOURCE_DIR.
%
%   This script is designed for use with matlab-actions/run-command in CI.
%   It exits with a non-zero status on failure.

if nargin < 2
    error('Usage: run_matlab_tests(build_dir, source_dir)');
end

n_pass = 0;
n_fail = 0;
failures = {};

%% -- Example tests ----------------------------------------------------------

example_tests = {
    % {test_name, mex_dir, script_dirs, script_name, needs_cd}
    {'eventq_plain',  fullfile(build_dir, 'example', 'eventq_plain'),  ...
        {fullfile(source_dir, 'example', 'eventq')}, 'testq_plain', false}
    {'eventq_handle', fullfile(build_dir, 'example', 'eventq_handle'), ...
        {fullfile(source_dir, 'example', 'eventq')}, 'testq_handle', false}
    {'eventq_class',  fullfile(build_dir, 'example', 'eventq_class'),  ...
        {fullfile(source_dir, 'example', 'eventq')}, 'testq_class', false}
    {'eventq2',       fullfile(build_dir, 'example', 'eventq2'),       ...
        {fullfile(source_dir, 'example', 'eventq2')}, 'testq2', false}
    {'zlib',          fullfile(build_dir, 'example', 'zlib'),          ...
        {fullfile(source_dir, 'example', 'zlib')}, 'testgz', true}
    {'fem_simple',    fullfile(build_dir, 'example', 'fem_interface'), ...
        {fullfile(source_dir, 'example', 'fem')}, 'test_simple', true}
    {'fem_patch',     fullfile(build_dir, 'example', 'fem_interface'), ...
        {fullfile(source_dir, 'example', 'fem')}, 'test_patch', true}
    {'fem_assembler', fullfile(build_dir, 'example', 'fem_interface'), ...
        {fullfile(source_dir, 'example', 'fem')}, 'test_assembler', true}
};

for i = 1:numel(example_tests)
    t = example_tests{i};
    test_name  = t{1};
    mex_dir    = t{2};
    script_dirs = t{3};
    script_name = t{4};
    needs_cd   = t{5};

    fprintf('\n=== Running example test: %s ===\n', test_name);
    saved_path = path;
    saved_dir = pwd;
    try
        addpath(mex_dir);
        for j = 1:numel(script_dirs)
            addpath(script_dirs{j});
        end
        if needs_cd
            cd(mex_dir);
        end
        feval(script_name);
        fprintf('PASS: %s\n', test_name);
        n_pass = n_pass + 1;
    catch ME
        fprintf('FAIL: %s -- %s\n', test_name, ME.message);
        n_fail = n_fail + 1;
        failures{end+1} = test_name; %#ok<AGROW>
    end
    cd(saved_dir);
    path(saved_path);
end

%% -- Unit tests (testing/) --------------------------------------------------

testing_mex_dir = fullfile(build_dir, 'testing');
testing_gen_dir = fullfile(build_dir, 'testing', 'octave');
testing_src_dir = fullfile(source_dir, 'testing');

unit_tests = {
    'test_transfers'
    'test_cpp_complex'
    'test_c99_complex'
    'test_catch'
    'test_fortran1'
    'test_fortran2'
    'test_redirect'
    'test_include'
    'test_single'
    'test_char'
};

for i = 1:numel(unit_tests)
    test_name = unit_tests{i};
    fprintf('\n=== Running unit test: %s ===\n', test_name);
    saved_path = path;
    saved_dir = pwd;
    try
        addpath(testing_mex_dir);
        addpath(testing_gen_dir);
        addpath(testing_src_dir);
        feval(test_name);
        fprintf('PASS: %s\n', test_name);
        n_pass = n_pass + 1;
    catch ME
        fprintf('FAIL: %s -- %s\n', test_name, ME.message);
        n_fail = n_fail + 1;
        failures{end+1} = test_name; %#ok<AGROW>
    end
    cd(saved_dir);
    path(saved_path);
end

%% -- Summary -----------------------------------------------------------------

fprintf('\n============================\n');
fprintf('Results: %d passed, %d failed\n', n_pass, n_fail);
if n_fail > 0
    fprintf('Failures:\n');
    for i = 1:numel(failures)
        fprintf('  - %s\n', failures{i});
    end
    error('mwrap:testFailure', '%d test(s) failed.', n_fail);
end
fprintf('All tests passed.\n');

end
